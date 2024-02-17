local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local u32 = bufferWriter.u32
local alloc = bufferWriter.alloc

local uint32 = {
	write = function(value: number)
		alloc(4)
		u32(value)
	end,

	read = function(b: buffer, cursor: number)
		return buffer.readu32(b, cursor), 4
	end,
}

return function(): types.dataTypeInterface<number>
	return uint32
end
