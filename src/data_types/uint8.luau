local types = require("../types")

local uint8 = {
	write = writeu8,

	read = @native function(b: buffer, cursor: number)
		return buffer.readu8(b, cursor), 1
	end,
}

return @native function(): types.DataType<number>
	return uint8
end
