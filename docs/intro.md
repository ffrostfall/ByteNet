---
sidebar_position: 1
---

# Intro

ByteNet is an advanced networking library targeted at devs who want way more granular control over their networking. It sends solely buffers through RemoteEvents, w/ automatic queueing functionality, and has built-in serialization and deserialization. This means you basically just don't have to worry about optimization when using ByteNet!

## Packets
ByteNet is built off an object called a `packet`. These packets have a clear and unchanging structure. You create packets by using `definePacket`, then use the `send` and `listen` methods to send and receive networked information. You send, and receive these packets as dictionaries; key-value pairs. But don't worry! The keys are serialized away, they don't affect performance or packet size **at all.**