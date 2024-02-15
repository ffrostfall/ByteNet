local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local u32 = bufferWriter.u32

local uint32 = {
	write = u32,

	read = function(b: buffer, cursor: number)
		return buffer.readu32(b, cursor), 4
	end,
}

return function(): types.dataTypeInterface<number>
	return uint32
end
