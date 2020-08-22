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

(** {1 Transition actions} *)

type t = 
  | Assign of Expr.ident * Expr.t
  [@@deriving show {with_path=false}, yojson]
  (** The type of actions associated to FSM transitions *)

(** {2 Printer} *)

val to_string: t -> string

(** {2 Simulation} *)

val perform: Expr.env -> t -> Event.t list
  (** [perform env a] performs action [a] in the context of environment [env]
       returning a list of resulting events. *)                                
