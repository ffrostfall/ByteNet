local readers = {
	uint8 = buffer.readu8,
	uint16 = buffer.readu16,
	uint32 = buffer.readu32,

	int8 = buffer.readi8,
	int16 = buffer.readi16,
	int32 = buffer.readi32,

	float32 = buffer.readf32,
	float64 = buffer.readf64,

	opt_uint8 = function(b: buffer, cursor: number): number?
		local exists = buffer.readu8(b, cursor)
		if exists then
			return buffer.readu8(b, cursor + 1)
		else
			return nil
		end
	end,
	opt_uint16 = function(b: buffer, cursor: number): number?
		local exists = buffer.readu8(b, cursor)
		if exists then
			return buffer.readu16(b, cursor + 1)
		else
			return nil
		end
	end,
	opt_uint32 = function(b: buffer, cursor: number): number?
		local exists = buffer.readu8(b, cursor)
		if exists then
			return buffer.readu32(b, cursor + 1)
		else
			return nil
		end
	end,

	opt_int8 = function(b: buffer, cursor: number): number?
		local exists = buffer.readu8(b, cursor)
		if exists then
			return buffer.readi8(b, cursor + 1)
		else
			return nil
		end
	end,
	opt_int16 = function(b: buffer, cursor: number): number?
		local exists = buffer.readu8(b, cursor)
		if exists then
			return buffer.readi16(b, cursor + 1)
		else
			return nil
		end
	end,
	opt_int32 = function(b: buffer, cursor: number): number?
		local exists = buffer.readu8(b, cursor)
		if exists then
			return buffer.readi32(b, cursor + 1)
		else
			return nil
		end
	end,

	opt_float32 = function(b: buffer, cursor: number): number?
		local exists = buffer.readu8(b, cursor)
		if exists then
			return buffer.readf32(b, cursor + 1)
		else
			return nil
		end
	end,
	opt_float64 = function(b: buffer, cursor: number): number?
		local exists = buffer.readu8(b, cursor)
		if exists then
			return buffer.readf64(b, cursor + 1)
		else
			return nil
		end
	end,

	bool = function(b: buffer, cursor: number): boolean
		return buffer.readu8(b, cursor) == 1
	end,
	opt_bool = function(b: buffer, cursor: number): boolean?
		local exists = buffer.readu8(b, cursor)
		if exists then
			return buffer.readu8(b, cursor + 1) == 1
		else
			return nil
		end
	end,

	buff = function(b: buffer, cursor: number): buffer
		local len = buffer.readu32(b, cursor)
		local newBuff = buffer.create(len)

		buffer.copy(newBuff, 0, b, cursor + 4, len)

		return newBuff
	end,
	opt_buff = function(b: buffer, cursor: number): buffer?
		local exists = buffer.readu8(b, cursor)
		if exists then
			local len = buffer.readu32(b, cursor + 1)
			local newBuff = buffer.create(len)

			buffer.copy(newBuff, 0, b, cursor + 5, len)

			return newBuff
		else
			return nil
		end
	end,

	str = function(b: buffer, cursor: number): string
		local len = buffer.readu16(b, cursor)
		return buffer.readstring(b, cursor + 2, len)
	end,
	opt_str = function(b: buffer, cursor: number): string?
		local exists = buffer.readu8(b, cursor)
		if exists then
			local len = buffer.readu16(b, cursor + 1)
			return buffer.readstring(b, cursor + 3, len)
		else
			return nil
		end
	end,

	vec3 = function(b: buffer, cursor: number): Vector3
		local x = buffer.readf32(b, cursor)
		local y = buffer.readf32(b, cursor + 4)
		local z = buffer.readf32(b, cursor + 8)

		return Vector3.new(x, y, z)
	end,
	opt_vec3 = function(b: buffer, cursor: number): Vector3?
		local exists = buffer.readu8(b, cursor)
		if exists then
			local x = buffer.readf32(b, cursor + 1)
			local y = buffer.readf32(b, cursor + 5)
			local z = buffer.readf32(b, cursor + 9)

			return Vector3.new(x, y, z)
		else
			return nil
		end
	end,
}
local writers = {
	uint8 = buffer.writeu8,
	uint16 = buffer.writeu16,
	uint32 = buffer.writeu32,

	int8 = buffer.writei8,
	int16 = buffer.writei16,
	int32 = buffer.writei32,

	float32 = buffer.writef32,
	float64 = buffer.writef64,

	opt_uint8 = function(b: buffer, cursor: number, value: number?)
		if value then
			buffer.writeu8(b, cursor, 1)
			buffer.writeu8(b, cursor + 1, value)
		else
			buffer.writeu8(b, cursor, 0)
		end
	end,
	opt_uint16 = function(b: buffer, cursor: number, value: number?)
		if value then
			buffer.writeu8(b, cursor, 1)
			buffer.writeu16(b, cursor + 1, value)
		else
			buffer.writeu8(b, cursor, 0)
		end
	end,
	opt_uint32 = function(b: buffer, cursor: number, value: number?)
		if value then
			buffer.writeu8(b, cursor, 1)
			buffer.writeu32(b, cursor + 1, value)
		else
			buffer.writeu8(b, cursor, 0)
		end
	end,

	opt_int8 = function(b: buffer, cursor: number, value: number?)
		if value then
			buffer.writeu8(b, cursor, 1)
			buffer.writei8(b, cursor + 1, value)
		else
			buffer.writeu8(b, cursor, 0)
		end
	end,
	opt_int16 = function(b: buffer, cursor: number, value: number?)
		if value then
			buffer.writeu8(b, cursor, 1)
			buffer.writei16(b, cursor + 1, value)
		else
			buffer.writeu8(b, cursor, 0)
		end
	end,
	opt_int32 = function(b: buffer, cursor: number, value: number?)
		if value then
			buffer.writeu8(b, cursor, 1)
			buffer.writei32(b, cursor + 1, value)
		else
			buffer.writeu8(b, cursor, 0)
		end
	end,

	opt_float32 = function(b: buffer, cursor: number, value: number?)
		if value then
			buffer.writeu8(b, cursor, 1)
			buffer.writef32(b, cursor + 1, value)
		else
			buffer.writeu8(b, cursor, 0)
		end
	end,
	opt_float64 = function(b: buffer, cursor: number, value: number?)
		if value then
			buffer.writeu8(b, cursor, 1)
			buffer.writef64(b, cursor + 1, value)
		else
			buffer.writeu8(b, cursor, 0)
		end
	end,

	bool = function(b: buffer, cursor: number, value: boolean)
		buffer.writeu8(b, cursor, if value then 1 else 0)
	end,
	opt_bool = function(b: buffer, cursor: number, value: boolean?)
		if value then
			buffer.writeu8(b, cursor, 1)
			buffer.writeu8(b, cursor + 1, if value then 1 else 0)
		else
			buffer.writeu8(b, cursor, 0)
		end
	end,

	buff = function(b: buffer, cursor: number, value: buffer)
		buffer.writeu32(b, cursor, buffer.len(value))
		buffer.copy(b, cursor + 4, value)
	end,
	opt_buff = function(b: buffer, cursor: number, value: buffer?)
		if value then
			buffer.writeu8(b, cursor, 1)
			buffer.writeu32(b, cursor + 1, buffer.len(value))
			buffer.copy(b, cursor + 5, value)
		else
			buffer.writeu8(b, cursor, 0)
		end
	end,

	str = function(b: buffer, cursor: number, value: string)
		buffer.writeu16(b, cursor, #value)
		buffer.writestring(b, cursor + 2, value)
	end,
	opt_str = function(b: buffer, cursor: number, value: string?)
		if value then
			buffer.writeu8(b, cursor, 1)
			buffer.writeu16(b, cursor + 1, #value)
			buffer.writestring(b, cursor + 3, value)
		else
			buffer.writeu8(b, cursor, 0)
		end
	end,

	vec3 = function(b: buffer, cursor: number, value: Vector3)
		buffer.writef32(b, cursor, value.X)
		buffer.writef32(b, cursor + 4, value.Y)
		buffer.writef32(b, cursor + 8, value.Z)
	end,
	opt_vec3 = function(b: buffer, cursor: number, value: Vector3?)
		if value then
			buffer.writeu8(b, cursor, 1)
			buffer.writef32(b, cursor + 1, value.X)
			buffer.writef32(b, cursor + 5, value.Y)
			buffer.writef32(b, cursor + 9, value.Z)
		else
			buffer.writeu8(b, cursor, 0)
		end
	end,
}

local lengths = {
	uint8 = function()
		return 1
	end,
	uint16 = function()
		return 2
	end,
	uint32 = function()
		return 4
	end,

	int8 = function()
		return 1
	end,
	int16 = function()
		return 2
	end,
	int32 = function()
		return 4
	end,

	float32 = function()
		return 4
	end,
	float64 = function()
		return 8
	end,

	opt_uint8 = function(num: number?): number
		return if num then 2 else 1
	end,
	opt_uint16 = function(num: number?): number
		return if num then 3 else 1
	end,
	opt_uint32 = function(num: number?): number
		return if num then 5 else 1
	end,

	opt_int8 = function(num: number?): number
		return if num then 2 else 1
	end,
	opt_int16 = function(num: number?): number
		return if num then 3 else 1
	end,
	opt_int32 = function(num: number?): number
		return if num then 5 else 1
	end,

	opt_float32 = function(num: number?): number
		return if num then 5 else 1
	end,
	opt_float64 = function(num: number?): number
		return if num then 9 else 1
	end,

	bool = function()
		return 1
	end,
	opt_bool = function(bool: boolean?): number
		return if bool then 2 else 1
	end,

	buff = function(buff: buffer): number
		return buffer.len(buff) + 4
	end,
	opt_buff = function(buff: buffer?): number
		return if buff then buffer.len(buff) + 5 else 1
	end,

	str = function(str: string): number
		return #str + 2
	end,
	opt_str = function(str: string?): number
		return if str then #str + 3 else 1
	end,

	vec3 = function()
		return 12
	end,
	opt_vec3 = function(vec: Vector3?): number
		return if vec then 13 else 1
	end,
}

return {
	readers = readers,
	writers = writers,
	lengths = lengths,
}
