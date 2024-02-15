--!native
--!optimize 2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local clientPacketIDs = require(script.Parent.Parent.packets.clientPacketIDs)
local serverPacketIDs = require(script.Parent.Parent.packets.serverPacketIDs)
local client = require(script.Parent.Parent.process.client)
local server = require(script.Parent.Parent.process.server)

local function getUnique(structure: { [string]: any })
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
	},
	packetMetatable
))

function packetPrototype.sendTo(self: packetType, data: {}, player: Player)
	if RunService:IsServer() then
		if self.reliabilityType == "reliable" then
			server.sendPlayerReliable(player, self.id, self.packetFormat, data)
		else
			server.sendPlayerUnreliable(player, self.id, self.packetFormat, data)
		end
	end
end

function packetPrototype.sendToAllExcept(self: packetType, data: {}, except: Player)
	if RunService:IsServer() then
		for _, player in Players:GetPlayers() do
			if player ~= except then
				if self.reliabilityType == "reliable" then
					server.sendPlayerReliable(player, self.id, self.packetFormat, data)
				else
					server.sendPlayerUnreliable(player, self.id, self.packetFormat, data)
				end
			end
		end
	end
end

function packetPrototype.sendToAll(self: packetType, data: {})
	if self.reliabilityType == "reliable" then
		server.sendAllReliable(self.id, self.packetFormat, data)
	else
		server.sendAllUnreliable(self.id, self.packetFormat, data)
	end
end

function packetPrototype.send(self: packetType, data: {})
	if RunService:IsServer() then
		if self.reliabilityType == "reliable" then
			server.sendAllReliable(self.id, self.packetFormat, data)
		else
			server.sendAllUnreliable(self.id, self.packetFormat, data)
		end
	else
		client.sendReliable(self.id, self.packetFormat, data)
	end
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
	self.id = if RunService:IsServer()
		then serverPacketIDs.assignPacket(self._unique, self)
		else clientPacketIDs.assignPacket(self._unique, self)
	self.listeners = {}

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
