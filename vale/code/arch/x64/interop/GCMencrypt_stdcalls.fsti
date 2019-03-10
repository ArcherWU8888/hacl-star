module GCMencrypt_stdcalls

open X64.CPU_Features_s
open FStar.HyperStack.ST
module B = LowStar.Buffer
module HS = FStar.HyperStack
module DV = LowStar.BufferView.Down
module UV = LowStar.BufferView.Up
open FStar.Mul
open Words_s
open GCM_helpers
open AES_s
open Interop.Base

let uint8_p = B.buffer UInt8.t
let uint64 = UInt64.t

let length_aux (b:uint8_p) : Lemma
  (requires B.length b = 176)
  (ensures DV.length (get_downview b) % 16 = 0) = 
    let db = get_downview b in
    DV.length_eq db

val gcm128_encrypt:
  key:Ghost.erased (Seq.seq nat32) ->
  plain_b:uint8_p ->
  plain_num:uint64 ->
  auth_b:uint8_p ->
  auth_num:uint64 ->
  iv_b:uint8_p ->
  out_b:uint8_p ->
  tag_b:uint8_p ->
  keys_b:uint8_p ->
  Stack unit
    (requires fun h0 ->
      B.disjoint plain_b out_b /\ B.disjoint auth_b out_b /\
      B.disjoint keys_b out_b /\ B.disjoint tag_b out_b /\

      (B.disjoint plain_b auth_b \/ plain_b == auth_b) /\
      (B.disjoint plain_b iv_b \/ plain_b == iv_b) /\
      (B.disjoint plain_b tag_b \/ plain_b == tag_b) /\
      (B.disjoint plain_b keys_b \/ plain_b == keys_b) /\
      (B.disjoint auth_b iv_b \/ auth_b == iv_b) /\      
      (B.disjoint auth_b tag_b \/ auth_b == tag_b) /\
      (B.disjoint auth_b keys_b \/ auth_b == keys_b) /\
      (B.disjoint iv_b out_b \/ iv_b == out_b) /\      
      (B.disjoint iv_b tag_b \/ iv_b == tag_b) /\
      (B.disjoint iv_b keys_b \/ iv_b == keys_b) /\     
      (B.disjoint tag_b keys_b \/ tag_b == keys_b) /\     
      
      B.live h0 keys_b /\ B.live h0 plain_b /\ B.live h0 iv_b /\ 
      B.live h0 out_b /\ B.live h0 tag_b /\ B.live h0 auth_b /\
      
      B.length plain_b = 16 * bytes_to_quad_size (UInt64.v plain_num) /\
      B.length auth_b = 16 * bytes_to_quad_size (UInt64.v auth_num) /\
      B.length iv_b = 16 /\
      B.length out_b = B.length plain_b /\
      B.length tag_b = 16 /\
      B.length keys_b = 176 /\

      256 * (B.length plain_b / 16) < pow2_32 /\
      4096 * (UInt64.v plain_num) < pow2_32 /\
      4096 * (UInt64.v auth_num) < pow2_32 /\
      
      256 * bytes_to_quad_size (UInt64.v auth_num) < pow2_32 /\
      256 * bytes_to_quad_size (UInt64.v plain_num) < pow2_32 /\      

      aesni_enabled /\ pclmulqdq_enabled /\
      is_aes_key_LE AES_128 (Ghost.reveal key) /\
      (let db = get_downview keys_b in
      length_aux keys_b;
      let ub = UV.mk_buffer db Views.up_view128 in
      Seq.equal (UV.as_seq h0 ub) (key_to_round_keys_LE AES_128 (Ghost.reveal key)))
    )
    (ensures fun h0 _ h1 ->
      True)
