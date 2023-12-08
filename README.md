# ByteNet v0.1.0

## An advanced, modern networking library for Roblox

---

## Features
- Strictly typed in Luau
- Supports Reliability types
- Packets are structured in key-value pairs, except the keys are serialized away
- Written entirely w/ buffers (Compression woohoo)
- Queues events per-frame
- Ordered

---

## Performance

### **Speed**

ByteNet is incredibly performant, running **purely** on buffers with zero table manipulation.

### **Bandwidth**

ByteNet lets **you** specify exact data types, such as **int8**, **uint32**. Packet IDs are **1 byte**.