<div class="docs" markdown="span">

<h1>Available special types</h1>

</div>

Special types are how complex packet types are made. They can take in nearly any type, including themselves, and most importantly they are dynamic. This means you can have an array of any length, a map of any key type and any value type, and an optional value of any type.

Special types always take *parameters*. You have to call them: `ByteNet.<type name>(<any primitive type>)`.

!!!danger
	### There are drawbacks to using these!

	- Using these types incurs 1-2 bytes of overhead due to the dynamic nature.
	- They take drastically more time to parse
	- They are heavier on memory usage, as a new closure is created each time. You will never have to worry about this unless you have dozens of packets, though.

---

## Optionals
Optional types are a cool name for the concept of "This doesn't have to exist". It's good for optional parameters: for example if some invoked function were to fail, you might want to send back a blank copy to indicate that something is wrong.

```lua title="packets.luau"
return {
	myCoolPacket = ByteNet.definePacket({
		structure = {
			-- An "optional" type takes in a parameter.
			-- This can be anything! You can even have optional arrays.
			helloWorldString = ByteNet.optional(ByteNet.string)

			-- This works!
			eachCharacter = ByteNet.optional(ByteNet.array(ByteNet.string))
		},
	})
}
```
You really don't have to think about using optional types. You just send it!
```lua title="server.luau"
local packets = require(path.to.packets)

local randomlyStringOrNil = 
	if math.random(1, 2) == 1 then "Hello, world!" else nil

packets.myCoolPacket:sendToAll({
	helloWorldString = randomlyAppearingString,

	-- Note that even if we don't put the "eachCharacter" field here,
	-- it won't error. This is because it's optional!
})
```

---

## Arrays
Arrays are fairly self explanatory. They're just plain old arrays. However, it's important to note that mixed tables have **undefined** behavior when passed as an array. This means things might be missing when they come out on the other side!

There is a 2 byte overhead to sending an array in ByteNet. This is because these 2 bytes are an unsigned 16-bit integer, which stores the array length. As a side effect, arrays sent through ByteNet have a max length of **2^16**, which is equal to **65,536**. It's likely that in the future, you will be able to reduce the overhead to 1 byte through configuration, in turn reducing the max length of the array.

```lua title="packets.luau"
return {
	myCoolPacket = ByteNet.definePacket({
		structure = {
			myArray = ByteNet.array(ByteNet.bool)
		},
	})
}
```

```lua title="server.luau"
local packets = require(path.to.packets)

packets.myCoolPacket:sendToAll({
	-- Important to note that mixed arrays/arrays with holes
	-- shouldn't be sent through.
	myArray = { true, false, true }
})
```

---

## Maps
Maps are by far the most powerful "special" type in ByteNet. They let you send, what's most commonly referred to as a dictionary, through ByteNet. However it's important to keep in mind two things: the type of the key (or index), and the type of the value, cannot change.

Like arrays, maps have a 2-byte overhead to store the length of the map. This is done by iterating over the map using <a href="https://devforum.roblox.com/t/luau-recap-may-2022/1818869">generic iteration</a> and increasing a variable by 1 for every key-value pair. This, once again, means that there is a **2^16** (which equals to **65,536**) cap to the number of elements in the map.

```lua title="packets.luau"
return {
	myCoolPacket = ByteNet.definePacket({
		structure = {
			-- [name] = age
			people = ByteNet.map(ByteNet.string, ByteNet.uint16)
		},
	})
}
```

```lua title="server.luau"
local packets = require(path.to.packets)

packets.myCoolPacket:sendToAll({
	people = {
		john = 21,
		jane = 24,
		dave = 26,
		you = 162,
	}
})
```