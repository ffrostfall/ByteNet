export type packetFormat = {
	{
		writer: (b: buffer, offset: number, value: any) -> (),
		reader: (b: buffer, offset: number) -> any,
		key: string,
		length: (value: any) -> number,
	}
}

type Packet<T> = {
	sendToAll: (self: Packet<T>, data: T) -> (),
	send: (self: Packet<T>, data: T, target: Player?) -> (),
	listen: (self: Packet<T>, callback: (data: T, player: Player?) -> ()) -> (),
}

export type ByteNet = {
	definePacket: <T>(structure: T, reliabilityType: ("reliable" | "unreliable")?) -> Packet<T>,

	dataTypes: {
		opt_uint8: () -> number?,
		opt_int8: () -> number?,
		uint8: () -> number,
		int8: () -> number,

		opt_uint16: () -> number?,
		opt_int16: () -> number?,
		uint16: () -> number,
		int16: () -> number,

		opt_uint32: () -> number?,
		opt_int32: () -> number?,
		uint32: () -> number,
		int32: () -> number,

		opt_float32: () -> number?,
		opt_float64: () -> number?,
		float32: () -> number,
		float64: () -> number,

		vec3: () -> Vector3,
		string: () -> string,
		bool: () -> boolean,
		buff: () -> buffer,
	},
}

return nil
