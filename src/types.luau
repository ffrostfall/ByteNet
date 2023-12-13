type Packet<T> = {
	sendToAll: (self: Packet<T>, data: T) -> (),
	send: (self: Packet<T>, data: T, target: Player?) -> (),
	listen: (self: Packet<T>, callback: (data: T, player: Player?) -> ()) -> (),
}

export type ByteNet = {
	definePacket: <_, T>(reliabilityType: "reliable" | "unreliable", structure: T) -> Packet<T>,

	dataTypes: {
		uint8: number,
		int8: number,

		uint16: number,
		int16: number,

		uint32: number,
		int32: number,

		float32: number,
		float64: number,

		vec3: Vector3,
		string: string,
		bool: boolean,
	},
}

return nil
