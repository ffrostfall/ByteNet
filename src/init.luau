local RunService = game:GetService("RunService")

local clientPacketIDs = require(script.packets.clientPacketIDs)
local serverPacketIDs = require(script.packets.serverPacketIDs)
local packet = require(script.packets.packet)
local clientProcess = require(script.process.client)
local array = require(script.dataTypes.array)
local bool = require(script.dataTypes.bool)
local buff = require(script.dataTypes.buff)
local cframe = require(script.dataTypes.cframe)
local float32 = require(script.dataTypes.float32)
local float64 = require(script.dataTypes.float64)
local int16 = require(script.dataTypes.int16)
local int32 = require(script.dataTypes.int32)
local int8 = require(script.dataTypes.int8)
local map = require(script.dataTypes.map)
local optional = require(script.dataTypes.optional)
local string = require(script.dataTypes.string)
local uint16 = require(script.dataTypes.uint16)
local uint32 = require(script.dataTypes.uint32)
local uint8 = require(script.dataTypes.uint8)
local vec2 = require(script.dataTypes.vec2)
local vec3 = require(script.dataTypes.vec3)
local serverProcess = require(script.process.server)
local types = require(script.types)

if RunService:IsServer() then
	serverProcess.start()
	serverPacketIDs.start()
else
	clientProcess.start()
	clientPacketIDs.start()
end

return (
	table.freeze({
		definePacket = packet,

		array = array,
		bool = bool(),
		optional = optional,
		uint8 = uint8(),
		uint16 = uint16(),
		uint32 = uint32(),
		int8 = int8(),
		int16 = int16(),
		int32 = int32(),
		float32 = float32(),
		float64 = float64(),
		cframe = cframe(),
		string = string(),
		vec2 = vec2(),
		vec3 = vec3(),
		buff = buff(),
		map = map,
	}) :: any
) :: types.ByteNet
