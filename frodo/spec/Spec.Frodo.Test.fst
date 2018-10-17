module Spec.Frodo.Test

open FStar.Mul
open Lib.IntTypes
open Lib.RawIntTypes
open Lib.Sequence
open Lib.ByteSequence

open Spec.Frodo.KEM
open Spec.Frodo.KEM.KeyGen
open Spec.Frodo.KEM.Encaps
open Spec.Frodo.KEM.Decaps
open Spec.Frodo.Params

open FStar.All

// Reducing e.g. v (size 64) to 64 requires access to Lib.IntTypes implementation,
// hence why we befriend Lib.IntTypes although it might be possible to prove this 
// opaquely.
friend Lib.IntTypes

#reset-options "--max_fuel 0 --max_ifuel 1"

let print_and_compare (#len: size_nat) (test_expected: lbytes len) (test_result: lbytes len)
  : ML bool =
  IO.print_string "\nResult:   ";
  List.iter (fun a -> IO.print_string (UInt8.to_string (u8_to_UInt8 a))) (to_list test_result);
  IO.print_string "\nExpected: ";
  List.iter (fun a -> IO.print_string (UInt8.to_string (u8_to_UInt8 a))) (to_list test_expected);
  for_all2 (fun a b -> uint_to_nat #U8 a = uint_to_nat #U8 b) test_expected test_result

let compare (#len: size_nat) (test_expected: lbytes len) (test_result: lbytes len) =
  for_all2 (fun a b -> uint_to_nat #U8 a = uint_to_nat #U8 b) test_expected test_result

let test_frodo
  (keypaircoins: list uint8 {List.Tot.length keypaircoins == 2 * crypto_bytes + bytes_seed_a})
  (enccoins: list uint8 {List.Tot.length enccoins == bytes_mu})
  (ss_expected: list uint8 {List.Tot.length ss_expected == crypto_bytes})
  (pk_expected: list uint8 {List.Tot.length pk_expected == crypto_publickeybytes})
  (ct_expected: list uint8 {List.Tot.length ct_expected == crypto_ciphertextbytes})
  (sk_expected: list uint8 {List.Tot.length sk_expected == crypto_secretkeybytes})
  : ML bool =
  let keypaircoins = createL keypaircoins in
  let enccoins = createL enccoins in
  let ss_expected = createL ss_expected in
  let pk_expected = createL pk_expected in
  let ct_expected = createL ct_expected in
  let sk_expected = createL sk_expected in
  let pk, sk = crypto_kem_keypair_ keypaircoins in
  let ct, ss1 = crypto_kem_enc_ enccoins pk in
  let ss2 = crypto_kem_dec ct sk in
  let r_pk = compare pk_expected pk in
  let r_sk = compare sk_expected sk in
  let r_ct = compare ct_expected ct in
  let r_ss = print_and_compare ss1 ss2 in
  let r_ss1 = print_and_compare ss_expected ss2 in
  r_pk && r_sk && r_ct && r_ss && r_ss1

//
// Test1. FrodoKEM-64. CSHAKE128
//
let test1_keypaircoins =
  List.Tot.map u8_from_UInt8
    [
      0x4buy; 0x62uy; 0x2duy; 0xe1uy; 0x35uy; 0x01uy; 0x19uy; 0xc4uy; 0x5auy; 0x9fuy; 0x2euy; 0x2euy;
      0xf3uy; 0xdcuy; 0x5duy; 0xf5uy; 0x0auy; 0x75uy; 0x9duy; 0x13uy; 0x8cuy; 0xdfuy; 0xbduy; 0x64uy;
      0xc8uy; 0x1cuy; 0xc7uy; 0xccuy; 0x2fuy; 0x51uy; 0x33uy; 0x45uy; 0xd5uy; 0xa4uy; 0x5auy; 0x4cuy;
      0xeduy; 0x06uy; 0x40uy; 0x3cuy; 0x55uy; 0x57uy; 0xe8uy; 0x71uy; 0x13uy; 0xcbuy; 0x30uy; 0xeauy
    ]

let test1_enccoins =
  List.Tot.map u8_from_UInt8
    [
      0x08uy; 0xe2uy; 0x55uy; 0x38uy; 0x48uy; 0x4cuy; 0xd7uy; 0xf1uy; 0x61uy; 0x32uy; 0x48uy; 0xfeuy;
      0x6cuy; 0x9fuy; 0x6buy; 0x4euy
    ]

let test1_ss_expected =
  List.Tot.map u8_from_UInt8
    [
      0xdfuy; 0xc5uy; 0x2auy; 0x95uy; 0x6cuy; 0xe4uy; 0xbcuy; 0xa5uy; 0x53uy; 0x70uy; 0x46uy; 0x5auy;
      0x7euy; 0xf8uy; 0x4fuy; 0x68uy
    ]

let test1_pk_expected =
  List.Tot.map u8_from_UInt8
    [
      0x92uy; 0x44uy; 0x4duy; 0x91uy; 0xa2uy; 0xaduy; 0xaduy; 0x05uy; 0x2cuy; 0xa2uy; 0x3duy; 0xe5uy;
      0xfbuy; 0x9duy; 0xf9uy; 0xe1uy; 0x95uy; 0xe3uy; 0x8fuy; 0xc2uy; 0x21uy; 0xb8uy; 0xb8uy; 0x34uy;
      0x14uy; 0xfbuy; 0xd3uy; 0xefuy; 0x7cuy; 0xa2uy; 0x6buy; 0x36uy; 0x8cuy; 0x7buy; 0x9duy; 0x81uy;
      0x78uy; 0xc9uy; 0x49uy; 0x64uy; 0x4duy; 0x79uy; 0xfduy; 0x8buy; 0x19uy; 0xb9uy; 0x51uy; 0x4cuy;
      0xceuy; 0x27uy; 0x4duy; 0x64uy; 0xaauy; 0xe0uy; 0x29uy; 0x69uy; 0x10uy; 0xaauy; 0x9fuy; 0x49uy;
      0xacuy; 0x16uy; 0x1duy; 0xbcuy; 0x4euy; 0xa0uy; 0x85uy; 0xf4uy; 0xf4uy; 0x58uy; 0x3auy; 0xb9uy;
      0xaauy; 0xa9uy; 0xbduy; 0x30uy; 0xf3uy; 0xc9uy; 0x1buy; 0x6buy; 0x4duy; 0x26uy; 0xfeuy; 0x4buy;
      0x3euy; 0xc1uy; 0x88uy; 0xebuy; 0xdeuy; 0x99uy; 0x0auy; 0xa9uy; 0xb1uy; 0x27uy; 0xc0uy; 0x28uy;
      0x96uy; 0x65uy; 0xfeuy; 0x3auy; 0xf9uy; 0x0euy; 0x67uy; 0x7auy; 0x7fuy; 0x10uy; 0x4cuy; 0x16uy;
      0xaeuy; 0x2cuy; 0x0cuy; 0x72uy; 0x62uy; 0x5buy; 0x4duy; 0x3cuy; 0x12uy; 0x21uy; 0x9auy; 0x7euy;
      0x8fuy; 0x07uy; 0x51uy; 0xe0uy; 0x86uy; 0x3euy; 0x33uy; 0x98uy; 0x9buy; 0x81uy; 0x2auy; 0x96uy;
      0x99uy; 0xe2uy; 0xf9uy; 0x99uy; 0x4fuy; 0x28uy; 0x0buy; 0x76uy; 0xcbuy; 0x32uy; 0xb8uy; 0xeauy;
      0x77uy; 0xaduy; 0xa3uy; 0xe9uy; 0xaduy; 0x82uy; 0x76uy; 0xe3uy; 0x8cuy; 0x4fuy; 0x71uy; 0x8fuy;
      0xd8uy; 0xd4uy; 0xaduy; 0xb4uy; 0x5buy; 0x3fuy; 0x84uy; 0xb3uy; 0xefuy; 0x91uy; 0x01uy; 0xb4uy;
      0xaauy; 0xfeuy; 0x7buy; 0xdauy; 0xe3uy; 0x6buy; 0x9euy; 0x02uy; 0xc2uy; 0xb7uy; 0x35uy; 0xecuy;
      0x77uy; 0x15uy; 0xe1uy; 0x13uy; 0x95uy; 0x68uy; 0xd4uy; 0x18uy; 0x44uy; 0x29uy; 0x78uy; 0x55uy;
      0x47uy; 0xf5uy; 0x50uy; 0x98uy; 0x8euy; 0xf3uy; 0x01uy; 0xa1uy; 0x71uy; 0xf5uy; 0x18uy; 0xa6uy;
      0xd1uy; 0xfauy; 0xacuy; 0x90uy; 0xe1uy; 0xa8uy; 0x4duy; 0x83uy; 0xd7uy; 0xcduy; 0xc5uy; 0x14uy;
      0x1duy; 0xceuy; 0x24uy; 0x9euy; 0xc4uy; 0x7buy; 0x15uy; 0x9fuy; 0x07uy; 0x3duy; 0x85uy; 0xf6uy;
      0x1buy; 0x0duy; 0xe6uy; 0xc1uy; 0x3fuy; 0x1euy; 0x3fuy; 0x6cuy; 0x0auy; 0xc7uy; 0x2duy; 0xa4uy;
      0x9duy; 0xb2uy; 0x6euy; 0x2cuy; 0xbauy; 0xb8uy; 0x6fuy; 0xabuy; 0x34uy; 0x3auy; 0x48uy; 0xabuy;
      0x2fuy; 0x75uy; 0xabuy; 0x48uy; 0x21uy; 0x8euy; 0x59uy; 0x9duy; 0xd0uy; 0xf7uy; 0xcduy; 0x2duy;
      0xeduy; 0xc4uy; 0xb9uy; 0xaeuy; 0x1buy; 0x30uy; 0xf1uy; 0xc6uy; 0x94uy; 0x21uy; 0xa7uy; 0x81uy;
      0x58uy; 0xcfuy; 0x0euy; 0x7auy; 0xf0uy; 0xb5uy; 0x44uy; 0x42uy; 0x1auy; 0xd4uy; 0x22uy; 0xfauy;
      0x18uy; 0x0duy; 0x2cuy; 0x05uy; 0xd3uy; 0x74uy; 0xebuy; 0x90uy; 0x11uy; 0x25uy; 0xafuy; 0x00uy;
      0x3euy; 0xe7uy; 0xbeuy; 0xf1uy; 0x1euy; 0xafuy; 0x6duy; 0xd0uy; 0x7fuy; 0xa4uy; 0x12uy; 0xcfuy;
      0x4fuy; 0xc4uy; 0x65uy; 0xaauy; 0x07uy; 0x73uy; 0x5fuy; 0x22uy; 0xa0uy; 0x32uy; 0xd4uy; 0xd5uy;
      0xe5uy; 0x28uy; 0x47uy; 0x2euy; 0xb5uy; 0xc1uy; 0x2duy; 0x58uy; 0xc2uy; 0xe9uy; 0x83uy; 0xcduy;
      0x41uy; 0xa0uy; 0x82uy; 0x63uy; 0x92uy; 0x76uy; 0xc3uy; 0x51uy; 0x05uy; 0xf0uy; 0x6fuy; 0x18uy;
      0xeduy; 0xb7uy; 0x7buy; 0x87uy; 0xcbuy; 0x90uy; 0x16uy; 0x63uy; 0x3buy; 0x67uy; 0xc1uy; 0x3auy;
      0xbbuy; 0x66uy; 0x0buy; 0xcduy; 0x9duy; 0x9buy; 0x38uy; 0x7fuy; 0xa1uy; 0x91uy; 0x14uy; 0x07uy;
      0x7fuy; 0xcfuy; 0x1fuy; 0x11uy; 0x31uy; 0xf7uy; 0x95uy; 0x89uy; 0xf7uy; 0x35uy; 0x34uy; 0x11uy;
      0xa5uy; 0x5cuy; 0xabuy; 0x70uy; 0x05uy; 0xdduy; 0x38uy; 0xc1uy; 0x7auy; 0x42uy; 0x89uy; 0x6duy;
      0x13uy; 0xdcuy; 0x16uy; 0xaauy; 0xbcuy; 0x43uy; 0xc2uy; 0x20uy; 0x0fuy; 0xd2uy; 0x21uy; 0x3euy;
      0x15uy; 0x76uy; 0x6fuy; 0x82uy; 0xefuy; 0x29uy; 0x96uy; 0x4cuy; 0xd5uy; 0xf4uy; 0x79uy; 0x3auy;
      0x29uy; 0x54uy; 0xabuy; 0xc3uy; 0x37uy; 0xbbuy; 0x8cuy; 0x2auy; 0x86uy; 0x5duy; 0x76uy; 0x31uy;
      0xc8uy; 0xc1uy; 0x30uy; 0x47uy; 0x7auy; 0xceuy; 0x37uy; 0xf0uy; 0xe0uy; 0xe3uy; 0x64uy; 0x6auy;
      0xdduy; 0xb1uy; 0x7duy; 0x59uy; 0x17uy; 0xeeuy; 0xd5uy; 0xfbuy; 0xa9uy; 0x1buy; 0xd6uy; 0x1fuy;
      0x70uy; 0x21uy; 0xa7uy; 0xdcuy; 0x55uy; 0x63uy; 0xffuy; 0xdduy; 0xe5uy; 0xb5uy; 0x52uy; 0xc5uy;
      0x7duy; 0x41uy; 0x7euy; 0x8auy; 0xdfuy; 0xc1uy; 0xf6uy; 0x03uy; 0x8fuy; 0xc7uy; 0x52uy; 0xa3uy;
      0xc7uy; 0x66uy; 0x79uy; 0x55uy; 0xeduy; 0x0euy; 0x40uy; 0x59uy; 0xbcuy; 0x60uy; 0x13uy; 0x86uy;
      0xb4uy; 0x88uy; 0x8cuy; 0xbauy; 0x9buy; 0x80uy; 0x8auy; 0x2buy; 0x4euy; 0x80uy; 0x92uy; 0xe1uy;
      0xd2uy; 0x84uy; 0x93uy; 0xb6uy; 0xc8uy; 0xb3uy; 0x23uy; 0x1duy; 0xd3uy; 0xf7uy; 0xdduy; 0xa6uy;
      0x39uy; 0x1auy; 0x65uy; 0x08uy; 0x0fuy; 0x95uy; 0x78uy; 0x89uy; 0xafuy; 0xabuy; 0xb9uy; 0x9duy;
      0x32uy; 0x89uy; 0x82uy; 0x07uy; 0xf2uy; 0x1duy; 0xc0uy; 0xbauy; 0x30uy; 0x01uy; 0x42uy; 0x9auy;
      0xccuy; 0x8euy; 0x16uy; 0x7auy; 0xc0uy; 0xd7uy; 0x4auy; 0x91uy; 0xe0uy; 0x46uy; 0xf5uy; 0xaeuy;
      0xe0uy; 0xeduy; 0x0auy; 0x2cuy; 0xe1uy; 0xafuy; 0x40uy; 0xf1uy; 0x4duy; 0x18uy; 0x71uy; 0x5euy;
      0xd3uy; 0x6cuy; 0x9cuy; 0x52uy; 0x70uy; 0xfduy; 0xd2uy; 0xacuy; 0x05uy; 0xf6uy; 0xcbuy; 0x22uy;
      0x9fuy; 0x04uy; 0x8duy; 0xd0uy; 0x25uy; 0xe1uy; 0xfbuy; 0xeduy; 0x19uy; 0x7euy; 0x65uy; 0x51uy;
      0x60uy; 0xccuy; 0x88uy; 0xceuy; 0xdauy; 0xf5uy; 0xaduy; 0xfduy; 0x63uy; 0xd2uy; 0x62uy; 0x3fuy;
      0x98uy; 0x05uy; 0xbfuy; 0xd9uy; 0xaeuy; 0x16uy; 0x90uy; 0xdbuy; 0x1euy; 0x15uy; 0x2euy; 0xb0uy;
      0xcduy; 0x95uy; 0x8cuy; 0x27uy; 0x6auy; 0xd9uy; 0x1buy; 0xc1uy; 0xdduy; 0x02uy; 0xa9uy; 0x92uy;
      0x9auy; 0x9euy; 0x2buy; 0x25uy; 0xebuy; 0x82uy; 0x65uy; 0xcfuy; 0x5euy; 0x25uy; 0x8cuy; 0x5euy;
      0xc3uy; 0x2auy; 0x85uy; 0x50uy; 0x67uy; 0x78uy; 0x6cuy; 0xe5uy; 0x8fuy; 0xdbuy; 0x56uy; 0xd3uy;
      0x73uy; 0x64uy; 0x83uy; 0xaauy; 0xe6uy; 0x97uy; 0x2duy; 0x90uy; 0x9cuy; 0xb3uy; 0x59uy; 0xf5uy;
      0xeeuy; 0x59uy; 0xe3uy; 0x05uy; 0xb1uy; 0xa1uy; 0x45uy; 0x4cuy; 0xcfuy; 0x94uy; 0x3euy; 0x5cuy;
      0x15uy; 0x06uy; 0xf9uy; 0x5cuy; 0xc3uy; 0x82uy; 0x22uy; 0x71uy; 0x2buy; 0x42uy; 0xb5uy; 0xd5uy;
      0x44uy; 0x8fuy; 0xf8uy; 0x64uy; 0x54uy; 0x75uy; 0x03uy; 0xcfuy; 0xdduy; 0x91uy; 0x6buy; 0x05uy;
      0x09uy; 0x24uy; 0x7fuy; 0xd5uy; 0x97uy; 0x3euy; 0xa4uy; 0x7cuy; 0x65uy; 0x0auy; 0x42uy; 0x6buy;
      0x64uy; 0xa2uy; 0xd8uy; 0x81uy; 0x4fuy; 0xc0uy; 0xecuy; 0xd8uy; 0x79uy; 0x4cuy; 0xcbuy; 0x9cuy;
      0x27uy; 0xbcuy; 0x60uy; 0x6fuy; 0xe2uy; 0x49uy; 0x9buy; 0x44uy; 0x93uy; 0x6duy; 0xa4uy; 0x74uy;
      0x04uy; 0x1cuy; 0x81uy; 0xf9uy; 0x01uy; 0x8fuy; 0xd2uy; 0x4duy; 0xaduy; 0x07uy; 0x9auy; 0xbbuy;
      0x11uy; 0xc8uy; 0x76uy; 0x64uy; 0x29uy; 0xfeuy; 0xa4uy; 0x1auy; 0x25uy; 0x05uy; 0x4auy; 0xafuy;
      0x59uy; 0xa9uy; 0x88uy; 0xf7uy; 0x73uy; 0x12uy; 0x60uy; 0xd4uy; 0x12uy; 0x01uy; 0x68uy; 0xf5uy;
      0xbeuy; 0xc5uy; 0xb2uy; 0x7buy; 0xdcuy; 0xebuy; 0x96uy; 0xecuy; 0x43uy; 0x5duy; 0xc2uy; 0x07uy;
      0xb4uy; 0x1duy; 0xf7uy; 0x78uy; 0xa7uy; 0x82uy; 0x8duy; 0x10uy; 0x0buy; 0x90uy; 0xebuy; 0x5cuy;
      0x1euy; 0x49uy; 0x7buy; 0xdduy; 0x56uy; 0xc7uy; 0x5fuy; 0x0fuy; 0x8fuy; 0x9auy; 0x21uy; 0xcfuy;
      0xa4uy; 0x63uy; 0x20uy; 0x0cuy; 0xe5uy; 0xf7uy; 0xc2uy; 0xdfuy; 0xf1uy; 0xecuy; 0xf3uy; 0x94uy;
      0x5buy; 0xaduy; 0x29uy; 0xdduy; 0x0buy; 0x43uy; 0x19uy; 0xabuy; 0x93uy; 0xecuy; 0x7duy; 0x50uy;
      0x6buy; 0x67uy; 0xf5uy; 0x2fuy; 0xf1uy; 0xe7uy; 0x4buy; 0xe2uy; 0x35uy; 0x41uy; 0x47uy; 0xd8uy;
      0xcfuy; 0x9auy; 0xbbuy; 0x38uy; 0x3auy; 0x37uy; 0xc3uy; 0x61uy; 0x43uy; 0xa4uy; 0x41uy; 0xabuy;
      0x4duy; 0x9buy; 0xd9uy; 0xbfuy; 0x19uy; 0x6euy; 0x66uy; 0xa1uy; 0xfduy; 0xefuy; 0x54uy; 0x6fuy;
      0xefuy; 0x1euy; 0xe0uy; 0x26uy; 0xabuy; 0xe3uy; 0xf5uy; 0xe7uy; 0x22uy; 0xd0uy; 0x84uy; 0x6euy;
      0x78uy; 0x90uy; 0x70uy; 0xc3uy; 0x87uy; 0x6auy; 0x68uy; 0xb8uy; 0x5fuy; 0x80uy; 0x10uy; 0xb3uy;
      0x8fuy; 0x56uy; 0xffuy; 0x16uy; 0xf9uy; 0x88uy; 0x67uy; 0x1auy; 0x51uy; 0x3cuy; 0xf8uy; 0x27uy;
      0x40uy; 0xbbuy; 0x69uy; 0x6euy; 0xcbuy; 0x80uy; 0xa4uy; 0x0duy; 0xb6uy; 0xb2uy; 0x66uy; 0xbduy;
      0xa2uy; 0xcbuy; 0xfeuy; 0xd7uy; 0x67uy; 0x5fuy; 0xfauy; 0x85uy; 0xd0uy; 0x98uy; 0x1euy; 0x5duy;
      0x35uy; 0x01uy; 0x91uy; 0x3fuy; 0x91uy; 0x46uy; 0xacuy; 0xcduy; 0x82uy; 0xd3uy; 0xe1uy; 0x5cuy;
      0x53uy; 0x66uy; 0xa7uy; 0xa1uy; 0x00uy; 0xd5uy; 0x34uy; 0x3fuy; 0x1euy; 0x1euy; 0x0fuy; 0x1cuy;
      0xefuy; 0x5duy; 0x2euy; 0x79uy; 0x28uy; 0x02uy; 0xbeuy; 0x9buy; 0x8buy; 0xfauy; 0x5auy; 0x0auy;
      0xf3uy; 0xfcuy; 0x8cuy; 0xdcuy; 0xbduy; 0xa3uy; 0xb6uy; 0xd3uy; 0x5buy; 0xe0uy; 0xfbuy; 0xeeuy;
      0x63uy; 0xd3uy; 0x72uy; 0x5auy
    ]

let test1_ct_expected =
  List.Tot.map u8_from_UInt8
    [
      0x9duy; 0x0euy; 0x6euy; 0xecuy; 0xc3uy; 0xd0uy; 0xa5uy; 0x9fuy; 0xbauy; 0xf9uy; 0xfbuy; 0xc9uy;
      0x30uy; 0x42uy; 0x58uy; 0x2auy; 0xf6uy; 0x5buy; 0x14uy; 0x49uy; 0xecuy; 0x17uy; 0x96uy; 0xacuy;
      0x33uy; 0x1euy; 0xe9uy; 0x13uy; 0x66uy; 0x01uy; 0x88uy; 0x3auy; 0x1auy; 0x86uy; 0x1cuy; 0x54uy;
      0xebuy; 0x12uy; 0xbeuy; 0x84uy; 0x28uy; 0x5euy; 0xbeuy; 0x62uy; 0x6auy; 0x2buy; 0xe3uy; 0xc7uy;
      0xe2uy; 0xeeuy; 0x0cuy; 0x1duy; 0x08uy; 0xbduy; 0xd0uy; 0xe0uy; 0x0cuy; 0xefuy; 0xe0uy; 0x23uy;
      0x5duy; 0x60uy; 0xeauy; 0x22uy; 0x39uy; 0x03uy; 0x0buy; 0xceuy; 0xf3uy; 0xe3uy; 0xfcuy; 0x96uy;
      0xdeuy; 0xe2uy; 0xbfuy; 0x5duy; 0x41uy; 0x59uy; 0x43uy; 0xceuy; 0xe6uy; 0x1auy; 0x79uy; 0xa3uy;
      0x76uy; 0x5euy; 0xe7uy; 0x8cuy; 0x2euy; 0x3duy; 0x74uy; 0x14uy; 0x3duy; 0xa3uy; 0x34uy; 0xcfuy;
      0xacuy; 0x56uy; 0x34uy; 0x73uy; 0x5buy; 0xccuy; 0xd3uy; 0xd2uy; 0x8buy; 0xa2uy; 0x4buy; 0x57uy;
      0xe3uy; 0x62uy; 0x09uy; 0xe3uy; 0x19uy; 0xc0uy; 0x21uy; 0x01uy; 0x98uy; 0x82uy; 0x60uy; 0x58uy;
      0x4cuy; 0x63uy; 0x7duy; 0xbcuy; 0xe0uy; 0x2euy; 0x86uy; 0x08uy; 0x7fuy; 0xf1uy; 0x79uy; 0x7duy;
      0xacuy; 0x53uy; 0x81uy; 0xfduy; 0xeduy; 0xe5uy; 0x98uy; 0x03uy; 0x03uy; 0x09uy; 0x78uy; 0x0duy;
      0xe0uy; 0x18uy; 0x24uy; 0xeduy; 0xe6uy; 0x58uy; 0x22uy; 0xd6uy; 0x50uy; 0xaeuy; 0x1buy; 0x32uy;
      0x8duy; 0x51uy; 0x81uy; 0xc1uy; 0x7duy; 0xc4uy; 0xa9uy; 0x69uy; 0xc3uy; 0x13uy; 0xe2uy; 0xbbuy;
      0x27uy; 0x8euy; 0x90uy; 0x23uy; 0xe1uy; 0xaeuy; 0xd8uy; 0xdbuy; 0xa6uy; 0x89uy; 0xfbuy; 0xacuy;
      0xc6uy; 0x39uy; 0xb9uy; 0xf4uy; 0xa5uy; 0x1buy; 0x43uy; 0x22uy; 0x19uy; 0x01uy; 0x37uy; 0x7auy;
      0x0auy; 0xf2uy; 0xf3uy; 0x22uy; 0xc5uy; 0x41uy; 0xfeuy; 0x37uy; 0x01uy; 0xaauy; 0x49uy; 0x1euy;
      0xaduy; 0xf5uy; 0x57uy; 0x20uy; 0x66uy; 0x01uy; 0xfeuy; 0xc7uy; 0x6cuy; 0xe5uy; 0xe1uy; 0x83uy;
      0xccuy; 0xf1uy; 0x1duy; 0x4fuy; 0xf2uy; 0x4buy; 0xdfuy; 0xccuy; 0xdbuy; 0x66uy; 0xe0uy; 0x20uy;
      0x89uy; 0x02uy; 0x24uy; 0xdauy; 0xb7uy; 0x85uy; 0x81uy; 0x59uy; 0x3auy; 0x02uy; 0xacuy; 0x4fuy;
      0x13uy; 0xa6uy; 0x82uy; 0xc2uy; 0x78uy; 0x7duy; 0x2duy; 0xb6uy; 0xc6uy; 0xdcuy; 0x5euy; 0x15uy;
      0x8duy; 0x24uy; 0xbauy; 0x6auy; 0x35uy; 0x13uy; 0x12uy; 0x7duy; 0xecuy; 0xbauy; 0x5fuy; 0x8fuy;
      0x02uy; 0x51uy; 0xcfuy; 0x74uy; 0x26uy; 0x47uy; 0x11uy; 0x6fuy; 0xa9uy; 0xfcuy; 0x1duy; 0x1duy;
      0x23uy; 0x0duy; 0x25uy; 0xd8uy; 0xf2uy; 0x6buy; 0x8cuy; 0x3buy; 0xf0uy; 0xd0uy; 0xccuy; 0xf6uy;
      0xe5uy; 0x3duy; 0x58uy; 0x4auy; 0x88uy; 0xd4uy; 0x48uy; 0xfbuy; 0x49uy; 0xffuy; 0x87uy; 0x2fuy;
      0x1auy; 0xc1uy; 0xdduy; 0x58uy; 0xffuy; 0x55uy; 0x09uy; 0x09uy; 0xf1uy; 0x10uy; 0x86uy; 0xa0uy;
      0x42uy; 0x98uy; 0x23uy; 0x22uy; 0x43uy; 0x60uy; 0xb3uy; 0xe8uy; 0xf2uy; 0xe9uy; 0xccuy; 0x1cuy;
      0xbeuy; 0x04uy; 0x1auy; 0xf5uy; 0x80uy; 0x41uy; 0x20uy; 0x1buy; 0x78uy; 0x5auy; 0x15uy; 0x7fuy;
      0xbbuy; 0xceuy; 0x85uy; 0xbcuy; 0xb8uy; 0x69uy; 0x89uy; 0x60uy; 0xf2uy; 0xf6uy; 0x68uy; 0x85uy;
      0x23uy; 0x84uy; 0x49uy; 0xa5uy; 0x79uy; 0xbeuy; 0xa7uy; 0x32uy; 0x98uy; 0xa9uy; 0x50uy; 0xb3uy;
      0x32uy; 0xecuy; 0x8euy; 0x44uy; 0xf5uy; 0xa9uy; 0x55uy; 0x8buy; 0x41uy; 0x70uy; 0x5fuy; 0x88uy;
      0x88uy; 0x90uy; 0x9fuy; 0x13uy; 0x4cuy; 0x8euy; 0x5auy; 0x92uy; 0xd3uy; 0x2duy; 0x48uy; 0x49uy;
      0x65uy; 0x3cuy; 0x06uy; 0x41uy; 0x9euy; 0x1fuy; 0xdbuy; 0xc0uy; 0x25uy; 0x4fuy; 0xbbuy; 0x20uy;
      0x98uy; 0x11uy; 0x2auy; 0xa5uy; 0x5fuy; 0xc9uy; 0x1fuy; 0x66uy; 0xe7uy; 0xbcuy; 0x3buy; 0x68uy;
      0xdauy; 0xb9uy; 0x47uy; 0xa1uy; 0x62uy; 0x59uy; 0xb4uy; 0x72uy; 0xb4uy; 0xa8uy; 0x82uy; 0xf6uy;
      0x7cuy; 0xc7uy; 0xecuy; 0x9fuy; 0xbauy; 0xc5uy; 0x5fuy; 0xf7uy; 0xdbuy; 0x4duy; 0xe1uy; 0x9cuy;
      0xf1uy; 0xccuy; 0x1duy; 0x4duy; 0x04uy; 0xa9uy; 0x2fuy; 0xebuy; 0x16uy; 0x1duy; 0x0duy; 0xfauy;
      0x57uy; 0xc0uy; 0x94uy; 0x8fuy; 0xbcuy; 0x11uy; 0x98uy; 0x44uy; 0xabuy; 0x4cuy; 0x68uy; 0xc4uy;
      0x9auy; 0x51uy; 0xeduy; 0x97uy; 0x6buy; 0x12uy; 0x2fuy; 0xf2uy; 0xdauy; 0x68uy; 0x33uy; 0xd3uy;
      0x24uy; 0x53uy; 0x11uy; 0x9cuy; 0x32uy; 0xc6uy; 0xb2uy; 0xc1uy; 0x3auy; 0x76uy; 0xe9uy; 0x93uy;
      0x2cuy; 0xd7uy; 0xd9uy; 0xecuy; 0x60uy; 0x20uy; 0x39uy; 0xe7uy; 0x7fuy; 0x26uy; 0x5cuy; 0xd4uy;
      0xc7uy; 0xf0uy; 0xdfuy; 0xc4uy; 0xe9uy; 0x7buy; 0x09uy; 0xbfuy; 0xfauy; 0xbduy; 0xceuy; 0x8cuy;
      0x1auy; 0x84uy; 0xaeuy; 0xfduy; 0x41uy; 0x9cuy; 0x9cuy; 0x02uy; 0x69uy; 0x34uy; 0xf4uy; 0x27uy;
      0x9duy; 0x87uy; 0x23uy; 0xf9uy; 0x69uy; 0xa8uy; 0xc1uy; 0x24uy; 0xcauy; 0x44uy; 0x9buy; 0x6cuy;
      0x4auy; 0x23uy; 0x41uy; 0x17uy; 0x9fuy; 0x82uy; 0xfeuy; 0x74uy; 0xe5uy; 0x3auy; 0x6euy; 0x15uy;
      0xbfuy; 0xebuy; 0x8fuy; 0xb6uy; 0x51uy; 0x54uy; 0x86uy; 0xc5uy; 0xf7uy; 0xeauy; 0x2euy; 0xbcuy;
      0x63uy; 0x2auy; 0x18uy; 0x85uy; 0x72uy; 0x4duy; 0x6fuy; 0x56uy; 0x3buy; 0xa1uy; 0x66uy; 0x73uy;
      0xfauy; 0x59uy; 0x8auy; 0xecuy; 0xc1uy; 0x6duy; 0x49uy; 0xc3uy; 0x30uy; 0xf1uy; 0x0euy; 0x3fuy;
      0x07uy; 0xb3uy; 0x4duy; 0x58uy; 0x36uy; 0xe8uy; 0xebuy; 0xb2uy; 0xefuy; 0x9duy; 0x84uy; 0x1euy;
      0x5duy; 0xbcuy; 0xaduy; 0xa6uy; 0x4auy; 0x46uy; 0x6fuy; 0x91uy; 0xceuy; 0x14uy; 0xa5uy; 0x85uy;
      0x69uy; 0x33uy; 0x86uy; 0xa9uy; 0x57uy; 0x85uy; 0x15uy; 0x08uy; 0xeeuy; 0x76uy; 0x3buy; 0x6buy;
      0x64uy; 0x74uy; 0xe4uy; 0xf7uy; 0x4duy; 0x0fuy; 0xd5uy; 0x92uy; 0x43uy; 0x12uy; 0xaeuy; 0xbbuy;
      0x37uy; 0xc4uy; 0x13uy; 0x92uy; 0xe6uy; 0xd6uy; 0x46uy; 0xc0uy; 0xa0uy; 0xa7uy; 0xa8uy; 0xf2uy;
      0x39uy; 0x45uy; 0x72uy; 0xacuy; 0x5cuy; 0xa9uy; 0x94uy; 0x88uy; 0x2auy; 0xaauy; 0x23uy; 0x5cuy;
      0x49uy; 0x86uy; 0x2auy; 0xe4uy; 0x7buy; 0xb1uy; 0xc1uy; 0x4fuy; 0xaeuy; 0x9auy; 0xa2uy; 0x13uy;
      0x15uy; 0xf9uy; 0x20uy; 0x39uy; 0x85uy; 0x0auy; 0x3cuy; 0x9duy; 0xc6uy; 0x16uy; 0x3euy; 0x0cuy;
      0xfbuy; 0xc8uy; 0xffuy; 0xccuy; 0x3duy; 0xbfuy; 0x11uy; 0x24uy; 0x79uy; 0xe1uy; 0xeauy; 0xf8uy;
      0xb7uy; 0x98uy; 0xd6uy; 0x35uy; 0xbcuy; 0xb5uy; 0x78uy; 0x7duy; 0xcduy; 0x89uy; 0x70uy; 0xb2uy;
      0xbauy; 0x53uy; 0xeauy; 0x38uy; 0xa0uy; 0xa4uy; 0xc1uy; 0x49uy; 0xc1uy; 0xf5uy; 0x6cuy; 0xa7uy;
      0x04uy; 0x81uy; 0x12uy; 0x99uy; 0x37uy; 0x21uy; 0x93uy; 0xdbuy; 0x0euy; 0x38uy; 0xc3uy; 0xd8uy;
      0x4auy; 0xc7uy; 0xf6uy; 0x5duy; 0x5duy; 0x1fuy; 0xd1uy; 0x58uy; 0xd7uy; 0xdfuy; 0x86uy; 0xa0uy;
      0xcduy; 0xfcuy; 0xb5uy; 0xf1uy; 0xaeuy; 0x0fuy; 0x60uy; 0x6auy; 0x39uy; 0x73uy; 0xe4uy; 0x70uy;
      0xa7uy; 0xf0uy; 0x77uy; 0x59uy; 0x9duy; 0x0cuy; 0x0euy; 0x14uy; 0xa1uy; 0x5euy; 0xd5uy; 0xe8uy;
      0x6euy; 0x82uy; 0x8cuy; 0xf9uy; 0x94uy; 0x61uy; 0xb6uy; 0x2cuy; 0x0euy; 0x26uy; 0x59uy; 0xdduy;
      0xe6uy; 0x79uy; 0xdcuy; 0x21uy; 0xcfuy; 0xe1uy; 0x5duy; 0x69uy; 0xffuy; 0x0euy; 0x93uy; 0x28uy;
      0x3auy; 0x86uy; 0xa5uy; 0x47uy; 0xd8uy; 0xacuy; 0x50uy; 0x81uy; 0x2cuy; 0x95uy; 0x67uy; 0x5duy;
      0xf7uy; 0x27uy; 0xfduy; 0xa5uy; 0x20uy; 0xc3uy; 0x85uy; 0x6duy; 0x4cuy; 0xf2uy; 0xd0uy; 0xe6uy;
      0x9fuy; 0x73uy; 0xefuy; 0xd1uy; 0x7fuy; 0x84uy; 0xd5uy; 0xa1uy; 0x0cuy; 0x87uy; 0xbeuy; 0xefuy;
      0xccuy; 0xf8uy; 0xb0uy; 0x3fuy; 0x7buy; 0x30uy; 0x43uy; 0x6auy; 0xd0uy; 0x5duy; 0xafuy; 0x78uy;
      0x89uy; 0x19uy; 0x03uy; 0x09uy; 0xeeuy; 0xe1uy; 0x60uy; 0x7euy; 0xf0uy; 0x74uy; 0x87uy; 0x22uy;
      0xc1uy; 0x6duy; 0x8euy; 0x20uy; 0x34uy; 0x82uy; 0x87uy; 0x23uy; 0x45uy; 0x17uy; 0xf2uy; 0x2duy;
      0x95uy; 0xc4uy; 0xc5uy; 0x42uy; 0xb9uy; 0xa1uy; 0x07uy; 0x4cuy; 0x89uy; 0xd7uy; 0xf2uy; 0x9buy;
      0xdfuy; 0xf3uy; 0xacuy; 0xaeuy; 0x9cuy; 0x13uy; 0x5duy; 0x07uy; 0xd5uy; 0x7euy; 0x66uy; 0x34uy;
      0xd6uy; 0x15uy; 0x6euy; 0xd4uy; 0x5duy; 0x50uy; 0x7duy; 0xabuy; 0x17uy; 0x02uy; 0x58uy; 0x95uy;
      0xafuy; 0xc6uy; 0x17uy; 0x2fuy; 0xfcuy; 0xdcuy; 0x5auy; 0xbeuy; 0x5auy; 0xcbuy; 0x50uy; 0x85uy;
      0x7duy; 0x7duy; 0x3buy; 0x2auy; 0xbbuy; 0x29uy; 0xd6uy; 0xffuy; 0xecuy; 0x4cuy; 0xcfuy; 0x8euy;
      0xfauy; 0xc1uy; 0xb5uy; 0x97uy; 0x15uy; 0x07uy; 0xe8uy; 0x62uy; 0x27uy; 0x1duy; 0x28uy; 0x3duy;
      0x81uy; 0x5auy; 0xf0uy; 0x0duy; 0x98uy; 0x49uy; 0x33uy; 0x26uy; 0xdcuy; 0x56uy; 0x28uy; 0x88uy;
      0xdduy; 0x1cuy; 0x98uy; 0x52uy; 0xcauy; 0x99uy; 0xbfuy; 0xbcuy; 0xc2uy; 0xf4uy; 0x29uy; 0x85uy;
      0x5fuy; 0x5cuy; 0x56uy; 0x53uy; 0xa4uy; 0x03uy; 0x02uy; 0xcauy; 0x50uy; 0x45uy; 0xeduy; 0x96uy;
      0x10uy; 0x42uy; 0x94uy; 0x5auy; 0x14uy; 0x4euy; 0xb8uy; 0x59uy; 0x81uy; 0x04uy; 0x9auy; 0x3euy;
      0xaeuy; 0x63uy; 0xf6uy; 0xccuy; 0x17uy; 0xcauy; 0xb3uy; 0xf9uy; 0x32uy; 0xc6uy; 0x7euy; 0x56uy;
      0x3buy; 0x7cuy; 0xa4uy; 0xf1uy; 0x2cuy; 0x37uy; 0xb2uy; 0x6euy; 0x78uy; 0x09uy; 0x9buy; 0x52uy;
      0x0euy; 0x55uy; 0xfduy; 0xc2uy; 0xe2uy; 0x7cuy; 0xc4uy; 0x95uy; 0xaduy; 0xe5uy; 0x20uy; 0x6auy;
      0x12uy; 0x47uy; 0x41uy; 0x7euy; 0x02uy; 0x88uy; 0x1auy; 0x93uy; 0xe9uy; 0x5duy; 0x86uy; 0x4fuy;
      0x53uy; 0x17uy; 0x76uy; 0x33uy; 0x15uy; 0x2euy; 0x75uy; 0x3buy; 0x77uy; 0x9buy; 0x00uy; 0x1duy;
      0xc1uy; 0x27uy; 0xbbuy; 0x88uy; 0x73uy; 0x53uy; 0x71uy; 0xc7uy; 0x7buy; 0xa4uy; 0x78uy; 0xe9uy;
      0xdfuy; 0x49uy; 0xe5uy; 0xccuy; 0xb9uy; 0xc5uy; 0x91uy; 0x10uy; 0x5cuy; 0x3cuy; 0xd9uy; 0xb5uy;
      0x98uy; 0xb3uy; 0x63uy; 0x4cuy; 0xc8uy; 0x2fuy; 0x24uy; 0x16uy; 0x5duy; 0xaduy; 0x11uy; 0x83uy;
      0x9buy; 0xe1uy; 0xb8uy; 0x1euy; 0x11uy; 0xd9uy; 0x45uy; 0xe1uy; 0xd6uy; 0x90uy; 0x91uy; 0xaauy;
      0x94uy; 0x8auy; 0xb3uy; 0xc0uy; 0x4duy; 0x7auy; 0x76uy; 0xcbuy; 0x44uy; 0x02uy; 0x3auy; 0x8duy;
      0x9auy; 0x18uy; 0xbcuy; 0x6cuy
    ]

let test1_sk_expected =
  List.Tot.map u8_from_UInt8
    [
      0x4buy; 0x62uy; 0x2duy; 0xe1uy; 0x35uy; 0x01uy; 0x19uy; 0xc4uy; 0x5auy; 0x9fuy; 0x2euy; 0x2euy;
      0xf3uy; 0xdcuy; 0x5duy; 0xf5uy; 0x92uy; 0x44uy; 0x4duy; 0x91uy; 0xa2uy; 0xaduy; 0xaduy; 0x05uy;
      0x2cuy; 0xa2uy; 0x3duy; 0xe5uy; 0xfbuy; 0x9duy; 0xf9uy; 0xe1uy; 0x95uy; 0xe3uy; 0x8fuy; 0xc2uy;
      0x21uy; 0xb8uy; 0xb8uy; 0x34uy; 0x14uy; 0xfbuy; 0xd3uy; 0xefuy; 0x7cuy; 0xa2uy; 0x6buy; 0x36uy;
      0x8cuy; 0x7buy; 0x9duy; 0x81uy; 0x78uy; 0xc9uy; 0x49uy; 0x64uy; 0x4duy; 0x79uy; 0xfduy; 0x8buy;
      0x19uy; 0xb9uy; 0x51uy; 0x4cuy; 0xceuy; 0x27uy; 0x4duy; 0x64uy; 0xaauy; 0xe0uy; 0x29uy; 0x69uy;
      0x10uy; 0xaauy; 0x9fuy; 0x49uy; 0xacuy; 0x16uy; 0x1duy; 0xbcuy; 0x4euy; 0xa0uy; 0x85uy; 0xf4uy;
      0xf4uy; 0x58uy; 0x3auy; 0xb9uy; 0xaauy; 0xa9uy; 0xbduy; 0x30uy; 0xf3uy; 0xc9uy; 0x1buy; 0x6buy;
      0x4duy; 0x26uy; 0xfeuy; 0x4buy; 0x3euy; 0xc1uy; 0x88uy; 0xebuy; 0xdeuy; 0x99uy; 0x0auy; 0xa9uy;
      0xb1uy; 0x27uy; 0xc0uy; 0x28uy; 0x96uy; 0x65uy; 0xfeuy; 0x3auy; 0xf9uy; 0x0euy; 0x67uy; 0x7auy;
      0x7fuy; 0x10uy; 0x4cuy; 0x16uy; 0xaeuy; 0x2cuy; 0x0cuy; 0x72uy; 0x62uy; 0x5buy; 0x4duy; 0x3cuy;
      0x12uy; 0x21uy; 0x9auy; 0x7euy; 0x8fuy; 0x07uy; 0x51uy; 0xe0uy; 0x86uy; 0x3euy; 0x33uy; 0x98uy;
      0x9buy; 0x81uy; 0x2auy; 0x96uy; 0x99uy; 0xe2uy; 0xf9uy; 0x99uy; 0x4fuy; 0x28uy; 0x0buy; 0x76uy;
      0xcbuy; 0x32uy; 0xb8uy; 0xeauy; 0x77uy; 0xaduy; 0xa3uy; 0xe9uy; 0xaduy; 0x82uy; 0x76uy; 0xe3uy;
      0x8cuy; 0x4fuy; 0x71uy; 0x8fuy; 0xd8uy; 0xd4uy; 0xaduy; 0xb4uy; 0x5buy; 0x3fuy; 0x84uy; 0xb3uy;
      0xefuy; 0x91uy; 0x01uy; 0xb4uy; 0xaauy; 0xfeuy; 0x7buy; 0xdauy; 0xe3uy; 0x6buy; 0x9euy; 0x02uy;
      0xc2uy; 0xb7uy; 0x35uy; 0xecuy; 0x77uy; 0x15uy; 0xe1uy; 0x13uy; 0x95uy; 0x68uy; 0xd4uy; 0x18uy;
      0x44uy; 0x29uy; 0x78uy; 0x55uy; 0x47uy; 0xf5uy; 0x50uy; 0x98uy; 0x8euy; 0xf3uy; 0x01uy; 0xa1uy;
      0x71uy; 0xf5uy; 0x18uy; 0xa6uy; 0xd1uy; 0xfauy; 0xacuy; 0x90uy; 0xe1uy; 0xa8uy; 0x4duy; 0x83uy;
      0xd7uy; 0xcduy; 0xc5uy; 0x14uy; 0x1duy; 0xceuy; 0x24uy; 0x9euy; 0xc4uy; 0x7buy; 0x15uy; 0x9fuy;
      0x07uy; 0x3duy; 0x85uy; 0xf6uy; 0x1buy; 0x0duy; 0xe6uy; 0xc1uy; 0x3fuy; 0x1euy; 0x3fuy; 0x6cuy;
      0x0auy; 0xc7uy; 0x2duy; 0xa4uy; 0x9duy; 0xb2uy; 0x6euy; 0x2cuy; 0xbauy; 0xb8uy; 0x6fuy; 0xabuy;
      0x34uy; 0x3auy; 0x48uy; 0xabuy; 0x2fuy; 0x75uy; 0xabuy; 0x48uy; 0x21uy; 0x8euy; 0x59uy; 0x9duy;
      0xd0uy; 0xf7uy; 0xcduy; 0x2duy; 0xeduy; 0xc4uy; 0xb9uy; 0xaeuy; 0x1buy; 0x30uy; 0xf1uy; 0xc6uy;
      0x94uy; 0x21uy; 0xa7uy; 0x81uy; 0x58uy; 0xcfuy; 0x0euy; 0x7auy; 0xf0uy; 0xb5uy; 0x44uy; 0x42uy;
      0x1auy; 0xd4uy; 0x22uy; 0xfauy; 0x18uy; 0x0duy; 0x2cuy; 0x05uy; 0xd3uy; 0x74uy; 0xebuy; 0x90uy;
      0x11uy; 0x25uy; 0xafuy; 0x00uy; 0x3euy; 0xe7uy; 0xbeuy; 0xf1uy; 0x1euy; 0xafuy; 0x6duy; 0xd0uy;
      0x7fuy; 0xa4uy; 0x12uy; 0xcfuy; 0x4fuy; 0xc4uy; 0x65uy; 0xaauy; 0x07uy; 0x73uy; 0x5fuy; 0x22uy;
      0xa0uy; 0x32uy; 0xd4uy; 0xd5uy; 0xe5uy; 0x28uy; 0x47uy; 0x2euy; 0xb5uy; 0xc1uy; 0x2duy; 0x58uy;
      0xc2uy; 0xe9uy; 0x83uy; 0xcduy; 0x41uy; 0xa0uy; 0x82uy; 0x63uy; 0x92uy; 0x76uy; 0xc3uy; 0x51uy;
      0x05uy; 0xf0uy; 0x6fuy; 0x18uy; 0xeduy; 0xb7uy; 0x7buy; 0x87uy; 0xcbuy; 0x90uy; 0x16uy; 0x63uy;
      0x3buy; 0x67uy; 0xc1uy; 0x3auy; 0xbbuy; 0x66uy; 0x0buy; 0xcduy; 0x9duy; 0x9buy; 0x38uy; 0x7fuy;
      0xa1uy; 0x91uy; 0x14uy; 0x07uy; 0x7fuy; 0xcfuy; 0x1fuy; 0x11uy; 0x31uy; 0xf7uy; 0x95uy; 0x89uy;
      0xf7uy; 0x35uy; 0x34uy; 0x11uy; 0xa5uy; 0x5cuy; 0xabuy; 0x70uy; 0x05uy; 0xdduy; 0x38uy; 0xc1uy;
      0x7auy; 0x42uy; 0x89uy; 0x6duy; 0x13uy; 0xdcuy; 0x16uy; 0xaauy; 0xbcuy; 0x43uy; 0xc2uy; 0x20uy;
      0x0fuy; 0xd2uy; 0x21uy; 0x3euy; 0x15uy; 0x76uy; 0x6fuy; 0x82uy; 0xefuy; 0x29uy; 0x96uy; 0x4cuy;
      0xd5uy; 0xf4uy; 0x79uy; 0x3auy; 0x29uy; 0x54uy; 0xabuy; 0xc3uy; 0x37uy; 0xbbuy; 0x8cuy; 0x2auy;
      0x86uy; 0x5duy; 0x76uy; 0x31uy; 0xc8uy; 0xc1uy; 0x30uy; 0x47uy; 0x7auy; 0xceuy; 0x37uy; 0xf0uy;
      0xe0uy; 0xe3uy; 0x64uy; 0x6auy; 0xdduy; 0xb1uy; 0x7duy; 0x59uy; 0x17uy; 0xeeuy; 0xd5uy; 0xfbuy;
      0xa9uy; 0x1buy; 0xd6uy; 0x1fuy; 0x70uy; 0x21uy; 0xa7uy; 0xdcuy; 0x55uy; 0x63uy; 0xffuy; 0xdduy;
      0xe5uy; 0xb5uy; 0x52uy; 0xc5uy; 0x7duy; 0x41uy; 0x7euy; 0x8auy; 0xdfuy; 0xc1uy; 0xf6uy; 0x03uy;
      0x8fuy; 0xc7uy; 0x52uy; 0xa3uy; 0xc7uy; 0x66uy; 0x79uy; 0x55uy; 0xeduy; 0x0euy; 0x40uy; 0x59uy;
      0xbcuy; 0x60uy; 0x13uy; 0x86uy; 0xb4uy; 0x88uy; 0x8cuy; 0xbauy; 0x9buy; 0x80uy; 0x8auy; 0x2buy;
      0x4euy; 0x80uy; 0x92uy; 0xe1uy; 0xd2uy; 0x84uy; 0x93uy; 0xb6uy; 0xc8uy; 0xb3uy; 0x23uy; 0x1duy;
      0xd3uy; 0xf7uy; 0xdduy; 0xa6uy; 0x39uy; 0x1auy; 0x65uy; 0x08uy; 0x0fuy; 0x95uy; 0x78uy; 0x89uy;
      0xafuy; 0xabuy; 0xb9uy; 0x9duy; 0x32uy; 0x89uy; 0x82uy; 0x07uy; 0xf2uy; 0x1duy; 0xc0uy; 0xbauy;
      0x30uy; 0x01uy; 0x42uy; 0x9auy; 0xccuy; 0x8euy; 0x16uy; 0x7auy; 0xc0uy; 0xd7uy; 0x4auy; 0x91uy;
      0xe0uy; 0x46uy; 0xf5uy; 0xaeuy; 0xe0uy; 0xeduy; 0x0auy; 0x2cuy; 0xe1uy; 0xafuy; 0x40uy; 0xf1uy;
      0x4duy; 0x18uy; 0x71uy; 0x5euy; 0xd3uy; 0x6cuy; 0x9cuy; 0x52uy; 0x70uy; 0xfduy; 0xd2uy; 0xacuy;
      0x05uy; 0xf6uy; 0xcbuy; 0x22uy; 0x9fuy; 0x04uy; 0x8duy; 0xd0uy; 0x25uy; 0xe1uy; 0xfbuy; 0xeduy;
      0x19uy; 0x7euy; 0x65uy; 0x51uy; 0x60uy; 0xccuy; 0x88uy; 0xceuy; 0xdauy; 0xf5uy; 0xaduy; 0xfduy;
      0x63uy; 0xd2uy; 0x62uy; 0x3fuy; 0x98uy; 0x05uy; 0xbfuy; 0xd9uy; 0xaeuy; 0x16uy; 0x90uy; 0xdbuy;
      0x1euy; 0x15uy; 0x2euy; 0xb0uy; 0xcduy; 0x95uy; 0x8cuy; 0x27uy; 0x6auy; 0xd9uy; 0x1buy; 0xc1uy;
      0xdduy; 0x02uy; 0xa9uy; 0x92uy; 0x9auy; 0x9euy; 0x2buy; 0x25uy; 0xebuy; 0x82uy; 0x65uy; 0xcfuy;
      0x5euy; 0x25uy; 0x8cuy; 0x5euy; 0xc3uy; 0x2auy; 0x85uy; 0x50uy; 0x67uy; 0x78uy; 0x6cuy; 0xe5uy;
      0x8fuy; 0xdbuy; 0x56uy; 0xd3uy; 0x73uy; 0x64uy; 0x83uy; 0xaauy; 0xe6uy; 0x97uy; 0x2duy; 0x90uy;
      0x9cuy; 0xb3uy; 0x59uy; 0xf5uy; 0xeeuy; 0x59uy; 0xe3uy; 0x05uy; 0xb1uy; 0xa1uy; 0x45uy; 0x4cuy;
      0xcfuy; 0x94uy; 0x3euy; 0x5cuy; 0x15uy; 0x06uy; 0xf9uy; 0x5cuy; 0xc3uy; 0x82uy; 0x22uy; 0x71uy;
      0x2buy; 0x42uy; 0xb5uy; 0xd5uy; 0x44uy; 0x8fuy; 0xf8uy; 0x64uy; 0x54uy; 0x75uy; 0x03uy; 0xcfuy;
      0xdduy; 0x91uy; 0x6buy; 0x05uy; 0x09uy; 0x24uy; 0x7fuy; 0xd5uy; 0x97uy; 0x3euy; 0xa4uy; 0x7cuy;
      0x65uy; 0x0auy; 0x42uy; 0x6buy; 0x64uy; 0xa2uy; 0xd8uy; 0x81uy; 0x4fuy; 0xc0uy; 0xecuy; 0xd8uy;
      0x79uy; 0x4cuy; 0xcbuy; 0x9cuy; 0x27uy; 0xbcuy; 0x60uy; 0x6fuy; 0xe2uy; 0x49uy; 0x9buy; 0x44uy;
      0x93uy; 0x6duy; 0xa4uy; 0x74uy; 0x04uy; 0x1cuy; 0x81uy; 0xf9uy; 0x01uy; 0x8fuy; 0xd2uy; 0x4duy;
      0xaduy; 0x07uy; 0x9auy; 0xbbuy; 0x11uy; 0xc8uy; 0x76uy; 0x64uy; 0x29uy; 0xfeuy; 0xa4uy; 0x1auy;
      0x25uy; 0x05uy; 0x4auy; 0xafuy; 0x59uy; 0xa9uy; 0x88uy; 0xf7uy; 0x73uy; 0x12uy; 0x60uy; 0xd4uy;
      0x12uy; 0x01uy; 0x68uy; 0xf5uy; 0xbeuy; 0xc5uy; 0xb2uy; 0x7buy; 0xdcuy; 0xebuy; 0x96uy; 0xecuy;
      0x43uy; 0x5duy; 0xc2uy; 0x07uy; 0xb4uy; 0x1duy; 0xf7uy; 0x78uy; 0xa7uy; 0x82uy; 0x8duy; 0x10uy;
      0x0buy; 0x90uy; 0xebuy; 0x5cuy; 0x1euy; 0x49uy; 0x7buy; 0xdduy; 0x56uy; 0xc7uy; 0x5fuy; 0x0fuy;
      0x8fuy; 0x9auy; 0x21uy; 0xcfuy; 0xa4uy; 0x63uy; 0x20uy; 0x0cuy; 0xe5uy; 0xf7uy; 0xc2uy; 0xdfuy;
      0xf1uy; 0xecuy; 0xf3uy; 0x94uy; 0x5buy; 0xaduy; 0x29uy; 0xdduy; 0x0buy; 0x43uy; 0x19uy; 0xabuy;
      0x93uy; 0xecuy; 0x7duy; 0x50uy; 0x6buy; 0x67uy; 0xf5uy; 0x2fuy; 0xf1uy; 0xe7uy; 0x4buy; 0xe2uy;
      0x35uy; 0x41uy; 0x47uy; 0xd8uy; 0xcfuy; 0x9auy; 0xbbuy; 0x38uy; 0x3auy; 0x37uy; 0xc3uy; 0x61uy;
      0x43uy; 0xa4uy; 0x41uy; 0xabuy; 0x4duy; 0x9buy; 0xd9uy; 0xbfuy; 0x19uy; 0x6euy; 0x66uy; 0xa1uy;
      0xfduy; 0xefuy; 0x54uy; 0x6fuy; 0xefuy; 0x1euy; 0xe0uy; 0x26uy; 0xabuy; 0xe3uy; 0xf5uy; 0xe7uy;
      0x22uy; 0xd0uy; 0x84uy; 0x6euy; 0x78uy; 0x90uy; 0x70uy; 0xc3uy; 0x87uy; 0x6auy; 0x68uy; 0xb8uy;
      0x5fuy; 0x80uy; 0x10uy; 0xb3uy; 0x8fuy; 0x56uy; 0xffuy; 0x16uy; 0xf9uy; 0x88uy; 0x67uy; 0x1auy;
      0x51uy; 0x3cuy; 0xf8uy; 0x27uy; 0x40uy; 0xbbuy; 0x69uy; 0x6euy; 0xcbuy; 0x80uy; 0xa4uy; 0x0duy;
      0xb6uy; 0xb2uy; 0x66uy; 0xbduy; 0xa2uy; 0xcbuy; 0xfeuy; 0xd7uy; 0x67uy; 0x5fuy; 0xfauy; 0x85uy;
      0xd0uy; 0x98uy; 0x1euy; 0x5duy; 0x35uy; 0x01uy; 0x91uy; 0x3fuy; 0x91uy; 0x46uy; 0xacuy; 0xcduy;
      0x82uy; 0xd3uy; 0xe1uy; 0x5cuy; 0x53uy; 0x66uy; 0xa7uy; 0xa1uy; 0x00uy; 0xd5uy; 0x34uy; 0x3fuy;
      0x1euy; 0x1euy; 0x0fuy; 0x1cuy; 0xefuy; 0x5duy; 0x2euy; 0x79uy; 0x28uy; 0x02uy; 0xbeuy; 0x9buy;
      0x8buy; 0xfauy; 0x5auy; 0x0auy; 0xf3uy; 0xfcuy; 0x8cuy; 0xdcuy; 0xbduy; 0xa3uy; 0xb6uy; 0xd3uy;
      0x5buy; 0xe0uy; 0xfbuy; 0xeeuy; 0x63uy; 0xd3uy; 0x72uy; 0x5auy; 0xfbuy; 0xffuy; 0x03uy; 0x00uy;
      0x00uy; 0x00uy; 0x03uy; 0x00uy; 0xfeuy; 0xffuy; 0xfduy; 0xffuy; 0x01uy; 0x00uy; 0xffuy; 0xffuy;
      0x02uy; 0x00uy; 0x02uy; 0x00uy; 0xfeuy; 0xffuy; 0x01uy; 0x00uy; 0x03uy; 0x00uy; 0xffuy; 0xffuy;
      0xfbuy; 0xffuy; 0xfeuy; 0xffuy; 0x06uy; 0x00uy; 0x06uy; 0x00uy; 0x01uy; 0x00uy; 0xfcuy; 0xffuy;
      0xfduy; 0xffuy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x01uy; 0x00uy; 0xffuy; 0xffuy; 0x00uy; 0x00uy;
      0xfcuy; 0xffuy; 0x02uy; 0x00uy; 0x04uy; 0x00uy; 0x01uy; 0x00uy; 0x02uy; 0x00uy; 0xffuy; 0xffuy;
      0x02uy; 0x00uy; 0x03uy; 0x00uy; 0x01uy; 0x00uy; 0xfeuy; 0xffuy; 0x04uy; 0x00uy; 0xfeuy; 0xffuy;
      0x06uy; 0x00uy; 0xffuy; 0xffuy; 0x03uy; 0x00uy; 0x00uy; 0x00uy; 0xfduy; 0xffuy; 0x00uy; 0x00uy;
      0x00uy; 0x00uy; 0x00uy; 0x00uy; 0xffuy; 0xffuy; 0x01uy; 0x00uy; 0xfduy; 0xffuy; 0xfeuy; 0xffuy;
      0x00uy; 0x00uy; 0xfeuy; 0xffuy; 0x04uy; 0x00uy; 0xfduy; 0xffuy; 0xfduy; 0xffuy; 0x00uy; 0x00uy;
      0xffuy; 0xffuy; 0xfbuy; 0xffuy; 0x00uy; 0x00uy; 0x01uy; 0x00uy; 0xfeuy; 0xffuy; 0xfbuy; 0xffuy;
      0x02uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0xfeuy; 0xffuy; 0xfeuy; 0xffuy; 0xffuy; 0xffuy;
      0x06uy; 0x00uy; 0xffuy; 0xffuy; 0x00uy; 0x00uy; 0xfeuy; 0xffuy; 0x01uy; 0x00uy; 0x02uy; 0x00uy;
      0x01uy; 0x00uy; 0x01uy; 0x00uy; 0x01uy; 0x00uy; 0xffuy; 0xffuy; 0xffuy; 0xffuy; 0x01uy; 0x00uy;
      0xfbuy; 0xffuy; 0x05uy; 0x00uy; 0x02uy; 0x00uy; 0xfduy; 0xffuy; 0x02uy; 0x00uy; 0x05uy; 0x00uy;
      0xfduy; 0xffuy; 0x04uy; 0x00uy; 0x02uy; 0x00uy; 0x04uy; 0x00uy; 0xfbuy; 0xffuy; 0xfeuy; 0xffuy;
      0x01uy; 0x00uy; 0x02uy; 0x00uy; 0xfcuy; 0xffuy; 0x03uy; 0x00uy; 0x00uy; 0x00uy; 0x01uy; 0x00uy;
      0x02uy; 0x00uy; 0xffuy; 0xffuy; 0xffuy; 0xffuy; 0xffuy; 0xffuy; 0xfcuy; 0xffuy; 0x01uy; 0x00uy;
      0xffuy; 0xffuy; 0x01uy; 0x00uy; 0xfduy; 0xffuy; 0x03uy; 0x00uy; 0x00uy; 0x00uy; 0x04uy; 0x00uy;
      0xffuy; 0xffuy; 0xfcuy; 0xffuy; 0x01uy; 0x00uy; 0x03uy; 0x00uy; 0xffuy; 0xffuy; 0x00uy; 0x00uy;
      0x01uy; 0x00uy; 0x02uy; 0x00uy; 0xfduy; 0xffuy; 0xfeuy; 0xffuy; 0x01uy; 0x00uy; 0xffuy; 0xffuy;
      0x03uy; 0x00uy; 0xffuy; 0xffuy; 0xffuy; 0xffuy; 0xfeuy; 0xffuy; 0xfduy; 0xffuy; 0x01uy; 0x00uy;
      0xfeuy; 0xffuy; 0x03uy; 0x00uy; 0x02uy; 0x00uy; 0xffuy; 0xffuy; 0x01uy; 0x00uy; 0xfeuy; 0xffuy;
      0x00uy; 0x00uy; 0xffuy; 0xffuy; 0xfduy; 0xffuy; 0xffuy; 0xffuy; 0x01uy; 0x00uy; 0xffuy; 0xffuy;
      0x02uy; 0x00uy; 0x02uy; 0x00uy; 0xfeuy; 0xffuy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x01uy; 0x00uy;
      0xfauy; 0xffuy; 0x02uy; 0x00uy; 0x04uy; 0x00uy; 0xfduy; 0xffuy; 0xffuy; 0xffuy; 0x02uy; 0x00uy;
      0x03uy; 0x00uy; 0x08uy; 0x00uy; 0xfbuy; 0xffuy; 0x03uy; 0x00uy; 0x00uy; 0x00uy; 0xfduy; 0xffuy;
      0x08uy; 0x00uy; 0x04uy; 0x00uy; 0xfduy; 0xffuy; 0x02uy; 0x00uy; 0x02uy; 0x00uy; 0x01uy; 0x00uy;
      0x04uy; 0x00uy; 0x00uy; 0x00uy; 0xfduy; 0xffuy; 0xffuy; 0xffuy; 0xffuy; 0xffuy; 0x00uy; 0x00uy;
      0x01uy; 0x00uy; 0x02uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x04uy; 0x00uy;
      0xffuy; 0xffuy; 0x01uy; 0x00uy; 0xffuy; 0xffuy; 0x01uy; 0x00uy; 0xfduy; 0xffuy; 0x01uy; 0x00uy;
      0xffuy; 0xffuy; 0x01uy; 0x00uy; 0x01uy; 0x00uy; 0x06uy; 0x00uy; 0xfeuy; 0xffuy; 0x01uy; 0x00uy;
      0xfduy; 0xffuy; 0xfeuy; 0xffuy; 0x00uy; 0x00uy; 0x02uy; 0x00uy; 0xfcuy; 0xffuy; 0xffuy; 0xffuy;
      0x00uy; 0x00uy; 0xffuy; 0xffuy; 0x02uy; 0x00uy; 0x00uy; 0x00uy; 0xfduy; 0xffuy; 0xfeuy; 0xffuy;
      0x05uy; 0x00uy; 0x05uy; 0x00uy; 0xfeuy; 0xffuy; 0x03uy; 0x00uy; 0x02uy; 0x00uy; 0x04uy; 0x00uy;
      0x00uy; 0x00uy; 0x01uy; 0x00uy; 0x05uy; 0x00uy; 0x02uy; 0x00uy; 0xfcuy; 0xffuy; 0xfeuy; 0xffuy;
      0x01uy; 0x00uy; 0xffuy; 0xffuy; 0xffuy; 0xffuy; 0x02uy; 0x00uy; 0xffuy; 0xffuy; 0xfcuy; 0xffuy;
      0xfeuy; 0xffuy; 0x02uy; 0x00uy; 0xfcuy; 0xffuy; 0xfeuy; 0xffuy; 0xfduy; 0xffuy; 0xfcuy; 0xffuy;
      0x02uy; 0x00uy; 0xffuy; 0xffuy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0xfcuy; 0xffuy; 0x04uy; 0x00uy;
      0x01uy; 0x00uy; 0x04uy; 0x00uy; 0xfduy; 0xffuy; 0xffuy; 0xffuy; 0xfbuy; 0xffuy; 0xfduy; 0xffuy;
      0xffuy; 0xffuy; 0x04uy; 0x00uy; 0x03uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0xfcuy; 0xffuy;
      0x01uy; 0x00uy; 0xfduy; 0xffuy; 0xffuy; 0xffuy; 0xfduy; 0xffuy; 0x03uy; 0x00uy; 0xffuy; 0xffuy;
      0xfeuy; 0xffuy; 0x05uy; 0x00uy; 0x01uy; 0x00uy; 0x03uy; 0x00uy; 0xfauy; 0xffuy; 0x02uy; 0x00uy;
      0x00uy; 0x00uy; 0xfeuy; 0xffuy; 0xfeuy; 0xffuy; 0x02uy; 0x00uy; 0xfeuy; 0xffuy; 0xfduy; 0xffuy;
      0xffuy; 0xffuy; 0x01uy; 0x00uy; 0x04uy; 0x00uy; 0x01uy; 0x00uy; 0x01uy; 0x00uy; 0x06uy; 0x00uy;
      0x04uy; 0x00uy; 0xffuy; 0xffuy; 0x02uy; 0x00uy; 0xfcuy; 0xffuy; 0x01uy; 0x00uy; 0x02uy; 0x00uy;
      0xffuy; 0xffuy; 0x00uy; 0x00uy; 0x01uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0xfeuy; 0xffuy;
      0xfeuy; 0xffuy; 0x02uy; 0x00uy; 0xffuy; 0xffuy; 0xffuy; 0xffuy; 0x05uy; 0x00uy; 0x01uy; 0x00uy;
      0xfeuy; 0xffuy; 0x01uy; 0x00uy; 0x02uy; 0x00uy; 0x01uy; 0x00uy; 0xfeuy; 0xffuy; 0xfduy; 0xffuy;
      0x01uy; 0x00uy; 0xfeuy; 0xffuy; 0x03uy; 0x00uy; 0x03uy; 0x00uy; 0x02uy; 0x00uy; 0x04uy; 0x00uy;
      0x06uy; 0x00uy; 0x01uy; 0x00uy; 0x00uy; 0x00uy; 0xfeuy; 0xffuy; 0xfeuy; 0xffuy; 0x02uy; 0x00uy;
      0xfeuy; 0xffuy; 0x02uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x01uy; 0x00uy; 0x01uy; 0x00uy;
      0x00uy; 0x00uy; 0x03uy; 0x00uy; 0xfcuy; 0xffuy; 0xfeuy; 0xffuy; 0xffuy; 0xffuy; 0xfbuy; 0xffuy;
      0xfduy; 0xffuy; 0x04uy; 0x00uy; 0x01uy; 0x00uy; 0x02uy; 0x00uy; 0x01uy; 0x00uy; 0xffuy; 0xffuy;
      0xfeuy; 0xffuy; 0xffuy; 0xffuy; 0xfcuy; 0xffuy; 0xfcuy; 0xffuy; 0x06uy; 0x00uy; 0x00uy; 0x00uy;
      0xfduy; 0xffuy; 0xfduy; 0xffuy; 0xffuy; 0xffuy; 0xfeuy; 0xffuy; 0xffuy; 0xffuy; 0xffuy; 0xffuy;
      0x03uy; 0x00uy; 0xfbuy; 0xffuy; 0x02uy; 0x00uy; 0x02uy; 0x00uy; 0xfduy; 0xffuy; 0xfduy; 0xffuy;
      0x02uy; 0x00uy; 0x02uy; 0x00uy; 0x02uy; 0x00uy; 0x03uy; 0x00uy; 0xfcuy; 0xffuy; 0xfbuy; 0xffuy;
      0x01uy; 0x00uy; 0x04uy; 0x00uy; 0x03uy; 0x00uy; 0x00uy; 0x00uy; 0xfduy; 0xffuy; 0xfduy; 0xffuy;
      0xfduy; 0xffuy; 0xffuy; 0xffuy; 0x00uy; 0x00uy; 0x01uy; 0x00uy; 0xf8uy; 0xffuy; 0x01uy; 0x00uy;
      0x00uy; 0x00uy; 0xfeuy; 0xffuy; 0xfcuy; 0xffuy; 0x01uy; 0x00uy; 0x02uy; 0x00uy; 0xfeuy; 0xffuy;
      0xffuy; 0xffuy; 0xffuy; 0xffuy; 0x04uy; 0x00uy; 0x02uy; 0x00uy; 0xfduy; 0xffuy; 0x01uy; 0x00uy;
      0xfduy; 0xffuy; 0x04uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x01uy; 0x00uy; 0x00uy; 0x00uy;
      0x00uy; 0x00uy; 0x02uy; 0x00uy; 0x01uy; 0x00uy; 0x03uy; 0x00uy; 0x03uy; 0x00uy; 0xfauy; 0xffuy;
      0x03uy; 0x00uy; 0x00uy; 0x00uy; 0x02uy; 0x00uy; 0xffuy; 0xffuy; 0x01uy; 0x00uy; 0xfeuy; 0xffuy;
      0x01uy; 0x00uy; 0x04uy; 0x00uy; 0x03uy; 0x00uy; 0x01uy; 0x00uy; 0xfeuy; 0xffuy; 0xfduy; 0xffuy;
      0xffuy; 0xffuy; 0xffuy; 0xffuy; 0x01uy; 0x00uy; 0x05uy; 0x00uy; 0x02uy; 0x00uy; 0x02uy; 0x00uy;
      0xfduy; 0xffuy; 0x02uy; 0x00uy; 0xfeuy; 0xffuy; 0x03uy; 0x00uy; 0x01uy; 0x00uy; 0x01uy; 0x00uy;
      0x00uy; 0x00uy; 0x03uy; 0x00uy; 0x03uy; 0x00uy; 0xfeuy; 0xffuy; 0x00uy; 0x00uy; 0x02uy; 0x00uy;
      0xfcuy; 0xffuy; 0x02uy; 0x00uy; 0x02uy; 0x00uy; 0xfeuy; 0xffuy; 0x04uy; 0x00uy; 0x01uy; 0x00uy;
      0x06uy; 0x00uy; 0xfduy; 0xffuy; 0xfduy; 0xffuy; 0x03uy; 0x00uy; 0x00uy; 0x00uy; 0xfduy; 0xffuy;
      0xfeuy; 0xffuy; 0xffuy; 0xffuy; 0xffuy; 0xffuy; 0xfeuy; 0xffuy; 0x07uy; 0x00uy; 0x01uy; 0x00uy;
      0xffuy; 0xffuy; 0xffuy; 0xffuy; 0x01uy; 0x00uy; 0xfcuy; 0xffuy; 0xfduy; 0xffuy; 0x01uy; 0x00uy;
      0xffuy; 0xffuy; 0x03uy; 0x00uy; 0xffuy; 0xffuy; 0x00uy; 0x00uy; 0x03uy; 0x00uy; 0xffuy; 0xffuy;
      0x02uy; 0x00uy; 0xffuy; 0xffuy; 0x00uy; 0x00uy; 0xfeuy; 0xffuy; 0xffuy; 0xffuy; 0xfeuy; 0xffuy;
      0x02uy; 0x00uy; 0xfbuy; 0xffuy; 0xfcuy; 0xffuy; 0x01uy; 0x00uy; 0xffuy; 0xffuy; 0x01uy; 0x00uy;
      0x02uy; 0x00uy; 0xfduy; 0xffuy; 0xfeuy; 0xffuy; 0xfbuy; 0xffuy; 0x00uy; 0x00uy; 0xffuy; 0xffuy;
      0x03uy; 0x00uy; 0x01uy; 0x00uy; 0x03uy; 0x00uy; 0x01uy; 0x00uy; 0x01uy; 0x00uy; 0x01uy; 0x00uy;
      0xffuy; 0xffuy; 0xfauy; 0xffuy; 0x03uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0x00uy; 0xfbuy; 0xffuy;
      0xffuy; 0xffuy; 0x02uy; 0x00uy; 0xffuy; 0xffuy; 0x00uy; 0x00uy; 0xfeuy; 0xffuy; 0x05uy; 0x00uy;
      0x05uy; 0x00uy; 0x01uy; 0x00uy; 0xfeuy; 0xffuy; 0x01uy; 0x00uy; 0x01uy; 0x00uy; 0x03uy; 0x00uy;
      0xfeuy; 0xffuy; 0xffuy; 0xffuy; 0xfeuy; 0xffuy; 0x05uy; 0x00uy; 0x02uy; 0x00uy; 0xfcuy; 0xffuy;
      0xfeuy; 0xffuy; 0x05uy; 0x00uy; 0x01uy; 0x00uy; 0x00uy; 0x00uy; 0xfcuy; 0xffuy; 0x02uy; 0x00uy;
      0xfeuy; 0xffuy; 0x01uy; 0x00uy; 0xfcuy; 0xffuy; 0x02uy; 0x00uy; 0x01uy; 0x00uy; 0x03uy; 0x00uy;
      0x00uy; 0x00uy; 0xffuy; 0xffuy; 0xfbuy; 0xffuy; 0xfduy; 0xffuy; 0x00uy; 0x00uy; 0x02uy; 0x00uy;
      0x02uy; 0x00uy; 0xfbuy; 0xffuy; 0xfduy; 0xffuy; 0xfduy; 0xffuy; 0xffuy; 0xffuy; 0x01uy; 0x00uy
    ]

let test () : ML unit =
  assert_norm (List.Tot.length test1_enccoins == 16);
  assert_norm (List.Tot.length test1_keypaircoins == 2 * crypto_bytes + bytes_seed_a);
  assert_norm (List.Tot.length test1_enccoins == bytes_mu);
  assert_norm (List.Tot.length test1_ss_expected == crypto_bytes);
  assert_norm (List.Tot.length test1_pk_expected == crypto_publickeybytes);
  assert_norm (List.Tot.length test1_ct_expected == crypto_ciphertextbytes);
  assert_norm (List.Tot.length test1_sk_expected == crypto_secretkeybytes);
  let result =
    test_frodo test1_keypaircoins
      test1_enccoins
      test1_ss_expected
      test1_pk_expected
      test1_ct_expected
      test1_sk_expected
  in
  if result
  then IO.print_string "\n\nFrodoKEM : Success!\n"
  else IO.print_string "\n\nFrodoKEM: Failure :(\n"
