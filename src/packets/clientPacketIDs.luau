local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packetStorage = nil
local packetMap = {}

local clientPacketIDs = {}

function clientPacketIDs.start()
	packetStorage = ReplicatedStorage:FindFirstChild("ByteNetPacketStorage")

	if not packetStorage then
		packetStorage = ReplicatedStorage:WaitForChild("ByteNetPacketStorage")
	end
end

function clientPacketIDs.getPacketFromID(packetID: number)
	return packetMap[packetID]
end

function clientPacketIDs.assignPacket(unique: string, packet)
	local id = packetStorage:GetAttribute(unique)

	packetMap[id] = packet

	return id
end

return clientPacketIDs
