local ReplicatedStorage = game:GetService("ReplicatedStorage")

local wallyInstanceManager = require(ReplicatedStorage.Packages.wallyInstanceManager)

local packetStorage = nil
local packetMap = {}

local clientPacketIDs = {}

function clientPacketIDs.start()
	packetStorage = wallyInstanceManager.get(script.Parent.Parent.Parent, "packetStorage") :: Folder

	if not packetStorage then
		packetStorage = wallyInstanceManager.waitForInstance(script.Parent.Parent.Parent, "packetStorage", 3) :: Folder
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
