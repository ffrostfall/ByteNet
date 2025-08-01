local types = require("../types")

local int32 = {
	write = writei32,

	read = @native function(b: buffer, cursor: number)
		return buffer.readi32(b, cursor), 4
	end,
}

return @native function(): types.DataType<number>
	return int32
end
