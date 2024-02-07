local RunService = game:GetService("RunService")

local dataTypes = require(script.Parent.Parent.process.dataTypes)
local types = require(script.Parent.Parent.types)
local clientPacketIDs = require(script.Parent.Parent.packets.identifiers.clientPacketIDs)
local serverPacketIDs = require(script.Parent.Parent.packets.identifiers.serverPacketIDs)
local client = require(script.Parent.Parent.process.client)
local server = require(script.Parent.Parent.process.server)
local getUnique = require(script.Parent.getUnique)

local packetPrototype = {}
local packetMetatable = { __index = packetPrototype }
export type packetType = typeof(setmetatable(
	{} :: {
		id: number,
		reliabilityType: string,

		listeners: { [number]: (data: {}, player: Player) -> () },

		packetFormat: types.packetFormat,
	},
	packetMetatable
))

function packetPrototype.send(self: packetType, data: {})
	if RunService:IsServer() then
		server.sendAllReliable(self.id, self.packetFormat, data)
	else
		client.sendReliable(self.id, self.packetFormat, data)
	end
end

function packetPrototype.listen(self: packetType, callback)
	table.insert(self.listeners, callback)
end

return function(packetStructure: { [string]: any }, reliabilityType: "reliable" | "unreliable"): packetType
	local self = setmetatable({}, packetMetatable)

	-- Basic properties
	self.reliabilityType = reliabilityType or "reliable"
	self._unique = getUnique(packetStructure)
	self.id = if RunService:IsServer()
		then serverPacketIDs.assignPacket(self._unique, self)
		else clientPacketIDs.assignPacket(self._unique, self)
	self.listeners = {}

	-- Format
	self.packetFormat = {}
	for key, dataType in packetStructure do
		local writer, reader, length =
			dataTypes.writers[dataType], dataTypes.readers[dataType], dataTypes.lengths[dataType]

		table.insert(self.packetFormat, {
			reader = reader,
			writer = writer,
			length = length,
			key = key,
		})
	end
	table.sort(self.packetFormat, function(a, b)
		return a.key < b.key
	end)

	return self
end
