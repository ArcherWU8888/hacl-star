module Spec.Connect.Test

open FStar.Error
open Spec.Lib.IntTypes
open Spec.Lib.RawIntTypes
open Spec.Lib.IntSeq


(* Aliases *)
module TCP = Spec.Lib.IO.Tcp


let test_client_hello = List.Tot.map u8_from_UInt8 [
0x16uy; 0x03uy; 0x01uy; 0x02uy; 0x00uy; 0x01uy; 0x00uy; 0x01uy; 0xfcuy; 0x03uy; 0x03uy; 0x0fuy; 0x65uy; 0xd9uy; 0xc8uy; 0x27uy; 0xfduy; 0x22uy; 0x6buy; 0x53uy; 0xf8uy; 0xbduy; 0x3fuy; 0xd9uy; 0x22uy; 0x25uy; 0x93uy; 0xaauy; 0xefuy; 0xdauy; 0x77uy; 0xbcuy; 0xcauy; 0x66uy; 0x4euy; 0x2cuy; 0x66uy; 0x5buy; 0xb6uy; 0xeauy; 0xe2uy; 0x6duy; 0x87uy; 0x20uy; 0x69uy; 0xceuy; 0xa7uy; 0x6fuy; 0x96uy; 0x93uy; 0xb5uy; 0x20uy; 0x73uy; 0x6buy; 0x28uy; 0x67uy; 0x40uy; 0x62uy; 0x87uy; 0x1auy; 0xc4uy; 0xb3uy; 0x8duy; 0x04uy; 0xc0uy; 0x8auy; 0xf0uy; 0x3euy; 0x6auy; 0xd0uy; 0x2buy; 0xe1uy; 0xcbuy; 0xaduy; 0x1auy; 0xa1uy; 0x00uy; 0x1cuy; 0x13uy; 0x01uy; 0x13uy; 0x03uy; 0x13uy; 0x02uy; 0xc0uy; 0x2buy; 0xc0uy; 0x2fuy; 0xccuy; 0xa9uy; 0xccuy; 0xa8uy; 0xc0uy; 0x2cuy; 0xc0uy; 0x30uy; 0xc0uy; 0x13uy; 0xc0uy; 0x14uy; 0x00uy; 0x2fuy; 0x00uy; 0x35uy; 0x00uy; 0x0auy; 0x01uy; 0x00uy; 0x01uy; 0x97uy; 0x00uy; 0x00uy; 0x00uy; 0x16uy; 0x00uy; 0x14uy; 0x00uy; 0x00uy; 0x11uy; 0x65uy; 0x6euy; 0x61uy; 0x62uy; 0x6cuy; 0x65uy; 0x64uy; 0x2euy; 0x74uy; 0x6cuy; 0x73uy; 0x31uy; 0x33uy; 0x2euy; 0x63uy; 0x6fuy; 0x6duy; 0x00uy; 0x17uy; 0x00uy; 0x00uy; 0xffuy; 0x01uy; 0x00uy; 0x01uy; 0x00uy; 0x00uy; 0x0auy; 0x00uy; 0x0euy; 0x00uy; 0x0cuy; 0x00uy; 0x1duy; 0x00uy; 0x17uy; 0x00uy; 0x18uy; 0x00uy; 0x19uy; 0x01uy; 0x00uy; 0x01uy; 0x01uy; 0x00uy; 0x0buy; 0x00uy; 0x02uy; 0x01uy; 0x00uy; 0x00uy; 0x23uy; 0x00uy; 0x00uy; 0x00uy; 0x10uy; 0x00uy; 0x0euy; 0x00uy; 0x0cuy; 0x02uy; 0x68uy; 0x32uy; 0x08uy; 0x68uy; 0x74uy; 0x74uy; 0x70uy; 0x2fuy; 0x31uy; 0x2euy; 0x31uy; 0x00uy; 0x05uy; 0x00uy; 0x05uy; 0x01uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x33uy; 0x00uy; 0x6buy; 0x00uy; 0x69uy; 0x00uy; 0x1duy; 0x00uy; 0x20uy; 0xdeuy; 0xa7uy; 0x49uy; 0x74uy; 0x90uy; 0xe5uy; 0xb2uy; 0x5buy; 0x6euy; 0x31uy; 0x04uy; 0x28uy; 0x99uy; 0x3buy; 0xdcuy; 0xb0uy; 0x23uy; 0x12uy; 0x02uy; 0x95uy; 0x91uy; 0x0auy; 0xb8uy; 0x32uy; 0x17uy; 0x70uy; 0xebuy; 0x13uy; 0xd5uy; 0xc9uy; 0x8buy; 0x60uy; 0x00uy; 0x17uy; 0x00uy; 0x41uy; 0x04uy; 0x7duy; 0x50uy; 0x23uy; 0x75uy; 0x0buy; 0xb6uy; 0xebuy; 0x80uy; 0x51uy; 0xb0uy; 0xbbuy; 0x8euy; 0x41uy; 0x7auy; 0x36uy; 0x1fuy; 0x71uy; 0xf5uy; 0x54uy; 0x84uy; 0x26uy; 0x83uy; 0xcauy; 0x6duy; 0x84uy; 0xe2uy; 0xc3uy; 0x70uy; 0x6fuy; 0x4cuy; 0x1buy; 0xd6uy; 0x37uy; 0xe4uy; 0xd5uy; 0x4fuy; 0xaauy; 0x6cuy; 0xe4uy; 0x5fuy; 0x29uy; 0xfauy; 0xabuy; 0x41uy; 0x55uy; 0xa0uy; 0x03uy; 0x96uy; 0xd8uy; 0x99uy; 0x7duy; 0xe1uy; 0x4cuy; 0xcauy; 0x2duy; 0xafuy; 0x47uy; 0x9buy; 0x54uy; 0x15uy; 0x9duy; 0x9cuy; 0x9cuy; 0xf0uy; 0x00uy; 0x2buy; 0x00uy; 0x09uy; 0x08uy; 0x7fuy; 0x17uy; 0x03uy; 0x03uy; 0x03uy; 0x02uy; 0x03uy; 0x01uy; 0x00uy; 0x0duy; 0x00uy; 0x18uy; 0x00uy; 0x16uy; 0x04uy; 0x03uy; 0x05uy; 0x03uy; 0x06uy; 0x03uy; 0x08uy; 0x04uy; 0x08uy; 0x05uy; 0x08uy; 0x06uy; 0x04uy; 0x01uy; 0x05uy; 0x01uy; 0x06uy; 0x01uy; 0x02uy; 0x03uy; 0x02uy; 0x01uy; 0x00uy; 0x2duy; 0x00uy; 0x02uy; 0x01uy; 0x01uy; 0x00uy; 0x15uy; 0x00uy; 0x9buy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy
]


(* Test *)
let test() =
  // let f tcp = ... in
  match TCP.connect "enabled.tls13.com" 443 with
  | Error _ -> IO.print_string "Failed to connect !\n"
  | Correct tcp -> begin
    IO.print_string "Success to connect !\n";
    match TCP.send tcp (FStar.List.Tot.length test_client_hello) test_client_hello with
    | Error _ -> IO.print_string "Failed to send !\n"
    | Correct _ -> IO.print_string "Success to send !\n"
    end
