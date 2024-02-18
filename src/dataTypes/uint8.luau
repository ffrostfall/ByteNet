local types = require(script.Parent.Parent.types)
local bufferWriter = require(script.Parent.Parent.process.bufferWriter)

local u8 = bufferWriter.u8
local alloc = bufferWriter.alloc

local uint8 = {
	write = function(value: number)
		alloc(1)
		u8(value)
	end,

	read = function(b: buffer, cursor: number)
		return buffer.readu8(b, cursor), 1
	end,
}

return function(): types.dataTypeInterface<number>
	return uint8
end
