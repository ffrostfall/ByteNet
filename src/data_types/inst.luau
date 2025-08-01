local types = require("../types")

return @native function(): types.DataType<Instance?>
	return {
		write = @native function(value)
			alloc(1)
			writeReference(value)
		end,

		read = @native function(b: buffer, cursor: number)
			local refs = readRefs.get()

			if not refs then
				return nil, 1
			end

			local ref = refs[buffer.readu8(b, cursor)]

			if typeof(ref) == "Instance" then
				return ref, 1
			else
				return nil, 1
			end
		end,
	}
end
