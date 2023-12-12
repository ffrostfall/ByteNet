declare class packet<T> {
	send: (data: T, player: Player) => void;
	sendToAll: (data: T) => void;
	listen: (callback: (data: T, player: Player | undefined) => void) => void;
}

interface byteNet {
	dataTypes: {
		string: string;
		i8: number;
	}
	
	definePacket: <_, T>(reliabilityType: "reliable" | "unreliable", structure: T) => packet<T>;
}

export = byteNet;