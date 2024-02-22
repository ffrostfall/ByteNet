--[[
	Exists solely to get a packet instance from an ID in the reader file
]]
local dict = {}

local packetIDs = {}

function packetIDs.set(id: number, packet: any)
	dict[id] = packet
end

function packetIDs.get(id: number)
	return dict[id]
end

function packetIDs.total()
	return dict
end

return packetIDs
