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

(** {1 Simulation events} *)

type t = Expr.ident * Expr.e_val
  [@@deriving show {with_path=false}]
  (** [(id,v)] means that input, output or local variable [id] take value [v] *)

(** {2 Printer} *)

val to_string: t -> string
