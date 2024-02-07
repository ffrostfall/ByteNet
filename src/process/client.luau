local RunService = game:GetService("RunService")

local wallyInstanceManager = require(script.Parent.Parent.Parent.wallyInstanceManager)
local types = require(script.Parent.Parent.types)
local read = require(script.Parent.read)
local sendChannel = require(script.Parent.sendChannel)

local function onClientEvent(receivedBuffer)
	read(receivedBuffer)
end
local reliableChannel = sendChannel()
local unreliableChannel = sendChannel()

local clientProcess = {}

function clientProcess.sendReliable(id: number, format: types.packetFormat, data: { [string]: any })
	reliableChannel:add(id, format, data)
end

function clientProcess.sendUnreliable(id: number, format: types.packetFormat, data: { [string]: any })
	unreliableChannel:add(id, format, data)
end

function clientProcess.start()
	local byteNetInstance = script.Parent.Parent.Parent
	local remoteInstances: {
		reliable: RemoteEvent?,
		unreliable: UnreliableRemoteEvent?,
	} = {
		reliable = wallyInstanceManager.waitForInstance(byteNetInstance, "reliable", 3) :: RemoteEvent,
		unreliable = wallyInstanceManager.waitForInstance(byteNetInstance, "unreliable", 3) :: UnreliableRemoteEvent,
	}

	if not remoteInstances.reliable or not remoteInstances.unreliable then
		return
	end

	local reliableRemote = remoteInstances.reliable
	local unreliableRemote = remoteInstances.unreliable

	reliableRemote.OnClientEvent:Connect(onClientEvent)
	unreliableRemote.OnClientEvent:Connect(onClientEvent)

	RunService.Heartbeat:Connect(function()
		local reliableBuffer = reliableChannel:empty()
		if reliableBuffer then
			reliableRemote:FireServer(reliableBuffer)
		end

		local unreliableBuffer = unreliableChannel:empty()
		if unreliableBuffer then
			unreliableRemote:FireServer(unreliableBuffer)
		end
	end)
end

return clientProcess
