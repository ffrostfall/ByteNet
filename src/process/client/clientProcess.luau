local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local retrievePacketFromID = require(ReplicatedStorage.Packages.ByteNet.process.retrievePacketFromID)
local byteNetInstance = require(script.Parent.Parent.Parent.process.byteNetInstance)
local channel = require(script.Parent.Parent.Parent.process.channel)
local reliabilityTypeList = require(script.Parent.Parent.Parent.storage.reliabilityTypes.reliabilityTypeList)
local wallyInstanceManager = require(ReplicatedStorage.Packages.wallyInstanceManager)

local reliableChannel = channel()
local unreliableChannel = channel()
local listeners = {}

local function processIncomingBuffer(receivedBuffer)
	local cursor = 0
	while cursor < buffer.len(receivedBuffer) do
		local packetID = buffer.readu8(receivedBuffer, cursor)

		local packet = retrievePacketFromID(packetID)

		local packetBuffer = buffer.create(packet._size)
		buffer.copy(packetBuffer, 0, receivedBuffer, cursor + 1, packet._size)

		local structure = {} -- convertToStructure(packetBuffer, packet._sortedStructure)
		for _, callback in listeners[packetID] do
			callback(structure)
		end

		cursor += packet._size + 1
	end
end

local clientProcess = {}

function clientProcess.start()
	local remoteInstances: {
		[string]: RemoteEvent | UnreliableRemoteEvent,
	} = {
		[reliabilityTypeList.reliable] = wallyInstanceManager.waitForInstance(byteNetInstance, "reliable", 3) :: RemoteEvent,
		[reliabilityTypeList.unreliable] = wallyInstanceManager.waitForInstance(byteNetInstance, "unreliable", 3) :: UnreliableRemoteEvent,
	}

	if not remoteInstances[reliabilityTypeList.reliable] then
		warn("ByteNet: Could not find reliable remote event")
		return
	end

	if not remoteInstances[reliabilityTypeList.unreliable] then
		warn("ByteNet: Could not find unreliable remote event")
		return
	end

	local reliable: RemoteEvent = remoteInstances[reliabilityTypeList.reliable] :: RemoteEvent
	local unreliable: UnreliableRemoteEvent = remoteInstances[reliabilityTypeList.unreliable] :: UnreliableRemoteEvent

	reliable.OnClientEvent:Connect(processIncomingBuffer)
	unreliable.OnClientEvent:Connect(processIncomingBuffer)

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

function clientProcess.listen(packetID: number, callback: (data: {}) -> ())
	if not listeners[packetID] then
		listeners[packetID] = {}
	end

	table.insert(listeners[packetID], callback)
end

function clientProcess.send(reliabilityType: reliabilityTypeList.reliabilityType, packetBuffer: buffer)
	if reliabilityType == reliabilityTypeList.reliable then
		reliableChannel:add(packetBuffer)
	elseif reliabilityType == reliabilityTypeList.unreliable then
		unreliableChannel:add(packetBuffer)
	end
end

return clientProcess
