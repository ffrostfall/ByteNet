local types = require("../types")

local uint16 = {
	write = writeu16,

	read = @native function(b: buffer, cursor: number)
		return buffer.readu16(b, cursor), 2
	end,
}

return @native function(): types.DataType<number>
	return uint16
end
