local types = require("../types")

local nothing = {
	write = @native function() end,

	read = @native function()
		return nil, 0
	end,
}

return @native function(): types.DataType<nil>
	return nothing
end
