local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local boolean = {
	--[[
		1 = true
		0 = false
		
		Write and read based off a uint8
	]]
	read = function(b: buffer, cursor: number)
		return buffer.readu8(b, cursor) == 1, 1
	end,

	write = bufferWriter.bool,
}

return function(): types.dataTypeInterface<boolean>
	return boolean
end
