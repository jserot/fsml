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

type name = string
  [@@deriving show {with_path=false}, yojson]

type value = Expr.t
  [@@deriving show {with_path=false}, yojson]

type t = (name * value) list  (* A simple implementation using association list *)
  [@@deriving show {with_path=false}, yojson]

let empty = []

exception Duplicate of name
                     
let add n v vs = if List.mem_assoc n vs then raise (Duplicate n) else (n,v)::vs
               
let remove n vs = List.remove_assoc n vs

let mem n vs = List.mem_assoc n vs

let assoc n vs = List.assoc n vs

let compare vs1 vs2 =
  let module S = Set.Make (struct type t = name * value  let compare = Stdlib.compare end) in
  S.compare (S.of_list vs1) (S.of_list vs2)

let to_string vs = Misc.string_of_list ~f:(function (n,v) -> n ^ "=" ^ Expr.to_string v) ~sep:"," vs

exception Invalid_valuation of t

let names_of v = List.map fst v

let check names v =
  let module S = Set.Make (struct type t = string let compare = Stdlib.compare end) in
  if not (S.equal (S.of_list names) (S.of_list (names_of v))) then raise (Invalid_valuation v)
  
