--!native
--!optimize 2
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local read = require(script.Parent.read)
local bufferWriter = require(script.Parent.bufferWriter)

-- All channelData is set to nil upon being sent which is why these are all optionals
local globalReliable: channelData? = nil
local globalUnreliable: channelData? = nil
local perPlayerReliable: { [Player]: channelData? } = {}
local perPlayerUnreliable: { [Player]: channelData? } = {}

-- Shared with: src/process/client.luau (Infeasible to split this into another file)
type channelData = {
	cursor: number,
	jobs: types.bufferQueue,
}

-- Cursor is copied, jobs is not.
local cursor: number = 0
local jobs = {}

local function load(freshChannel: channelData?)
	if not freshChannel then
		cursor = 0
		jobs = {} -- It's important to note this creates a new channel and creates a new reference
		bufferWriter.set(jobs)
		return
	end

	cursor = freshChannel.cursor
	jobs = freshChannel.jobs
	bufferWriter.set(jobs)
end

local function save(): channelData
	return {
		cursor = cursor,
		jobs = jobs, -- This saves the current reference to the jobs table, letting us switch it out later. Also important.
	}
end

-- TODO handle invalid data better
local function onServerEvent(player: Player, data)
	-- Only accept buffer data
	if not (typeof(data) == "buffer") then
		return
	end

	-- Limit the amount of data
	if buffer.len(data) >= 100000 then
		warn("over 100K byte limit from player: " .. player.UserId)
		return
	end

	read(data, player)
end

local function addPacketToLoadedChannel(id: number, format: types.packetFormat, data: { [string]: any })
	-- packet ID
	bufferWriter.u8(cursor, id)
	cursor += 1

	for _, value in format do
		-- value[2] is the write function, value[3] is the key
		cursor += (value[2] :: (cursor: number, value: any) -> number)(cursor, data[value[3] :: string])
	end
end

local function dumpLoadedChannel(): buffer
	local dumpBuffer = buffer.create(cursor)

	-- remember, jobs[1] is the function, jobs[2] is the cursor, and jobs[3] is the value
	-- iterate over all jobs in increments of 3, and call accordingly
	for index = 1, #jobs, 3 do
		-- We have to do this typecasting because luau doesn't have tuple tables yet
		(jobs[index] :: (b: buffer, cursor: number, value: any) -> ())(
			dumpBuffer,
			jobs[index + 1] :: number,
			jobs[index + 2]
		)
	end

	return dumpBuffer
end
-- No longer shared

local serverProcess = {}

function serverProcess.sendAllReliable(id: number, format: types.packetFormat, data: { [string]: any })
	load(globalReliable)
	addPacketToLoadedChannel(id, format, data)
	globalReliable = save()
end

function serverProcess.sendAllUnreliable(id: number, format: types.packetFormat, data: { [string]: any })
	load(globalUnreliable)
	addPacketToLoadedChannel(id, format, data)
	globalUnreliable = save()
end

function serverProcess.sendPlayerReliable(
	player: Player,
	id: number,
	format: types.packetFormat,
	data: { [string]: any }
)
	load(perPlayerReliable[player])
	addPacketToLoadedChannel(id, format, data)
	perPlayerReliable[player] = save()
end

function serverProcess.sendPlayerUnreliable(
	player: Player,
	id: number,
	format: types.packetFormat,
	data: { [string]: any }
)
	load(perPlayerUnreliable[player])
	addPacketToLoadedChannel(id, format, data)
	perPlayerUnreliable[player] = save()
end

function serverProcess.start()
	local reliableRemote: RemoteEvent = Instance.new("RemoteEvent")
	reliableRemote.Name = "ByteNetReliable"
	reliableRemote.OnServerEvent:Connect(onServerEvent)
	reliableRemote.Parent = ReplicatedStorage

	local unreliableRemote: UnreliableRemoteEvent = Instance.new("UnreliableRemoteEvent")
	unreliableRemote.Name = "ByteNetUnreliable"
	unreliableRemote.OnServerEvent:Connect(onServerEvent)
	unreliableRemote.Parent = ReplicatedStorage

	RunService.Heartbeat:Connect(function()
		-- Check if the channel has anything before trying to send it
		if globalReliable ~= nil then
			load(globalReliable)

			reliableRemote:FireAllClients(dumpLoadedChannel())

			-- Clear channel reference
			globalReliable = nil
		end

		if globalUnreliable ~= nil then
			load(globalUnreliable)

			unreliableRemote:FireAllClients(dumpLoadedChannel())

			globalUnreliable = nil
		end

		for _, player in Players:GetPlayers() do
			if perPlayerReliable[player] ~= nil then
				load(perPlayerReliable[player])

				reliableRemote:FireClient(player, dumpLoadedChannel())

				perPlayerReliable[player] = nil
			end

			if perPlayerUnreliable[player] ~= nil then
				load(perPlayerUnreliable[player])

				unreliableRemote:FireClient(player, dumpLoadedChannel())

				perPlayerUnreliable[player] = nil
			end
		end
	end)
end

return serverProcess
