local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local byteNetInstance = require(script.Parent.Parent.Parent.process.byteNetInstance)
local channel = require(script.Parent.Parent.Parent.process.channel)
local reliabilityTypeList = require(script.Parent.Parent.Parent.storage.reliabilityTypeList)
local receive = require(script.Parent.Parent.parsing.receive)
local wallyInstanceManager = require(ReplicatedStorage.Packages.wallyInstanceManager)

local reliableChannel = channel()
local unreliableChannel = channel()

local function onClientEvent(receivedBuffer)
	receive(receivedBuffer)
end

local clientProcess = {}

function clientProcess.start()
	local remoteInstances: {
		[string]: RemoteEvent | UnreliableRemoteEvent,
	} = {
		[reliabilityTypeList.reliable] = wallyInstanceManager.waitForInstance(byteNetInstance, "reliable", 3) :: RemoteEvent,
		[reliabilityTypeList.unreliable] = wallyInstanceManager.waitForInstance(byteNetInstance, "unreliable", 3) :: UnreliableRemoteEvent,
	}

	if not remoteInstances[reliabilityTypeList.reliable] or not remoteInstances[reliabilityTypeList.unreliable] then
		return
	end

	local reliable: RemoteEvent = remoteInstances[reliabilityTypeList.reliable] :: RemoteEvent
	local unreliable: UnreliableRemoteEvent = remoteInstances[reliabilityTypeList.unreliable] :: UnreliableRemoteEvent

	reliable.OnClientEvent:Connect(onClientEvent)
	unreliable.OnClientEvent:Connect(onClientEvent)

	RunService.Heartbeat:Connect(function()
		local reliableQueue = reliableChannel:flush()
		local unreliableQueue = unreliableChannel:flush()

		if reliableQueue then
			reliable:FireServer(reliableQueue)
		end

		if unreliableQueue then
			unreliable:FireServer(unreliableQueue)
		end
	end)
end

function clientProcess.send(reliabilityType: reliabilityTypeList.reliabilityType, packetBuffer: buffer)
	if reliabilityType == reliabilityTypeList.reliable then
		reliableChannel:add(packetBuffer)
	elseif reliabilityType == reliabilityTypeList.unreliable then
		unreliableChannel:add(packetBuffer)
	end
end

return clientProcess
