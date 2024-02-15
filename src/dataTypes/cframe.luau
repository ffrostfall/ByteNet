local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local f32 = bufferWriter.f32

-- thanks jack :p
local cframe = {
	read = function(b: buffer, cursor: number)
		local x = buffer.readf32(b, cursor)
		local y = buffer.readf32(b, cursor + 4)
		local z = buffer.readf32(b, cursor + 8)
		local rx = buffer.readf32(b, cursor + 12)
		local ry = buffer.readf32(b, cursor + 16)
		local rz = buffer.readf32(b, cursor + 20)

		-- Re-construct the CFrame from the axis-angle representation
		local axis = Vector3.new(rx, ry, rz)
		local angle = axis.Magnitude

		return CFrame.fromAxisAngle(axis, angle) + Vector3.new(x, y, z), 24
	end,
	write = function(cursor: number, value: CFrame)
		-- Convert the CFrame to an axis-angle representation
		local x, y, z = value.X, value.Y, value.Z

		local axis, angle = value:ToAxisAngle()
		local rx, ry, rz = axis.X, axis.Y, axis.Z
		axis = axis * angle

		-- Math done, write it now
		f32(cursor, x)
		f32(cursor + 4, y)
		f32(cursor + 8, z)
		f32(cursor + 12, rx)
		f32(cursor + 16, ry)
		f32(cursor + 20, rz)

		return 24
	end,
}

return function(): types.dataTypeInterface<CFrame>
	return cframe
end
