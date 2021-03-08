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

(** Fsm expressions *)

type ident = string 
  [@@deriving show {with_path=false}, yojson]

type t = {
  e_desc: e_desc;
  mutable e_typ: Types.t;
  }
  [@@deriving show {with_path=false}, yojson]

and e_desc = 
  EInt of int
| EBool of bool
| EVar of ident             
| EBinop of string * t * t
  [@@deriving show {with_path=false}, yojson]

type value = {
  mutable v_desc: e_val;
  mutable v_typ: Types.t;
  }
  [@@deriving show {with_path=false}]

and e_val = 
  | Int of int
  | Bool of bool
  | Prim of (e_val list -> e_val)
  | Unknown
  | Enum of string
  [@@deriving show {with_path=false}]

let of_value v = match v with
  | Int v -> { e_desc=EInt v; e_typ=Types.type_int () }
  | Bool v -> { e_desc=EBool v; e_typ=Types.TyBool }
  | _ -> failwith "Expr.of_value"

let is_const e = 
  match e.e_desc with
  | EInt _ -> true
  | EBool _ -> true
  | _ -> false

let mk_bool_expr e = { e_desc = e; e_typ = Types.TyBool }
let mk_int_expr e = { e_desc = e; e_typ = Types.type_int () }
                   
type env = (ident * e_val) list
  [@@deriving show]

exception Unbound_id of ident
exception Unknown_id of ident
exception Illegal_expr of t

let lookup_env env id = 
  try
    match List.assoc id env with
    | Unknown -> raise (Unbound_id id)
    | v -> v
  with 
    Not_found -> raise (Unknown_id id)

let update_env env (k,v) = 
  let rec scan = function
    | [] -> []
    | (k',v')::rest -> if k=k' then (k, v)::rest else (k',v')::scan rest in
  scan env

let rec eval : env -> t -> e_val = fun env exp ->
  match exp.e_desc with
  | EInt v -> Int v
  | EBool v -> Bool v
  | EVar id -> lookup_env env id 
  | EBinop (op, e1, e2) ->
     begin match lookup_env env op, eval env e1, eval env e2 with
       | Prim f, v1, v2 -> f [v1;v2]
       | _, _, _ -> raise (Illegal_expr exp)
     end

let rec to_string e = match e.e_desc with
    EInt c -> string_of_int c
  | EBool c -> if c then "'1'" else "'0'"
  | EVar n ->  n
  | EBinop (op,e1,e2) -> to_string e1 ^ op ^ to_string e2 (* TODO : add parens *)

let string_of_value v = match v with
  | Int c -> string_of_int c
  | Bool b -> if b then "'1'" else "'0'"
  | Prim _ -> "<prim>"
  | Unknown -> "<unknown>"
  | Enum s -> s



