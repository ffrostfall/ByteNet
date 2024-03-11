local types = require(script.Parent.Parent.types)
local bufferWriter = require(script.Parent.Parent.process.bufferWriter)

local writeu8 = bufferWriter.writeu8

local uint8 = {
	write = writeu8,

	read = function(b: buffer, cursor: number)
		return buffer.readu8(b, cursor), 1
	end,
}

return function(): types.dataTypeInterface<number>
	return uint8
end
