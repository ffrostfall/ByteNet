local types = require("../types")

local int8 = {
	write = writei8,

	read = @native function(b: buffer, cursor: number)
		return buffer.readi8(b, cursor), 1
	end,
}

return @native function(): types.DataType<number>
	return int8
end
