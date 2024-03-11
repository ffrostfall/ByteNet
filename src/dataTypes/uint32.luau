local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local writeu32 = bufferWriter.writeu32

local uint32 = {
	write = writeu32,

	read = function(b: buffer, cursor: number)
		return buffer.readu32(b, cursor), 4
	end,
}

return function(): types.dataTypeInterface<number>
	return uint32
end
