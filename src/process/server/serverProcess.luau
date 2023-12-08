local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local mergeBufferArray = require(ReplicatedStorage.Packages.ByteNet.process.mergeBufferArray)
local byteNetInstance = require(script.Parent.Parent.byteNetInstance)
local wallyInstanceManager = require(ReplicatedStorage.Packages.wallyInstanceManager)
local reliabilityTypeList = require(script.Parent.Parent.Parent.storage.reliabilityTypeList)
local channel = require(script.Parent.Parent.channel)
local receive = require(script.Parent.Parent.parsing.receive)

local remoteInstances = {
	reliable = Instance.new("RemoteEvent"),
	unreliable = Instance.new("UnreliableRemoteEvent"),
}
local playerChannels = {}
local globalChannels = {
	[reliabilityTypeList.reliable] = channel(),
	[reliabilityTypeList.unreliable] = channel(),
}

local function onServerEvent(player, data)
	receive(data, player)
end

local serverProcess = {}

function serverProcess.start()
	remoteInstances.reliable.Name = "reliable"
	remoteInstances.unreliable.Name = "unreliable"

	wallyInstanceManager.add(byteNetInstance, remoteInstances.reliable)
	wallyInstanceManager.add(byteNetInstance, remoteInstances.unreliable)

	Players.PlayerAdded:Connect(function(player: Player)
		playerChannels[player] = {
			[reliabilityTypeList.reliable] = channel(),
			[reliabilityTypeList.unreliable] = channel(),
		}
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		playerChannels[player] = nil
	end)

	remoteInstances.reliable.OnServerEvent:Connect(onServerEvent)
	remoteInstances.unreliable.OnServerEvent:Connect(onServerEvent)

	RunService.Heartbeat:Connect(function()
		local globalReliableQueue = globalChannels[reliabilityTypeList.reliable]:flush()
		local globalUnreliableQueue = globalChannels[reliabilityTypeList.unreliable]:flush()

		for player, channels in playerChannels do
			if not player:IsDescendantOf(Players) then
				continue
			end

			local reliableQueue = channels[reliabilityTypeList.reliable]:flush()
			local unreliableQueue = channels[reliabilityTypeList.unreliable]:flush()

			if reliableQueue then
				if globalReliableQueue then
					reliableQueue = mergeBufferArray({ reliableQueue, globalReliableQueue })
				end

				remoteInstances.reliable:FireClient(player, reliableQueue)
			end

			if unreliableQueue then
				if globalUnreliableQueue then
					unreliableQueue = mergeBufferArray({ unreliableQueue, globalUnreliableQueue })
				end

				remoteInstances.unreliable:FireClient(player, unreliableQueue)
			end
		end
	end)
end

function serverProcess.sendTo(
	player: Player,
	reliabilityType: reliabilityTypeList.reliabilityType,
	packetBuffer: buffer
)
	playerChannels[player][reliabilityType]:add(packetBuffer)
end

function serverProcess.sendEveryone(reliabilityType: reliabilityTypeList.reliabilityType, packetBuffer: buffer)
	globalChannels[reliabilityType]:add(packetBuffer)
end

return serverProcess
