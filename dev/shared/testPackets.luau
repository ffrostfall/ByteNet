local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNet = require(ReplicatedStorage.Packages.ByteNet)

return {
	a = ByteNet.createPacket("reliable", { first = ByteNet.dataTypes.string, second = ByteNet.dataTypes.uint8 }),
}
