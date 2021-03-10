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

(** Types *)

type t =
  | TyInt of sign attr * size attr * range attr
  | TyBool
  | TyArrow of t * t  (** Internal use only *)
  | TyProduct of t list  (** Internal use only *)
  | TyVar of t var  (** Internal use only *)
  [@@deriving show {with_path=false}, yojson]

and 'a attr =
  | Const of 'a
  | Var of ('a attr) var
  [@@deriving show {with_path=false}, yojson]

and 'a var =
  { stamp: string;
    mutable value: 'a value }
  [@@deriving show {with_path=false}, yojson]

and 'a value =
  | Unknown
  | Known of 'a
  [@@deriving show {with_path=false}, yojson]

and sign = Signed | Unsigned [@@deriving show {with_path=false}, yojson]
and size = int [@@deriving show {with_path=false}, yojson]
and range = { lo: int; hi: int } [@@deriving show {with_path=false}, yojson]
          
type typ_scheme =
  { ts_params: ts_params;
    ts_body: t }
  [@@deriving show {with_path=false}, yojson]

and ts_params = {
  tp_typ: (t var) list;
  tp_sign: ((sign attr) var) list;
  tp_size: ((size attr) var) list;
  tp_range: ((range attr) var) list;
  }

(** {2 Builders} *)

val new_type_var: unit -> t var
  (** [new_type_var ()] returns a fresh type variable *)
  
val new_attr_var: unit -> ('a attr) var
  (** [new_attr_var ()] returns a fresh type attribute variable *)
  
val type_int: unit -> t

val trivial_scheme: t -> typ_scheme

(** {2 Unification} *)

exception TypeConflict of t * t
exception TypeCircularity of t * t

val unify: t -> t -> unit

val type_instance: typ_scheme -> t

val real_type: t -> t
val real_attr: 'a attr -> 'a attr

exception Polymorphic of t
                       
val mono_type: t -> t
  (** Remove all type variables from type representation [t]. Raises [!Polymorphic] if 
      [t] contains unresolved type variables. *)
  
(** {2 Printing} *)
  
val to_string: t -> string
