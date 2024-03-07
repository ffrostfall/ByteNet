local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local readRefs = require(script.Parent.Parent.process.readRefs)
local types = require(script.Parent.Parent.types)

local reference = bufferWriter.reference
local alloc = bufferWriter.alloc

return function(): types.dataTypeInterface<Instance?>
	return {
		write = function(value)
			alloc(1)
			reference(value)
		end,

		read = function(b: buffer, cursor: number)
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
