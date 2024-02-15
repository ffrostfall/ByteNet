<div class="docs">

<h1>Defining a packet</h1>

</div>

## what even is a packet in ByteNet anyway?
Packets are the structured dictionaries you use to define the "format" your data is going to be sent in. These are named packets as you 'send' packets through network, and packets have their contents usually formatted in a specific way because, well they have to be. 

ByteNet's purpose as a library is to provide a way to structure your data, and send that structure in a hyper-optimized way.

---

## Okay, where do I start?
I highly recommended storing all of your packets in a single, shared module, and then using a dictionary to access the individual packets. Not only does this make using ByteNet a breeze, it also gives you a better form of typechecking.

The keys of your packet determine the ID it gets. The server and the client sharing this key is essential: that's the core of how ByteNet works. Unfortunately, this means you cannot have duplicate contents of packets. **This may change in the future.**

Enough of how it works, let's start off with making a basic packet:
```lua title="packets.luau"
local ByteNet = require(path.to.bytenet)

return {
	printSomething = ByteNet.definePacket({
		-- This structure field is very important!
		structure = {
			message = ByteNet.string,
		}
	})
}
```

---

## Sending

On the server, there are 3 methods of sending packets to players. It's important to note that when a player should be specified, it's the *second* parameter given, not the first. This is an intentional design choice.

- `sendToAll`
- `sendToAllExcept`
- `sendTo`

On the client, there is only one, because you can only send data to the server:

- `send`

These functions *must* obey your structure created in `definePacket`, and if you have strict typing on, an error will be raised if the types do not match.

*code examples*
```lua title="client.luau"
-- Sending to server
packets.myPacket:send({
	message = "Hello, world!"
})
```
```lua title="server.luau"
-- Sending to all players
packets.myPacket:sendToAll({
	message = "Hello, players!"
})

-- Sending to an individual player
local someArbitraryPlayer = Players.You

packets.myPacket:sendTo({
	message = "Hello, random player!"
}, someArbitraryPlayer)

-- Sending to all except a certain player
local someArbitraryPlayer = Players.You

packets.myPacket:sendToAllExcept({
	message = "Hello, everyone except one person!"
})
```

## Receiving

You can use the `listen` method to listen for when a packet is received.

*code examples*
```lua title="server.luau"
packets.myPacket:listen(function(data, player)
	print(`{player.UserId} says { data.message }`)
end)
```
```lua title="client.luau"
packets.myPacket:listen(function(data)
	print(`server says { data.message }`)
end)
```
---

## Configuration (Reliability types)
Currently, the only config accessible right now is reliability types. This will change as time goes on, however right now, you can switch reliability types by defining `reliabilityType` to be `"reliable"` or `"unreliable"`.