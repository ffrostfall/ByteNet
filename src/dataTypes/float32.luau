local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local f32 = bufferWriter.f32

local float32 = {
	write = f32,

	read = function(b: buffer, cursor: number)
		return buffer.readf32(b, cursor), 4
	end,
}

return function(): types.dataTypeInterface<number>
	return float32
end
