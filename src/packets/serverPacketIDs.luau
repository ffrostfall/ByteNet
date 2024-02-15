local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packetMap = {}
local packetStorage = nil
local idCounter = 0

local serverPacketIDs = {}

function serverPacketIDs.start()
	packetStorage = Instance.new("Folder")
	packetStorage.Name = "ByteNetPacketStorage"
	packetStorage.Parent = ReplicatedStorage
end

function serverPacketIDs.assignPacket(packetContents: string, packet)
	idCounter += 1

	packetStorage:SetAttribute(packetContents, idCounter)
	packetMap[idCounter] = packet

	return idCounter
end

function serverPacketIDs.getPacketFromID(packetID: number)
	return packetMap[packetID]
end

return serverPacketIDs
