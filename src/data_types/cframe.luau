local types = require("../types")

local cframe: types.DataType<CFrame> = {
	__T = ... :: CFrame,

	read = @native function(b: buffer, cursor: number)
		local x = buffer.readf32(b, cursor)
		local y = buffer.readf32(b, cursor + 4)
		local z = buffer.readf32(b, cursor + 8)
		local rx = buffer.readf32(b, cursor + 12)
		local ry = buffer.readf32(b, cursor + 16)
		local rz = buffer.readf32(b, cursor + 20)

		return CFrame.new(x, y, z) * CFrame.Angles(rx, ry, rz), 24
	end,
	write = @native function(value: CFrame)
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

return @native function(): types.DataType<CFrame>
	return cframe
end
