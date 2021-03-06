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

type t = Expr.t
  (* Note: ideally, this should be [bool Expr.t] where [t] is defined as a GADT.
     Unfortunately, GADTs are not supported by most of [deriving] PPX extensions :(
     See branch [gadt] for a preliminary attempt *)
  [@@deriving show {with_path=false}, yojson]

exception Illegal_guard_expr of Expr.t

let eval env exp =
  match Expr.eval env exp with
  | Expr.Bool b -> b
  | _ -> raise (Illegal_guard_expr exp)

let to_string exp = Expr.to_string exp

