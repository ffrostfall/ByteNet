local RunService = game:GetService("RunService")

local clientPacketIDs = require(script.Parent.Parent.packets.identifiers.clientPacketIDs)
local serverPacketIDs = require(script.Parent.Parent.packets.identifiers.serverPacketIDs)
local clientProcess = require(script.Parent.Parent.process.client.clientProcess)
local serverProcess = require(script.Parent.Parent.process.server.serverProcess)
local reliabilityTypeList = require(script.Parent.Parent.storage.reliabilityTypes.reliabilityTypeList)
local getUnique = require(script.Parent.getUnique)

local packetPrototype = {}
local packetMetatable = { __index = packetPrototype }
export type packetType = typeof(setmetatable(
	{} :: {
		_id: number,
		--_unique: string,
		_reliabilityType: reliabilityTypeList.reliabilityType,

		--_size: number,
	},
	packetMetatable
))

function packetPrototype.sendToAll(self: packetType, _)
	local packetBuffer = buffer.create(1) -- convertToBytes(self._sortedStructure, data, self._id, self._size)

	serverProcess.sendEveryone(self._reliabilityType, packetBuffer)
end

function packetPrototype.send(self: packetType, _, target: Player?)
	local packetBuffer = buffer.create(1) -- convertToBytes(self._sortedStructure, data, self._id, self._size)

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
	if RunService:IsServer() then
		serverProcess.listen(self._id, callback)
	else
		clientProcess.listen(self._id, callback)
	end
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
		local num = 0
		for i = 1, string.len(key) do
			num += string.byte(key, i, i)
		end
		table.insert(self._order, {
			key,
			value,
		})
	end

	table.sort(self._order, function(a, b)
		return a[1] < b[1]
	end)

	return self
end
