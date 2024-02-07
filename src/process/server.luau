local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local wallyInstanceManager = require(script.Parent.Parent.Parent.wallyInstanceManager)
local types = require(script.Parent.Parent.types)
local read = require(script.Parent.read)
local sendChannel = require(script.Parent.sendChannel)
local channels = {
	players = {} :: { [Player]: { reliable: sendChannel.sendChannelType, unreliable: sendChannel.sendChannelType } },

	reliable = sendChannel(),
	unreliable = sendChannel(),
}

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

local function onPlayerAdded(player: Player)
	channels.players[player] = {
		reliable = sendChannel(),
		unreliable = sendChannel(),
	}
end

local serverProcess = {}

function serverProcess.sendAllReliable(id: number, format: types.packetFormat, data: { [string]: any })
	channels.reliable:add(id, format, data)
end

function serverProcess.sendAllUnreliable(id: number, format: types.packetFormat, data: { [string]: any })
	channels.unreliable:add(id, format, data)
end

function serverProcess.sendPlayerReliable(
	player: Player,
	id: number,
	format: types.packetFormat,
	data: { [string]: any }
)
	channels.players[player].reliable:add(id, format, data)
end

function serverProcess.sendPlayerUnreliable(
	player: Player,
	id: number,
	format: types.packetFormat,
	data: { [string]: any }
)
	channels.players[player].unreliable:add(id, format, data)
end

function serverProcess.start()
	local remoteInstances = {
		reliable = Instance.new("RemoteEvent"),
		unreliable = Instance.new("UnreliableRemoteEvent"),
	}

	remoteInstances.reliable.Name = "reliable"
	remoteInstances.unreliable.Name = "unreliable"

	local byteNetInstance = script.Parent.Parent.Parent
	wallyInstanceManager.add(byteNetInstance, remoteInstances.reliable)
	wallyInstanceManager.add(byteNetInstance, remoteInstances.unreliable)

	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(function(player: Player) end)

	remoteInstances.reliable.OnServerEvent:Connect(onServerEvent)
	remoteInstances.unreliable.OnServerEvent:Connect(onServerEvent)

	RunService.Heartbeat:Connect(function()
		local reliableBuffer = channels.reliable:empty()
		if reliableBuffer ~= nil then
			remoteInstances.reliable:FireAllClients(reliableBuffer)
		end

		local unreliableBuffer = channels.unreliable:empty()
		if unreliableBuffer ~= nil then
			remoteInstances.unreliable:FireAllClients(unreliableBuffer)
		end

		for player, playerChannels in channels.players do
			local reliablePlayerBuffer = playerChannels.reliable:empty()
			local unreliablePlayerBuffer = playerChannels.unreliable:empty()

			if reliablePlayerBuffer ~= nil then
				remoteInstances.reliable:FireClient(player, reliablePlayerBuffer)
			end

			if unreliablePlayerBuffer ~= nil then
				remoteInstances.unreliable:FireClient(player, unreliablePlayerBuffer)
			end
		end
	end)
end

return serverProcess
