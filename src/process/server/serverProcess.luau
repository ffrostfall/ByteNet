local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local mergeBufferArray = require(ReplicatedStorage.Packages.ByteNet.process.mergeBufferArray)
local retrievePacketFromID = require(ReplicatedStorage.Packages.ByteNet.process.retrievePacketFromID)
local byteNetInstance = require(script.Parent.Parent.byteNetInstance)
local wallyInstanceManager = require(ReplicatedStorage.Packages.wallyInstanceManager)
local reliabilityTypeList = require(script.Parent.Parent.Parent.storage.reliabilityTypes.reliabilityTypeList)
local channel = require(script.Parent.Parent.channel)

local listeners: { [number]: { [number]: (data: any, player: Player?) -> () } } = {}
local remoteInstances = {
	reliable = Instance.new("RemoteEvent"),
	unreliable = Instance.new("UnreliableRemoteEvent"),
}
local playerChannels = {}
local globalChannels = {
	[reliabilityTypeList.reliable] = channel(),
	[reliabilityTypeList.unreliable] = channel(),
}

local function processIncomingBuffer(player, receivedBuffer)
	local cursor = 0
	while cursor < buffer.len(receivedBuffer) do
		local packetID = buffer.readu8(receivedBuffer, cursor)

		local packet = retrievePacketFromID(packetID)

		local packetBuffer = buffer.create(packet._size)
		buffer.copy(packetBuffer, 0, receivedBuffer, cursor + 1, packet._size)

		local structure = {} -- convertToStructure(packetBuffer, packet._sortedStructure)
		for _, callback in listeners[packetID] do
			callback(structure, player)
		end

		cursor += packet._size + 1
	end
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
		playerChannels[player][reliabilityTypeList.reliable]:flush()
		playerChannels[player][reliabilityTypeList.unreliable]:flush()

		playerChannels[player] = nil
	end)

	remoteInstances.reliable.OnServerEvent:Connect(processIncomingBuffer)

	remoteInstances.unreliable.OnServerEvent:Connect(processIncomingBuffer)

	RunService.Heartbeat:Connect(function()
		local globalReliableQueue = globalChannels[reliabilityTypeList.reliable]:flush()
		local globalUnreliableQueue = globalChannels[reliabilityTypeList.unreliable]:flush()

		for player, channels in playerChannels do
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

function serverProcess.listen(id: number, callback: (data: {}, player: Player?) -> ())
	if listeners[id] then
		table.insert(listeners[id], callback)
	else
		listeners[id] = { callback }
	end
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
