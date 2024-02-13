local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local f32 = bufferWriter.f32

local vec3 = {
	--[[
		3 floats, 12 bytes
	]]
	read = function(b: buffer, cursor: number)
		return Vector3.new(buffer.readf32(b, cursor), buffer.readf32(b, cursor + 4), buffer.readf32(b, cursor + 8)), 12
	end,

	write = function(cursor: number, value: Vector3)
		f32(cursor, value.X)
		f32(cursor + 4, value.Y)
		f32(cursor + 8, value.Z)

		return 12
	end,
}

return function(): types.dataTypeInterface<Vector3>
	return vec3
end
