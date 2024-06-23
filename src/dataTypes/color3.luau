local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local uint8NoAlloc = bufferWriter.writeu8NoAlloc
local alloc = bufferWriter.alloc

local color3 = {
	write = function(input: Color3)
		alloc(3)
		uint8NoAlloc(input.R * 255)
		uint8NoAlloc(input.G * 255)
		uint8NoAlloc(input.B * 255)
	end,
	read = function(b: buffer, cursor: number)
		return Color3.fromRGB(buffer.readu8(b, cursor), buffer.readu8(b, cursor + 1), buffer.readu8(b, cursor + 2)), 3
	end,
}

return function(): types.dataTypeInterface<Color3>
	return color3
end
