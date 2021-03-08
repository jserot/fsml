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

type t = {
  id: string;
  states: (State.t * Valuation.t) list;
  inps: (string * Types.t) list;
  outps: (string * Types.t) list;
  vars: (string * Types.t) list;
  trans: Transition.t list;
  itrans: State.t * Action.t list;
} [@@deriving show {with_path=false}, yojson]

(* Transformation functions *)
       
exception Unknown_output of string
                          
let mealy_outp m o =
  let remove_outp_assignation o ov =
    List.filter (fun (o',_) -> o <> o') ov in
  let add_incoming_action s act ((src,guard,acts,dst) as t) =
    if dst = s then (src, guard, act::acts, dst)
    else t in
  let add_incoming_action' s act ((dst,acts) as t) =
    if dst = s then
      (dst, act::acts)
    else
      t in
  let move_output_from_state o m (s,ovs) =
    match List.assoc_opt o ovs with
    | Some v ->
       let act = Action.Assign (o,v) in
      { m with states = Misc.replace_assoc s (remove_outp_assignation o ovs) m.states;
               trans = List.map (add_incoming_action s act) m.trans;
               itrans = add_incoming_action' s act m.itrans }
    | None ->
       m in
  if List.mem_assoc o m.outps then
    List.fold_left (move_output_from_state o) m m.states
  else
    raise (Unknown_output o)
  
let mealy_outps ?(outps=[]) m =
  let os = match outps with
    | [] -> List.map fst m.outps
    | _ -> outps in
  List.fold_left mealy_outp m os

let moore_outp m o =
  let move_output_to_state o m (s,ovs) =
    (* If all transitions ending in [s] carry the same, constant, assignation of [o], add it to [ovs] *)
    let get_assignation acts =
      match
        List.find_opt
          (function Action.Assign (o',e) -> o'=o && Expr.is_const e)
          acts with
      | None -> None
      | Some (Action.Assign (_,e)) -> Some e in
    let remove_action acts = List.filter (function Action.Assign (o',_) -> o'<>o) acts in
    let remove_incoming_action ((src,guards,acts,dst) as t) =
      if dst = s then (src, guards, remove_action acts, dst)
      else t in
    let remove_incoming_action' ((dst,acts) as t) =
      if dst = s then (dst, remove_action acts)
      else t in
    let ts = m.trans
             |> List.filter (fun (_,_,_,dst) -> dst=s)
             |> List.map (fun (_,_,acts,_) -> get_assignation acts) in
    match List.find_opt (function Some _ -> true | _ -> false) ts with
    | Some (Some e' as e) -> (* TO FIX : _ = t *)
       if List.for_all (function e'' -> e=e'') ts then
         (* Apply transformation ! I.e. remove assignation from all selected transitions and add it to state [s]. *)
         { m with trans = List.map remove_incoming_action m.trans;
                  itrans = remove_incoming_action' m.itrans;
                  states = Misc.replace_assoc s (Valuation.add o e' ovs) m.states }
       else
         m (* The transformation is not applicable *)
    | _ -> (* The transformation is not applicable *)
       m   
  in
  if List.mem_assoc o m.outps then
    List.fold_left (move_output_to_state o) m m.states
  else
    raise (Unknown_output o)
  
let moore_outps ?(outps=[]) m =
  let os = match outps with
    | [] -> List.map fst m.outps
    | _ -> outps in
  List.fold_left moore_outp m os

(* Serializing/deserializing fns *)
       
let to_string m =
  m |> to_yojson |> Yojson.Safe.to_string 

let from_string s = 
  match Yojson.Safe.from_string s |> of_yojson with
  | Ok v -> v
  | Error _ -> Yojson.json_error "Fsm.from_string: invalid JSON string"

let to_file ~fname m = 
  m |> to_yojson |> Yojson.Safe.to_file fname;
  Printf.printf "Wrote file %s\n" fname
  
let from_file ~fname = 
  match fname |> Yojson.Safe.from_file |> of_yojson with
  | Ok v -> v
  | Error _ -> Yojson.json_error "Fsm.from_string: invalid JSON file"
