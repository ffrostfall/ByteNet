/* eslint-disable @typescript-eslint/no-explicit-any */

declare class packet<T extends ByteNetType<any>> {
  // can't have server and client overloads while keeping dot access to methods because of how typescript works
  listen: (callback: (data: T["value"]) => void) => void;

  // @client
  send: (data: T["value"]) => void;

  // @server
  sendToAll: (data: T["value"]) => void;
  sendTo: (data: T["value"], player: Player) => void;
  sendToList: (data: T["value"], players: Player[]) => void;
  sendToAllExcept: (data: T["value"], exception: Player) => void;
}

type ByteNetType<T> = {
  value: T;
};

declare type array<T extends ByteNetType<any>> = ByteNetType<T[]>;
declare type struct<T extends { [index: string]: ByteNetType<any> }> =
  ByteNetType<{
    [valueName in keyof T]: T[valueName]["value"];
  }>;
declare type optional<T extends ByteNetType<any>> = ByteNetType<
  T["value"] | undefined
>;
declare type map<
  K extends ByteNetType<any>,
  V extends ByteNetType<any>,
> = ByteNetType<Map<K["value"], V["value"]>>;

export namespace ByteNet {
  export function definePacket<T extends ByteNetType<any>>(packetProps: {
    value: T;
    reliabilityType: "reliable" | "unreliable";
  }): packet<T>;

  export function defineNamespace<
    T extends {
      [packetName: string]: packet<ByteNetType<any>>;
    },
  >(
    namespaceDefine: () => T,
  ): {
    [packetName in keyof T]: T[packetName];
  };

  // Primitive types
  export function i8(): ByteNetType<number>;
  export function i16(): ByteNetType<number>;
  export function i32(): ByteNetType<number>;
  export function u8(): ByteNetType<number>;
  export function u16(): ByteNetType<number>;
  export function u32(): ByteNetType<number>;
  export function f32(): ByteNetType<number>;
  export function f64(): ByteNetType<number>;
  export function string(): ByteNetType<string>;
  export function bool(): ByteNetType<boolean>;
  export function buff(): ByteNetType<buffer>;
  export function inst(): ByteNetType<Instance>;
  export function nothing(): ByteNetType<void>;
  export function unknown(): ByteNetType<unknown>;

  // Special types
  export function array<T extends ByteNetType<any>>(type: T): array<T>;
  export function struct<T extends { [index: string]: ByteNetType<any> }>(
    struct: T,
  ): struct<T>;
  export function optional<T extends ByteNetType<any>>(type: T): optional<T>;
  export function map<K extends ByteNetType<any>, V extends ByteNetType<any>>(
    key: K,
    value: V,
  ): map<K, V>;
}
