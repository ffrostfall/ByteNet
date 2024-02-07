local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNet = require(ReplicatedStorage.Packages.ByteNet)

return {
	a = ByteNet.definePacket({ second = ByteNet.dataTypes.uint8() }),
}
