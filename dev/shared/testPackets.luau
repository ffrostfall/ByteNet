local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNet = require(ReplicatedStorage.Packages.ByteNet)

return {
	a = ByteNet.definePacket({
		structure = {
			a = ByteNet.dataTypes.bool(),
			b = ByteNet.dataTypes.array(ByteNet.dataTypes.bool()),
			c = ByteNet.dataTypes.array(ByteNet.dataTypes.array(ByteNet.dataTypes.bool())),
			d = ByteNet.dataTypes.optional(ByteNet.dataTypes.bool()),
			e = ByteNet.dataTypes.optional(
				ByteNet.dataTypes.map(ByteNet.dataTypes.uint16(), ByteNet.dataTypes.uint8())
			),
			f = ByteNet.dataTypes.optional(ByteNet.dataTypes.map(ByteNet.dataTypes.vec3(), ByteNet.dataTypes.uint16())),
			chained = ByteNet.dataTypes.optional(
				ByteNet.dataTypes.optional(ByteNet.dataTypes.optional(ByteNet.dataTypes.string()))
			),
		},
	}),
}
