local ReplicatedStorage = game:GetService("ReplicatedStorage")

local wallyInstanceManager = require(ReplicatedStorage.Packages.wallyInstanceManager)

local packetMap = {}
local packetStorage = Instance.new("Folder")
local idCounter = 0

local serverPacketIDs = {}

function serverPacketIDs.start()
	packetStorage.Name = "packetStorage"
	wallyInstanceManager.add(script.Parent.Parent.Parent, packetStorage)
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
