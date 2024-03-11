local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local writei16 = bufferWriter.writei16

local int16 = {
	write = writei16,

	read = function(b: buffer, cursor: number)
		return buffer.readi16(b, cursor), 2
	end,
}

return function(): types.dataTypeInterface<number>
	return int16
end
