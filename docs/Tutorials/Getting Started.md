---
sidebar_position: 1
---

# Getting Started

## Your first Packet
To actually make use of ByteNet, you'll first need to create a packet. Packets require a structure like so:
```lua
local ByteNet = require(path.to.ByteNet)

local myPacket = ByteNet.definePacket({
	textField = ByteNet.dataTypes.string,
})
```
You might've noticed this, but **you don't provide ByteNet a name.** What gives? ByteNet is built around your networking structures being shared. Instead of relying on a name, ByteNet relies on your packet structure. So you'll want to create a ModuleScript under ReplicatedStorage to store your packets, instead of relying on individual scripts. For example:
```lua name="packets.luau"
-- under ReplicatedStorage
local ByteNet = require(path.to.ByteNet)

return {
	myPacket = ByteNet.definePacket("reliable", {
		textField = ByteNet.dataTypes.string,
	})
}
```
Great! Now we have a packet. Luckily, utilizing packets in ByteNet is extremely simple:
```lua
-- On the server...
local ByteNet = require(path.to.ByteNet)
local packets = require(path.to.packets)

packets.myPacket:listen(function(data, player)
	print(`{ player.Name } said {data.textField}`)
end)

-- On the client..
local ByteNet = require(path.to.ByteNet)
local packets = require(path.to.packets)

packets.myPacket:send({
	textField = "Hello, world!"
})
```