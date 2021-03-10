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

type t = Event.t list Clock.clocked
  [@@deriving show {with_path=false}]

let merge2 l1 l2 =
  let rec h l1 l2 = match l1, l2 with
        [], [] -> []
      | l1, [] -> l1
      | [], l2 -> l2
      | (t1,evs1)::ss1, (t2,evs2)::ss2 ->
         if t1=t2 then (t1,evs1@evs2) :: h ss1 ss2
         else if t1<t2 then (t1,evs1) :: h ss1 l2
         else (t2,evs2) :: h l1 ss2 in
    h l1 l2

module Ops = struct
  let ( @@@ ) l1 l2 = merge2 l1 l2
end
                  
let merge ls =
  match ls with
    [] -> []
  | l::ls -> List.fold_left merge2 l ls

let changes id vcs = List.map (fun (t,v) -> (t, [id,v])) vcs
                   
let to_string (t,evs) = Printf.sprintf "t=%d: %s" t (Misc.string_of_list ~f:Event.to_string ~sep:"," evs)
