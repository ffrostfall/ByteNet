local RunService = game:GetService("RunService")

local currentRunContext = require(script.Parent.Parent.storage.currentRunContext)
local packetReporter = require(script.Parent.Parent.logging.packetReporter)
local clientPacketIDs = require(script.Parent.Parent.packets.identifiers.clientPacketIDs)
local serverPacketIDs = require(script.Parent.Parent.packets.identifiers.serverPacketIDs)
local clientProcess = require(script.Parent.Parent.process.client.clientProcess)
local send = require(script.Parent.Parent.process.parsing.send)
local serverProcess = require(script.Parent.Parent.process.server.serverProcess)
local dataTypeList = require(script.Parent.Parent.storage.dataTypeList)
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
		_reporter: packetReporter.packetReporterType,
	},
	packetMetatable
))

function packetPrototype.sendToAll(self: packetType, data)
	local packetBuffer = send(self._id, data, self._order)

	serverProcess.sendEveryone(self._reliabilityType, packetBuffer)
end

function packetPrototype.send(self: packetType, data: { [string]: any }, target: Player?)
	for _, v in self._order do
		local key = v[1]
		local dataType = v[2]

		local value = data[key]
		if value == nil then
			self._reporter:error("missing key " .. key)
			return
		else
			local dataTypeInfo = dataTypeList[dataType]
			if not dataTypeInfo.typecheck(value) then
				self._reporter:raiseTypeError(key, dataType, typeof(value))
				return
			end

			if dataTypeInfo.checkBounds then
				if not dataTypeInfo.checkBounds(value) then
					self._reporter:raiseBoundsError(key, dataTypeInfo.min, dataTypeInfo.max, value)
					return
				end
			end
		end
	end

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

return function(packetStructure: { [string]: any }, reliabilityType: reliabilityTypeList.reliabilityType): packetType
	local self = setmetatable({}, packetMetatable)

	self._reliabilityType = reliabilityType or "reliable"

	self._id = 0
	self._unique = getUnique(packetStructure)
	if currentRunContext == "server" then
		self._id = serverPacketIDs.assignPacket(self._unique, self)
	else
		self._id = clientPacketIDs.assignPacket(self._unique, self)
	end

	self._reporter = packetReporter(self._id)

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
