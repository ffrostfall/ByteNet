-- Used internally to define the format of a packet in an efficient way
export type packetFormat = {
	{
		-- read | write | key
		[number]: ((b: buffer, offset: number) -> (any, number)) | ((offset: number, value: any) -> number) | string,
	}
}
export type packetFormatElement =
	((b: buffer, offset: number) -> (any, number))
	| ((offset: number, value: any) -> number)
	| string

-- Used internally to efficiently handle the "deferred write" with buffers
export type bufferQueue = { ((b: buffer, c: number, v: any) -> ()) | number | string | buffer }

-- Used internally for serializing and deserializing all data types
export type dataTypeInterface<T> = {
	write: (cursor: number, value: T) -> number,
	read: (b: buffer, cursor: number) -> (T, number),
}

-- Somewhat public facing: used as return result in definePacket
type Packet<T> = {
	sendToAll: (self: Packet<T>, data: T) -> (),
	send: (self: Packet<T>, data: T, target: Player?) -> (),
	listen: (self: Packet<T>, callback: (data: T, player: Player?) -> ()) -> (),
}

-- Library type
export type ByteNet = {
	definePacket: <T>(props: {
		structure: T,
		reliabilityType: ("reliable" | "unreliable")?,
	}) -> Packet<T>,

	dataTypes: {
		bool: () -> boolean,
		array: <T>(value: T) -> { [number]: T },
		optional: <T>(value: T) -> T?,
		uint8: () -> number,
		uint16: () -> number,
		uint32: () -> number,
		int8: () -> number,
		int16: () -> number,
		int32: () -> number,
		float32: () -> number,
		float64: () -> number,
		string: () -> string,
		vec3: () -> Vector3,
		vec2: () -> Vector2,
		buff: () -> buffer,
		cframe: () -> CFrame,
		map: <K, V>(key: K, value: V) -> { [K]: V },
	},
}

return nil
