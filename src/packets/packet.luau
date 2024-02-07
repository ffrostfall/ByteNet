local currentRunContext = require(script.Parent.Parent.storage.currentRunContext)
local clientPacketIDs = require(script.Parent.Parent.packets.identifiers.clientPacketIDs)
local serverPacketIDs = require(script.Parent.Parent.packets.identifiers.serverPacketIDs)
local reliabilityTypeList = require(script.Parent.Parent.storage.reliabilityTypeList)
local getUnique = require(script.Parent.getUnique)

local packetPrototype = {}
local packetMetatable = { __index = packetPrototype }
export type packetType = typeof(setmetatable(
	{} :: {
		_id: number,
		_reliabilityType: reliabilityTypeList.reliabilityType,

		_listeners: { [number]: (data: {}, player: Player) -> () },
	},
	packetMetatable
))

return function(packetStructure: { [string]: any }, reliabilityType: reliabilityTypeList.reliabilityType): packetType
	local self = setmetatable({}, packetMetatable)

	self._reliabilityType = reliabilityType or "reliable"
	self._unique = getUnique(packetStructure)
	self._id = if currentRunContext == "server"
		then serverPacketIDs.assignPacket(self._unique, self)
		else clientPacketIDs.assignPacket(self._unique, self)
	self._listeners = {}

	return self
end
