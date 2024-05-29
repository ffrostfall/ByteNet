local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local writef32NoAlloc = bufferWriter.writef32NoAlloc
local alloc = bufferWriter.alloc

local cframe = {
	read = function(b: buffer, cursor: number)
		local x = buffer.readf32(b, cursor)
		local y = buffer.readf32(b, cursor + 4)
		local z = buffer.readf32(b, cursor + 8)
		local rx = buffer.readf32(b, cursor + 12)
		local ry = buffer.readf32(b, cursor + 16)
		local rz = buffer.readf32(b, cursor + 20)
		
		return CFrame.new(x, y, z) * CFrame.Angles(rx, ry, rz), 24
	end,
	write = function(value: CFrame)
		local x, y, z = value.X, value.Y, value.Z
		local rx, ry, rz = value:ToEulerAnglesXYZ()
		
		-- Math done, write it now
		alloc(24)
		writef32NoAlloc(x)
		writef32NoAlloc(y)
		writef32NoAlloc(z)
		writef32NoAlloc(rx)
		writef32NoAlloc(ry)
		writef32NoAlloc(rz)
	end,
}

return function(): types.dataTypeInterface<CFrame>
	return cframe
end