local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local byteNetInstance = require(script.Parent.Parent.byteNetInstance)
local wallyInstanceManager = require(script.Parent.Parent.Parent.Parent.wallyInstanceManager)

local remoteInstances = {
	reliable = Instance.new("RemoteEvent"),
	unreliable = Instance.new("UnreliableRemoteEvent"),
}

local function onServerEvent(player: Player, data)
	if buffer.len(data) >= 100000 then
		warn("over 100K byte limit from player: " .. player.UserId)
		return
	end
end

local function onPlayerAdded(player: Player) end

local serverProcess = {}

function serverProcess.start()
	remoteInstances.reliable.Name = "reliable"
	remoteInstances.unreliable.Name = "unreliable"

	wallyInstanceManager.add(byteNetInstance, remoteInstances.reliable)
	wallyInstanceManager.add(byteNetInstance, remoteInstances.unreliable)

	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)

	Players.PlayerRemoving:Connect(function(player: Player) end)

	remoteInstances.reliable.OnServerEvent:Connect(onServerEvent)
	remoteInstances.unreliable.OnServerEvent:Connect(onServerEvent)

	RunService.Heartbeat:Connect(function() end)
end

return serverProcess
