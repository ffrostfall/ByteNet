--!native
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local buffer_writer = require("./buffer_writer")
local read = require("./read")
local types = require("../types")

local write_packet = buffer_writer.write_packet

-- All ChannelState is set to nil upon being sent which is why these are all optionals
local per_player_reliable: { [Player]: types.ChannelState } = {}
local per_player_unreliable: { [Player]: types.ChannelState } = {}

-- Shared with: src/process/client.luau (Infeasible to split this into another file)
@native
local function create(): types.ChannelState
	return {
		cursor = 0,
		size = 256,
		references = {},
		buff = buffer.create(256),
	}
end

@native
local function dump(channel: types.ChannelState): (buffer, { unknown }?)
	local cursor = channel.cursor
	local dump_buff = buffer.create(cursor)

	buffer.copy(dump_buff, 0, channel.buff, 0, cursor)

	return dump_buff, if #channel.references > 0 then channel.references else nil
end
-- No longer shared

local globalReliable: types.ChannelState = create()
local globalUnreliable: types.ChannelState = create()

-- TODO handle invalid data better
@native
local function on_server_event(player: Player, data, references)
	-- Only accept buffer data
	if not (typeof(data) == "buffer") then
		return
	end

	read(data, references, player)
end

@native
local function player_added(player)
	if not per_player_reliable[player] then
		per_player_reliable[player] = create()
	end

	if not per_player_unreliable[player] then
		per_player_unreliable[player] = create()
	end
end

local server = {}

function server.sendAllReliable(id: number, writer: (value: any) -> (), data: { [string]: any })
	globalReliable = write_packet(globalReliable, id, writer, data)
end

function server.sendAllUnreliable(id: number, writer: (value: any) -> (), data: { [string]: any })
	globalUnreliable = write_packet(globalUnreliable, id, writer, data)
end

function server.sendPlayerReliable(
	player: Player,
	id: number,
	writer: (value: any) -> (),
	data: { [string]: any }
)
	per_player_reliable[player] = write_packet(per_player_reliable[player], id, writer, data)
end

function server.sendPlayerUnreliable(
	player: Player,
	id: number,
	writer: (value: any) -> (),
	data: { [string]: any }
)
	per_player_unreliable[player] = write_packet(per_player_unreliable[player], id, writer, data)
end

function server.start()
	local reliableRemote = Instance.new("RemoteEvent")
	reliableRemote.Name = "ByteNetReliable"
	reliableRemote.OnServerEvent:Connect(on_server_event)
	reliableRemote.Parent = ReplicatedStorage

	local unreliableRemote = Instance.new("UnreliableRemoteEvent")
	unreliableRemote.Name = "ByteNetUnreliable"
	unreliableRemote.OnServerEvent:Connect(on_server_event)
	unreliableRemote.Parent = ReplicatedStorage

	for _, player in Players:GetPlayers() do
		player_added(player)
	end

	Players.PlayerAdded:Connect(player_added)
	Players.PlayerRemoving:Connect(function(player)
		per_player_reliable[player] = nil
		per_player_unreliable[player] = nil
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
			if per_player_reliable[player].cursor > 0 then
				local b, r = dump(per_player_reliable[player])
				reliableRemote:FireClient(player, b, r)

				per_player_reliable[player].cursor = 0
				table.clear(per_player_reliable[player].references)
			end

			if per_player_unreliable[player].cursor > 0 then
				local b, r = dump(per_player_unreliable[player])
				unreliableRemote:FireClient(player, b, r)

				per_player_unreliable[player].cursor = 0
				table.clear(per_player_unreliable[player].references)
			end
		end
	end)
end

return server
