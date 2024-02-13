--!native
--!optimize 2
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local read = require(script.Parent.read)
local bufferWriter = require(script.Parent.bufferWriter)

local globalReliable: channelData? = nil
local globalUnreliable: channelData? = nil
local perPlayerReliable: { [Player]: channelData? } = {}
local perPlayerUnreliable: { [Player]: channelData? } = {}

type channelData = {
	cursor: number,
	jobs: types.bufferQueue,
}

local cursor = 0
local jobs = {}

local function load(freshChannel: channelData?)
	if not freshChannel then
		cursor = 0
		jobs = {}
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
		jobs = jobs,
	}
end

local function onServerEvent(player: Player, data)
	if not (typeof(data) == "buffer") then
		return
	end

	if buffer.len(data) >= 100000 then
		warn("over 100K byte limit from player: " .. player.UserId)
		return
	end

	read(data)
end

local function addPacketToLoadedChannel(id: number, format: types.packetFormat, data: { [string]: any })
	bufferWriter.u8(cursor, id)
	cursor += 1

	for _, value in format do
		cursor += (value[2] :: (cursor: number, value: any) -> number)(cursor, data[value[3] :: string])
	end
end

local function dumpLoadedChannel(): buffer
	local dumpBuffer = buffer.create(cursor)

	for index = 1, #jobs, 3 do
		(jobs[index] :: (b: buffer, cursor: number, value: any) -> ())(
			dumpBuffer,
			jobs[index + 1] :: number,
			jobs[index + 2]
		)
	end

	return dumpBuffer
end

local function onPlayerAdded(player: Player)
	perPlayerReliable[player] = nil
	perPlayerUnreliable[player] = nil
end

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
	local reliableRemote = Instance.new("RemoteEvent")
	local unreliableRemote = Instance.new("UnreliableRemoteEvent")

	reliableRemote.Name = "ByteNetReliable"
	unreliableRemote.Name = "ByteNetUnreliable"

	reliableRemote.Parent = ReplicatedStorage
	unreliableRemote.Parent = ReplicatedStorage

	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(function() end)

	reliableRemote.OnServerEvent:Connect(onServerEvent)
	unreliableRemote.OnServerEvent:Connect(onServerEvent)

	RunService.Heartbeat:Connect(function()
		if globalReliable ~= nil then
			load(globalReliable)
			reliableRemote:FireAllClients(dumpLoadedChannel())

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
