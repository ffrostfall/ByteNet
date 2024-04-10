local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNet = require(ReplicatedStorage.Packages.ByteNet)

local myTree: any = ByteNet.define({
	test = {
		value = ByteNet.array(ByteNet.bool),
		reliabilityType = "reliable",
	},
})

ByteNet.complete()

return myTree
