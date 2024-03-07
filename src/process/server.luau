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
local load = bufferWriter.load

-- All channelData is set to nil upon being sent which is why these are all optionals
local perPlayerReliable: { [Player]: types.channelData } = {}
local perPlayerUnreliable: { [Player]: types.channelData } = {}

-- Shared with: src/process/client.luau (Infeasible to split this into another file)
local function create()
	return {
		cursor = 0,
		size = 256,
		references = {},
		buff = buffer.create(256),
	}
end

local function dump(channel: types.channelData): (buffer, { unknown }?)
	local cursor = channel.cursor
	local dumpBuffer = buffer.create(cursor)

	buffer.copy(dumpBuffer, 0, channel.buff, 0, cursor)

	return dumpBuffer, if #channel.references > 0 then channel.references else nil
end
-- No longer shared

local globalReliable: types.channelData = create()
local globalUnreliable: types.channelData = create()

-- TODO handle invalid data better
local function onServerEvent(player: Player, data, references)
	-- Only accept buffer data
	if not (typeof(data) == "buffer") then
		return
	end

	read(data, references, player)
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
	local reliableRemote = Instance.new("RemoteEvent")
	reliableRemote.Name = "ByteNetReliable"
	reliableRemote.OnServerEvent:Connect(onServerEvent)
	reliableRemote.Parent = ReplicatedStorage

	local unreliableRemote = Instance.new("UnreliableRemoteEvent")
	unreliableRemote.Name = "ByteNetUnreliable"
	unreliableRemote.OnServerEvent:Connect(onServerEvent)
	unreliableRemote.Parent = ReplicatedStorage

	Players.PlayerAdded:Connect(function(player)
		perPlayerReliable[player] = create()
		perPlayerUnreliable[player] = create()
	end)

	RunService.Heartbeat:Connect(function()
		-- Check if the channel has anything before trying to send it
		if globalReliable.cursor > 0 then
			local b, r = dump(globalReliable)
			reliableRemote:FireAllClients(b, r)

			globalReliable.cursor = 0
			table.clear(globalReliable.references)
		end

		if globalUnreliable.cursor > 0 then
			local b, r = dump(globalUnreliable)
			unreliableRemote:FireAllClients(b, r)

			globalUnreliable.cursor = 0
			table.clear(globalUnreliable.references)
		end

		for _, player in Players:GetPlayers() do
			if perPlayerReliable[player].cursor > 0 then
				local b, r = dump(perPlayerReliable[player])
				reliableRemote:FireClient(player, b, r)

				perPlayerReliable[player].cursor = 0
				table.clear(perPlayerReliable[player].references)
			end

			if perPlayerUnreliable[player].cursor > 0 then
				local b, r = dump(perPlayerUnreliable[player])
				unreliableRemote:FireClient(player, b, r)

				perPlayerUnreliable[player].cursor = 0
				table.clear(perPlayerUnreliable[player].references)
			end
		end
	end)
end

return serverProcess
