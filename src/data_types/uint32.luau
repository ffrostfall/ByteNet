local types = require("../types")

local uint32 = {
	write = writeu32,

	read = @native function(b: buffer, cursor: number)
		return buffer.readu32(b, cursor), 4
	end,
}

return @native function(): types.DataType<number>
	return uint32
end
