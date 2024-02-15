local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNet = require(ReplicatedStorage.Packages.ByteNet)

return {
	a = ByteNet.definePacket({
		structure = {
			a = ByteNet.bool,
			b = ByteNet.array(ByteNet.bool),
			c = ByteNet.array(ByteNet.array(ByteNet.bool)),
			d = ByteNet.optional(ByteNet.bool),
			e = ByteNet.optional(ByteNet.map(ByteNet.uint16, ByteNet.uint8)),
			f = ByteNet.optional(ByteNet.map(ByteNet.vec3, ByteNet.uint16)),
			chained = ByteNet.optional(ByteNet.optional(ByteNet.optional(ByteNet.string))),
		},
	}),
}
