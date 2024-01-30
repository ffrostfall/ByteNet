local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local mergeBufferArray = require(script.Parent.Parent.Parent.process.mergeBufferArray)
local byteNetInstance = require(script.Parent.Parent.byteNetInstance)
local wallyInstanceManager = require(script.Parent.Parent.Parent.Parent.wallyInstanceManager)
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

local function onServerEvent(player: Player, data)
	if buffer.len(data) >= 100000 then
		warn("over 100K byte limit from player: " .. player.UserId)
		return
	end

	receive(data, player)
end

local function onPlayerAdded(player: Player)
	if playerChannels[player] then
		return
	end

	playerChannels[player] = {
		[reliabilityTypeList.reliable] = channel(),
		[reliabilityTypeList.unreliable] = channel(),
	}
end

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

			if reliableQueue or globalReliableQueue then
				if globalReliableQueue then
					reliableQueue = mergeBufferArray({ reliableQueue or buffer.create(0), globalReliableQueue })
				end

				remoteInstances.reliable:FireClient(player, reliableQueue)
			end

			if unreliableQueue or globalUnreliableQueue then
				if globalUnreliableQueue then
					unreliableQueue = mergeBufferArray({ unreliableQueue or buffer.create(0), globalUnreliableQueue })
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
	if not playerChannels[player] then
		playerChannels[player] = {
			[reliabilityTypeList.reliable] = channel(),
			[reliabilityTypeList.unreliable] = channel(),
		}
	end
	playerChannels[player][reliabilityType]:add(packetBuffer)
end

function serverProcess.sendEveryone(reliabilityType: reliabilityTypeList.reliabilityType, packetBuffer: buffer)
	globalChannels[reliabilityType]:add(packetBuffer)
end

return serverProcess
