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

(** {1 A [valuation] is a collection of [(name,value)] associations} *)

type name = string
  [@@deriving show {with_path=false}, yojson]

type value = Expr.t
  [@@deriving show {with_path=false}, yojson]

type t = (name * value) list (** Basic, public implementation here *)
  [@@deriving show {with_path=false}, yojson]

val compare: t -> t -> int

val to_string: t -> string

exception Invalid_valuation of t
                             
val check: name list -> t -> unit
(** [check names vs] checks whether [vs] is a "complete" valuation wrt. to [names]. {i i.e.} whether
          each variable listed in [names] has a valuation in [vs] and each variable listed in [vs] occurs in 
          [names]. Raises {!Invalid_valuation} in case of failure. *)

val empty: t

exception Duplicate of name

val add: name -> value -> t -> t

val remove: name -> t -> t

val mem: name -> t -> bool

val assoc: name -> t -> value

