--!native
--!optimize 2
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local read = require(script.Parent.read)
local bufferWriter = require(script.Parent.bufferWriter)



-- All channelData is set to nil upon being sent which is why these are all optionals
local globalReliable: types.channelData? = nil
local globalUnreliable: types.channelData? = nil
local perPlayerReliable: { [Player]: types.channelData? } = {}
local perPlayerUnreliable: { [Player]: types.channelData? } = {}

-- Shared with: src/process/client.luau (Infeasible to split this into another file)
local EMPTY: types.channelData = {
	cursor = 0,
	size = 64,
	buff = nil :: any,
}

local function load(freshChannel: types.channelData?)
	if not freshChannel then
		local newChannel = table.clone(EMPTY)
		newChannel.buff = buffer.create(64)
		bufferWriter.load(newChannel)
		return
	end

	bufferWriter.load(freshChannel)
end

local function addPacketToLoadedChannel(format: types.packetFormat, data: { [string]: any })
	for _, value in format do
		-- value[2] is the write function, value[3] is the key
		(value[2] :: (cursor: number, value: any) -> number)(data[value[3] :: string])
	end
end

local function dump(channel: types.channelData): buffer
	local dumpBuffer = buffer.create(channel.cursor)
	buffer.copy(dumpBuffer, 0, channel.buff, 0, channel.cursor)
	return dumpBuffer
end
-- No longer shared

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

local serverProcess = {}

function serverProcess.sendAllReliable(id: number, format: types.packetFormat, data: { [string]: any })
	load(globalReliable)

	bufferWriter.u8(id)
	addPacketToLoadedChannel(format, data)

	globalReliable = bufferWriter.export()
end

function serverProcess.sendAllUnreliable(id: number, format: types.packetFormat, data: { [string]: any })
	load(globalUnreliable)

	bufferWriter.u8(id)
	addPacketToLoadedChannel(format, data)

	globalUnreliable = bufferWriter.export()
end

function serverProcess.sendPlayerReliable(
	player: Player,
	id: number,
	format: types.packetFormat,
	data: { [string]: any }
)
	load(perPlayerReliable[player])

	bufferWriter.u8(id)
	addPacketToLoadedChannel(format, data)

	perPlayerReliable[player] = bufferWriter.export()
end

function serverProcess.sendPlayerUnreliable(
	player: Player,
	id: number,
	format: types.packetFormat,
	data: { [string]: any }
)
	load(perPlayerUnreliable[player])

	bufferWriter.u8(id)
	addPacketToLoadedChannel(format, data)

	perPlayerUnreliable[player] = bufferWriter.export()
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
			reliableRemote:FireAllClients(dump(globalReliable))

			-- Clear channel reference
			globalReliable = nil
		end

		if globalUnreliable ~= nil then
			unreliableRemote:FireAllClients(dump(globalUnreliable))

			globalUnreliable = nil
		end

		for _, player in Players:GetPlayers() do
			if perPlayerReliable[player] ~= nil then
				reliableRemote:FireClient(player, dump(perPlayerReliable[player] :: types.channelData))

				perPlayerReliable[player] = nil
			end

			if perPlayerUnreliable[player] ~= nil then
				unreliableRemote:FireClient(player, dump(perPlayerUnreliable[player] :: types.channelData))

				perPlayerUnreliable[player] = nil
			end
		end
	end)
end

return serverProcess
