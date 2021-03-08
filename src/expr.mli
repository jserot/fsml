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

(** {1 Simple (int) expressions for FSMs} *)

type ident = string 
  [@@deriving show {with_path=false}, yojson]
  (** The type of identifiers occuring in expressions *)

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
  | Enum of string  (** This is a hack to allow tracing of state transitions  *)
  [@@deriving show {with_path=false}]

val of_value: e_val -> t

val is_const: t -> bool
  
(** {2 Builders} *)

val mk_bool_expr: e_desc -> t
val mk_int_expr: e_desc -> t

(** {2 Evaluation} *)
  
type env = (ident * e_val) list
  [@@deriving show]
  (** Evaluation environment  *)

(** {2 Printing} *)

val to_string: t -> string

val string_of_value: e_val -> string

(** {2 Simulation} *)

val lookup_env: env -> ident -> e_val
val update_env: env -> ident * e_val -> env
  
exception Unbound_id of ident
exception Unknown_id of ident
exception Illegal_expr of t

val eval: env -> t -> e_val
