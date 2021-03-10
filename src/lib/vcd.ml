(**********************************************************************)
(*                                                                    *)
(*              This file is part of the FSML library                 *)
(*                     github.com/jserot/fsml                         *)
(*                                                                    *)
(*  Copyright (c) 2020-present, Jocelyn SEROT.  All rights reserved.  *)
(*                                                                    *)
(*  This source code is licensed under the license found in the       *)
(*  LICENSE file in the root directory of this source tree.           *)
(*                                                                    *)
(**********************************************************************)

open Printf
open Tevents.Ops

type vcd_config = {
    mutable clock_name: string;
    mutable default_int_size: int;
  }

let cfg = {
  clock_name = "clk";
  default_int_size = 8;
  }

let bits_of_uint s n = 
  let b = Bytes.make s '0' in
  let rec h n i =
    if i >= 0 then begin
      Bytes.set b i (if n mod 2 = 1 then '1' else '0');
      h (n/2) (i-1)
      end in
  h n (s-1);
  Bytes.to_string b

let cpl2 n x =
  let rec pow2 k = if k = 0 then 1 else 2 * pow2 (k-1) in (* Not tail recursive, but who cares, here ... *)
  pow2 n - x

let bits_of_int is_unsigned sz v = 
  if is_unsigned
  then bits_of_uint sz v
  else bits_of_uint sz (cpl2 sz (-v))

type vcd_type =
  | TyEvent
  | TyInt of bool * int (* signed/unsigned, size *)
  | TyBool
  | TyEnum of string * string list
  
let vcd_type_of ty =
  match Types.real_type ty with
  | Types.TyBool -> TyBool
  | Types.TyInt (sg, sz, _) ->
     let sg' = match sg with | Types.Const Unsigned -> true | _ -> false in
     let sz' = match sz with | Types.Const n -> n | _ -> cfg.default_int_size in
     TyInt (sg', sz') 
  | _ -> failwith ("VCD output: illegal type: " ^ Types.to_string ty)
    
let vcd_kind_of ty = match ty with
  TyEvent -> "event", 1
| TyBool  -> "wire", 1
| TyInt (_,s) -> "wire", s
| TyEnum _ -> "real", 1

let start_symbol = 33 

let signal_cnt = ref start_symbol

type vcd_signal = string * (char * vcd_type) [@@warning "-34"]

let register_signal acc (name,ty) =
    if List.mem_assoc name acc  then (* Already registered *)
      acc
    else
      let acc' = (name, (Char.chr !signal_cnt, vcd_type_of ty)) :: acc in
      incr signal_cnt;
      acc'

let register_vcd_signal (name,ty) acc =
  let acc' = (name, (Char.chr !signal_cnt, ty)) :: acc in
  incr signal_cnt;
  acc'

let register_fsm_signals f acc =
     List.fold_left register_signal acc (f.Fsm.inps @ f.Fsm.outps @ f.Fsm.vars)
  |> register_vcd_signal ("state", TyEnum ("t_state", List.map fst f.Fsm.states))

exception Error of string

let dump_event oc signals (t,evs) =
  let dump_scalar_event (name,v) = 
    let (id,ty) =
      try List.assoc name signals
      with Not_found -> raise (Error ("unknown signal: " ^ name)) in
    match ty, v with
        TyEvent, _ -> fprintf oc "1%c\n" id          (* Clock *)
      | TyBool, Expr.Bool b -> fprintf oc "b%d %c\n" (if b then 1 else 0) id
      | TyInt (sg,sz), Expr.Int n -> fprintf oc "b%s %c\n" (bits_of_int sg sz n) id
      | TyEnum _, Expr.Enum e -> fprintf oc "s%s %c\n" e id
      | _, _-> () in
  fprintf oc "#%d\n" t;
  List.iter dump_scalar_event evs

let dump_signal oc (name,(id,ty)) =
     let kind, size =  vcd_kind_of ty in
     fprintf oc "$var %s %d %c %s $end\n" kind size id name
  
let write ~fname ~fsm evs =
  let oc = open_out fname in
  let signals =
    []
    |> register_fsm_signals fsm
    |> register_vcd_signal (cfg.clock_name, TyEvent) in
  (* fprintf oc "$date\n";
   * fprintf oc "   %s\n" (Misc.time_of_day());
   * fprintf oc "$end\n"; *)
  (* fprintf oc "$version\n";
   * fprintf oc "   FSML %s\n" Version.version;
   * fprintf oc "$end\n"; *)
  fprintf oc "$timescale 1ns $end\n";
  fprintf oc "$scope module top $end\n";
  List.iter (dump_signal oc) signals;
  fprintf oc "$upscope $end\n";
  fprintf oc "$enddefinitions\n$end\n";
  let clk_evs = 
    let tf = match evs with
      | [] -> 0
      | _ -> evs |> List.rev |> List.hd |> fst in
    Misc.list_make ~lo:0 ~hi:tf ~f:(fun t -> t, ["clk", Expr.Unknown]) in
  List.iter (dump_event oc signals) (evs @@@ clk_evs);
  printf "Wrote file %s\n" fname;
  close_out oc  

let view ?(fname="") ?(cmd="gtkwave") ~fsm evs = 
  let fname = match fname with
    | "" -> "/tmp/" ^ fsm.Fsm.id ^ "_sim.vcd"
    | _ -> fname in
  let _ = write ~fname ~fsm evs in
  Sys.command (cmd ^ " " ^ fname)
