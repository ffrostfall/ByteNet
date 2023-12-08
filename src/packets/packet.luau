local RunService = game:GetService("RunService")

local clientPacketIDs = require(script.Parent.Parent.packets.identifiers.clientPacketIDs)
local serverPacketIDs = require(script.Parent.Parent.packets.identifiers.serverPacketIDs)
local clientProcess = require(script.Parent.Parent.process.client.clientProcess)
local send = require(script.Parent.Parent.process.parsing.send)
local serverProcess = require(script.Parent.Parent.process.server.serverProcess)
local reliabilityTypeList = require(script.Parent.Parent.storage.reliabilityTypeList)
local getUnique = require(script.Parent.getUnique)

local packetPrototype = {}
local packetMetatable = { __index = packetPrototype }
export type packetType = typeof(setmetatable(
	{} :: {
		_id: number,
		_order: { [number]: { string } },
		_reliabilityType: reliabilityTypeList.reliabilityType,

		_listeners: { [number]: (data: {}, player: Player) -> () },
	},
	packetMetatable
))

function packetPrototype.sendToAll(self: packetType, data)
	local packetBuffer = send(self._id, data, self._order)

	serverProcess.sendEveryone(self._reliabilityType, packetBuffer)
end

function packetPrototype.send(self: packetType, data: { [string]: any }, target: Player?)
	local packetBuffer = send(self._id, data, self._order)

	if RunService:IsServer() then
		if target then
			serverProcess.sendTo(target, self._reliabilityType, packetBuffer)
		else
			warn("no target specified")
		end
	elseif RunService:IsClient() then
		clientProcess.send(self._reliabilityType, packetBuffer)
	end
end

function packetPrototype.listen(self: packetType, callback: (data: {}, player: Player?) -> ())
	table.insert(self._listeners, callback)
end

return function(reliabilityType: reliabilityTypeList.reliabilityType, packetStructure: { [string]: any }): packetType
	local self = setmetatable({}, packetMetatable)

	self._reliabilityType = reliabilityType

	self._id = 0
	self._unique = getUnique(packetStructure)
	if RunService:IsServer() then
		self._id = serverPacketIDs.assignPacket(self._unique, self)
	elseif RunService:IsClient() then
		self._id = clientPacketIDs.assignPacket(self._unique, self)
	end

	-- structure stuff
	self._order = {}
	for key, value in packetStructure do
		table.insert(self._order, {
			key,
			value,
		})
	end

	table.sort(self._order, function(a, b)
		return a[1] < b[1]
	end)

	self._listeners = {}

	return self
end
