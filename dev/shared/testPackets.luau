local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNet = require(ReplicatedStorage.Packages.ByteNet)
--
return ByteNet.defineNamespace("game", function()
	return {
		myPacket = ByteNet.definePacket({
			value = ByteNet.nothing,
			reliabilityType = "reliable",
		}),
	}
end)
