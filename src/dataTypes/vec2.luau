local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local f32NoAlloc = bufferWriter.f32NoAlloc
local alloc = bufferWriter.alloc

local vec2 = {
	--[[
		2 float32s, one for X, one for Y
	]]

	read = function(b: buffer, cursor: number)
		return Vector2.new(buffer.readf32(b, cursor), buffer.readf32(b, cursor + 4)), 8
	end,

	write = function(value: Vector2)
		alloc(8)
		f32NoAlloc(value.X)
		f32NoAlloc(value.Y)
	end,
}

return function(): types.dataTypeInterface<Vector2>
	return vec2
end
