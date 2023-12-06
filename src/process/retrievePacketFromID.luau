local RunService = game:GetService("RunService")

local clientPacketIDs = require(script.Parent.Parent.packets.identifiers.clientPacketIDs)
local serverPacketIDs = require(script.Parent.Parent.packets.identifiers.serverPacketIDs)

return function(packetID: number)
	if RunService:IsServer() then
		return serverPacketIDs.getPacketFromID(packetID)
	else
		return clientPacketIDs.getPacketFromID(packetID)
	end
end
