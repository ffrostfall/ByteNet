local read_refs = require("../process/readRefs")
local types = require("../types")

@native
local function unknown(): types.DataType<unknown>
	return {
		write = @native function(value: unknown)
			alloc(1)
			writeReference(value)
		end,

		read = @native function(b: buffer, cursor: number)
			local refs = read_refs.get()

			if not refs then
				return nil, 1
			end

			return refs[buffer.readu8(b, cursor)], 1
		end,
	}
end

return unknown
