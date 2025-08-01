local types = require("../types")

local bool_modifier = {
	[1] = true,
	[0] = false,
}
local bool_modifier2 = {
	[true] = 1,
	[false] = 0,
}

local bool_data_type = {
	__T = (nil :: any) :: boolean,

	--[[
		1 = true
		0 = false
		
		Write and read based off a uint8
	]]
	read = @native function(b: buffer, cursor: number)
		return bool_modifier[buffer.readu8(b, cursor)], 1
	end,

	length = 1,

	write = @native function(value)
		buffer.writeu8(bool_modifier2[value])
	end,
}

@native
local function bool(): types.DataType<boolean>
	return bool_data_type
end

return bool
