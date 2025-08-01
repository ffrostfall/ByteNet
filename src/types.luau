export type ChannelState = {
	buff: buffer,
	cursor: number,
	ref_map: { [number]: unknown },
}

export type PacketProps<T> = {
	value: T,

	reliability: ("Reliable" | "Unreliable")?,

	max_per_frame: number?,
}

export type DataType<T> = {
	read __T: T,

	write: (value: T) -> (),
	read: (b: buffer, cursor: number) -> (T, number),

	read length: number?,
}

type Packet<T> = {
	send_to_all: (data: T) -> (),
	send_to: (data: T, target: Player) -> (),
	send_to_list: (data: T, targets: { Player }) -> (),
	send_to_all_except: (data: T, exception: Player) -> (),

	wait: () -> T,
	send: (data: T, target: Player?) -> (),
	listen: (callback: (data: T, player: Player?) -> ()) -> (),
}

export type function ValueFromDataType(data_type: type)
	return data_type:readproperty(types.singleton("__T"))
end

return nil
