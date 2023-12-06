local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNet = require(ReplicatedStorage.Packages.ByteNet)

return {
	a = ByteNet.createPacket("reliable"),
	b = ByteNet.createPacket("unreliable"),
	c = ByteNet.createPacket("reliable"),
	d = ByteNet.createPacket("unreliable"),
}
