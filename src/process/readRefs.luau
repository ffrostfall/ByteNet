--!native
local current

local readRefs = {}

function readRefs.set(refTable)
	current = refTable
end

function readRefs.get()
	return current
end

return readRefs
