--!native

--[[
	Exists solely to get a packet instance from an ID in the reader file.
	Might be able to be done in a better way?
]]
local dict = {}

local packetIDs = {}

function packetIDs.set(id: number, packet: any)
	dict[id] = packet
end

-- Use this instead of a get function for performance.
function packetIDs.ref()
	return dict
end

return packetIDs
