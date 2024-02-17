--!strict
--!native
--!optimize 2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local clientPacketIDs = require(script.Parent.Parent.packets.clientPacketIDs)
local serverPacketIDs = require(script.Parent.Parent.packets.serverPacketIDs)
local client = require(script.Parent.Parent.process.client)
local server = require(script.Parent.Parent.process.server)

local moduleRunContext: "server" | "client" = if RunService:IsServer() then "server" else "client"
local function getUnique(structure: { [string]: any }): string
	local unique = ""

	for key in structure do
		unique ..= key
	end

	return unique
end

local packetPrototype = {}
local packetMetatable = { __index = packetPrototype }
export type packetType = typeof(setmetatable(
	{} :: {
		id: number,
		reliabilityType: string,
		listeners: { [number]: (data: {}, player: Player) -> () },
		packetFormat: types.packetFormat,

		_processSendFunction: (player: Player, id: number, format: types.packetFormat, data: {}) -> (),
		_processSendAllFunction: (id: number, format: types.packetFormat, data: {}) -> (),
		_clientSendFunction: (id: number, format: types.packetFormat, data: {}) -> (),
	},
	packetMetatable
))

function packetPrototype.sendTo(self: packetType, data: {}, player: Player)
	assert(moduleRunContext == "server", "The 'sendTo' method can only be called on the server")

	self._processSendFunction(player, self.id, self.packetFormat, data)
end

function packetPrototype.sendToAllExcept(self: packetType, data: {}, except: Player)
	assert(moduleRunContext == "server", "The 'sendToAllExcept' method can only be called on the server")

	local id, format = self.id, self.packetFormat
	for _, player: Player in Players:GetPlayers() do
		if player ~= except then
			self._processSendFunction(player, id, format, data)
		end
	end
end

function packetPrototype.sendToAll(self: packetType, data: {})
	assert(moduleRunContext == "server", "The 'sendToAll' method can only be called on the server")

	self._processSendAllFunction(self.id, self.packetFormat, data)
end

function packetPrototype.send(self: packetType, data: {})
	assert(moduleRunContext == "client", "The 'send' method can only be called on the client")

	self._clientSendFunction(self.id, self.packetFormat, data)
end

function packetPrototype.listen(self: packetType, callback)
	table.insert(self.listeners, callback)
end

type packetProps = {
	structure: { [string]: types.dataTypeInterface<any> },
	reliabilityType: "reliable" | "unreliable",
	callbackBehavior: {
		spawnThread: boolean,
		allowMultiple: boolean,
	},
}
return function(props: packetProps): packetType
	local self = setmetatable({}, packetMetatable)

	-- Basic properties: reliability type, "unique" which is used to get the packet ID, and set up listeners
	self.reliabilityType = props.reliabilityType or "reliable"
	self._unique = getUnique(props.structure)
	self.id = if moduleRunContext == "server"
		then serverPacketIDs.assignPacket(self._unique, self)
		else clientPacketIDs.assignPacket(self._unique, self)
	self.listeners = {}

	if moduleRunContext == "server" then
		self._processSendFunction = if self.reliabilityType == "reliable"
			then server.sendPlayerReliable
			else server.sendPlayerUnreliable

		self._processSendAllFunction = if self.reliabilityType == "reliable"
			then server.sendAllReliable
			else server.sendAllUnreliable
	elseif moduleRunContext == "client" then
		self._clientSendFunction = if self.reliabilityType == "reliable"
			then client.sendReliable
			else client.sendUnreliable
	end

	self.packetFormat = {}
	for key, dataType in props.structure do
		-- Fetch all relevant data from the structure (read, write, key), and then insert it into the packet format
		local value: { [number]: types.packetFormatElement } = {
			dataType.read,
			dataType.write,
			key,
		}

		table.insert(self.packetFormat, value)
	end

	-- Sort the format so that way it's in a static order shared across both client and server
	table.sort(self.packetFormat, function(a, b)
		local keyA = a[3]
		local keyB = b[3]

		return keyA > keyB
	end)

	return self
end
