local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local f32 = bufferWriter.f32

local vec2 = {
	--[[
		2 float32s, one for X, one for Y
	]]

	read = function(b: buffer, cursor: number)
		return Vector2.new(buffer.readf32(b, cursor), buffer.readf32(b, cursor + 4)), 8
	end,

	write = function(cursor: number, value: Vector2)
		f32(cursor, value.X)
		f32(cursor + 4, value.Y)

		return 8
	end,
}

return function(): types.dataTypeInterface<Vector2>
	return vec2
end
