local RunService = game:GetService("RunService")

local byteNetInstance = require(script.Parent.Parent.Parent.process.byteNetInstance)
local reliabilityTypeList = require(script.Parent.Parent.Parent.storage.reliabilityTypeList)
local wallyInstanceManager = require(script.Parent.Parent.Parent.Parent.wallyInstanceManager)

local function onClientEvent(receivedBuffer) end

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

	RunService.Heartbeat:Connect(function() end)
end

return clientProcess
