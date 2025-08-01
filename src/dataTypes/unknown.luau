local bufferWriter = require("../process/bufferWriter")
local readRefs = require(script.Parent.Parent.process.readRefs)
local types = require("../types")

local writeReference = bufferWriter.writeReference
local alloc = bufferWriter.alloc

return function(): types.dataTypeInterface<unknown>
	return {
		write = function(value: unknown)
			alloc(1)
			writeReference(value)
		end,

		read = function(b: buffer, cursor: number)
			local refs = readRefs.get()

			if not refs then
				return nil, 1
			end

			return refs[buffer.readu8(b, cursor)], 1
		end,
	}
end
