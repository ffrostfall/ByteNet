local RunService = game:GetService("RunService")

local clientProcess = require(script.process.client)
local array = require(script.dataTypes.array)
local bool = require(script.dataTypes.bool)
local buff = require(script.dataTypes.buff)
local cframe = require(script.dataTypes.cframe)
local float32 = require(script.dataTypes.float32)
local float64 = require(script.dataTypes.float64)
local inst = require(script.dataTypes.inst)
local int16 = require(script.dataTypes.int16)
local int32 = require(script.dataTypes.int32)
local int8 = require(script.dataTypes.int8)
local map = require(script.dataTypes.map)
local nothing = require(script.dataTypes.nothing)
local optional = require(script.dataTypes.optional)
local string = require(script.dataTypes.string)
local struct = require(script.dataTypes.struct)
local uint16 = require(script.dataTypes.uint16)
local uint32 = require(script.dataTypes.uint32)
local uint8 = require(script.dataTypes.uint8)
local unknown = require(script.dataTypes.unknown)
local vec2 = require(script.dataTypes.vec2)
local vec3 = require(script.dataTypes.vec3)
local namespace = require(script.namespaces.namespace)
local definePacket = require(script.packets.definePacket)
local serverProcess = require(script.process.server)
local values = require(script.replicated.values)
local types = require(script.types)

values.start()

if RunService:IsServer() then
	serverProcess.start()
else
	clientProcess.start()
end

return (
	table.freeze({
		definePacket = definePacket,
		defineNamespace = namespace,

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
		struct = struct,
		map = map,
		inst = inst(),
		unknown = unknown(),
		nothing = nothing(),
	}) :: any
) :: types.ByteNet
