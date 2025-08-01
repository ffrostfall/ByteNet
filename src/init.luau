local RunService = game:GetService("RunService")

local array = require("@self/data_types/array")
local bool = require("@self/data_types/bool")
local buff = require("@self/data_types/buff")
local cframe = require("@self/data_types/cframe")
local client = require("@self/process/client")
local define_packet = require("@self/packets/define_packet")
local float32 = require("@self/data_types/float32")
local float64 = require("@self/data_types/float64")
local inst = require("@self/data_types/inst")
local int16 = require("@self/data_types/int16")
local int32 = require("@self/data_types/int32")
local int8 = require("@self/data_types/int8")
local map = require("@self/data_types/map")
local nothing = require("@self/data_types/nothing")
local optional = require("@self/data_types/optional")
local server = require("@self/process/server")
local string = require("@self/data_types/string")
local struct = require("@self/data_types/struct")
local uint16 = require("@self/data_types/uint16")
local uint32 = require("@self/data_types/uint32")
local uint8 = require("@self/data_types/uint8")
local unknown = require("@self/data_types/unknown")
local vec2 = require("@self/data_types/vec2")
local vec3 = require("@self/data_types/vec3")

if RunService:IsServer() then
	server.start()
else
	client.init()
end

return table.freeze({
	define_packet = define_packet,

	t = {
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
	},
})
