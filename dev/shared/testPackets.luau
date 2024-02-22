local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNet = require(ReplicatedStorage.Packages.ByteNet)
--
return ByteNet.defineNamespace("game", function()
	local myStruct = ByteNet.struct({
		a = ByteNet.uint8,
		b = ByteNet.uint16,
		c = ByteNet.string,
		d = ByteNet.float32,
	})

	return {
		myPacket = ByteNet.definePacket({
			value = ByteNet.array(myStruct),
		}),
	}
end)
