local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local f32NoAlloc = bufferWriter.f32NoAlloc
local alloc = bufferWriter.alloc

local vec3 = {
	--[[
		3 floats, 12 bytes
	]]
	read = function(b: buffer, cursor: number)
		return Vector3.new(buffer.readf32(b, cursor), buffer.readf32(b, cursor + 4), buffer.readf32(b, cursor + 8)), 12
	end,

	write = function(value: Vector3)
		alloc(12)
		f32NoAlloc(value.X)
		f32NoAlloc(value.Y)
		f32NoAlloc(value.Z)
	end,
}

return function(): types.dataTypeInterface<Vector3>
	return vec3
end
