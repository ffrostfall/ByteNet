--!native
--!optimize 2
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local read = require(script.Parent.read)
local bufferWriter = require(script.Parent.bufferWriter)

local alloc = bufferWriter.alloc
local u8 = bufferWriter.u8

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
	if freshChannel then
		bufferWriter.load(freshChannel)
		return
	end

	local newChannel = table.clone(EMPTY)
	newChannel.buff = buffer.create(64)
	bufferWriter.load(newChannel)
end

local function dump(channel: types.channelData): buffer
	local cursor = channel.cursor
	local dumpBuffer = buffer.create(cursor)

	buffer.copy(dumpBuffer, 0, channel.buff, 0, cursor)

	return dumpBuffer
end
-- No longer shared

-- TODO handle invalid data better
local function onServerEvent(player: Player, data)
	-- Only accept buffer data
	if not (typeof(data) == "buffer") then
		return
	end

	read(data, player)
end

local serverProcess = {}

function serverProcess.sendAllReliable(id: number, writer: (value: any) -> (), data: { [string]: any })
	load(globalReliable)

	alloc(1)
	u8(id)
	writer(data)

	globalReliable = bufferWriter.export()
end

function serverProcess.sendAllUnreliable(id: number, writer: (value: any) -> (), data: { [string]: any })
	load(globalUnreliable)

	alloc(1)
	u8(id)
	writer(data)

	globalUnreliable = bufferWriter.export()
end

function serverProcess.sendPlayerReliable(
	player: Player,
	id: number,
	writer: (value: any) -> (),
	data: { [string]: any }
)
	load(perPlayerReliable[player])

	alloc(1)
	u8(id)
	writer(data)

	perPlayerReliable[player] = bufferWriter.export()
end

function serverProcess.sendPlayerUnreliable(
	player: Player,
	id: number,
	writer: (value: any) -> (),
	data: { [string]: any }
)
	load(perPlayerUnreliable[player])

	alloc(1)
	u8(id)
	writer(data)

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
