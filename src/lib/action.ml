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

type t = 
  | Assign of Expr.ident * Expr.t        (* var/i/o, value *)
  [@@deriving show {with_path=false}, yojson]

let to_string a = match a with
  | Assign (id, expr) -> id ^ ":=" ^ Expr.to_string expr

(* Simulation *)

let perform env a = match a with
  | Assign (id, expr) -> [ id, Expr.eval env expr ]
