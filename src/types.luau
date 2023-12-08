type Packet<T> = {
	sendToAll: (self: Packet<T>, data: T) -> (),
	send: (self: Packet<T>, data: T, target: Player?) -> (),
	listen: (self: Packet<T>, callback: (data: T, player: Player?) -> ()) -> (),
}

export type ByteNet = {
	createPacket: <_, T>(reliabilityType: "reliable" | "unreliable", structure: T) -> Packet<T>,

	dataTypes: {
		uint8: number,
		string: string,
	},
}

return nil
