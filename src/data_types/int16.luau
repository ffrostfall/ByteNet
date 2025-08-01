local types = require("../types")

local int16 = {
	write = writei16,

	read = @native function(b: buffer, cursor: number)
		return buffer.readi16(b, cursor), 2
	end,
}

return @native function(): types.DataType<number>
	return int16
end
