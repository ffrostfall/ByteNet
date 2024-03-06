local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNet = require(ReplicatedStorage.Packages.ByteNet)
--
return ByteNet.defineNamespace("game", function()
	local myStruct = ByteNet.struct({
		a = ByteNet.inst,
	})

	return {
		myPacket = ByteNet.definePacket({
			value = ByteNet.array(myStruct),
		}),
	}
end)
