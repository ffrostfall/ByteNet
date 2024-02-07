local RunService = game:GetService("RunService")

local clientPacketIDs = require(script.packets.identifiers.clientPacketIDs)
local serverPacketIDs = require(script.packets.identifiers.serverPacketIDs)
local clientProcess = require(script.process.client)
local dataTypes = require(script.process.dataTypes)
local serverProcess = require(script.process.server)
local types = require(script.types)

if RunService:IsServer() then
	serverProcess.start()
	serverPacketIDs.start()
else
	clientProcess.start()
	clientPacketIDs.start()
end

--[=[
	@class ByteNet
	
	The root interface for ByteNet.
]=]

--[=[
	@function definePacket
	@within ByteNet
	
	@param reliabilityType "reliable" | "unreliable"
	@param structure { [string]: DataType }
	
	@return Packet
]=]

--[=[
	@type DataType [arbitrary]
	@within ByteNet
	Declares the type of data of a field.
]=]

--[=[
	@interface dataTypes
	@within ByteNet
	.string DataType
	.uint8 DataType
	.int8 DataType
	.uint16 DataType
	.int16 DataType
	.uint32 DataType
	.int32 DataType
	.f32 DataType
	.f64 DataType
	.v3 DataType
	.bool DataType
]=]

--[=[
	@class Packet
	
	The class returned by `ByteNet.definePacket`. Packets are utilized to send data between the server and client.
]=]

--[=[
	@method sendToAll
	@within Packet
	@server
	
	@param data { [string]: any }
	
	Sends data to all players.
]=]

--[=[
	@method send
	@within Packet
	
	@param data { [string]: any }
	@param target Player?
	
	If on the client, sends data to the server. If on the server, sends data to a specific player.
]=]

--[=[
	@method listen
	@within Packet
	
	@param callback (data: {[string]: any}, player: Player?) -> ()
	
	When the packet is received, the callback is called with the data, and if on the server, the player who sent the packet.
]=]

local dataTypeTable = setmetatable({}, {
	__index = function(_, index)
		return function()
			if not dataTypes.writers[index] then
				error("Invalid data type: " .. index)
			end

			return index
		end
	end,
})

return (
	table.freeze({
		definePacket = require(script.packets.packet),

		dataTypes = dataTypeTable,
	}) :: any
) :: types.ByteNet
