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

exception Unknown_var of string
exception Illegal_var_type of string * Types.t

let clean m =
  let reachable_states =
    List.fold_left
      (fun acc (_,_,_,dst) -> if List.mem dst acc then acc else dst::acc)
      []
      m.trans
    @ [fst m.itrans] in
  { m with states = List.map (fun s -> s, List.assoc s m.states) reachable_states;
           trans = List.filter (fun (src,_,_,_) -> List.mem src reachable_states) m.trans
  }

let defact ~cleaned m (var,range,ival) =
  let dom_v = Misc.list_make ~f:(fun v -> Expr.Int v) ~lo:range.Types.lo ~hi:range.Types.hi in 
  let remove_guard guards = List.filter (Fun.negate @@ Expr.is_var_test var) guards in
  let remove_act acts = List.filter (function Action.Assign(v,_) when v=var -> false | _ -> true) acts in
  let filter_domain (guards,acts) (u,u') =
    (* Tells whether a pair of valuations [(u,u')] for variable [var] is compatible with the
     *    specified transition guards and actions *)
    let test_guard u expr =
      if Expr.is_var_test var expr
      then Expr.bool_val (Expr.eval (Builtins.eval_env @ [var, u]) expr)
      else true in
    let test_guards u = List.for_all (test_guard u) guards in
    let test_act u u' act = match act with
      | Action.Assign (v,exp) when v=var ->
         Expr.eval (Builtins.eval_env @ [var, u]) exp = u' 
      | _ -> test_guards u' in
    let test_acts u u' =
      match List.find_opt (function Action.Assign (v,_) when v=var -> true | _ -> false) acts with
      | Some a -> (* If the list of actions contains an assignment to [var] then it is used to restrict the domain ... *)
         test_act u u' a
      | None -> (* ... else, the domain is restricted by the list of guards *)
         List.for_all (test_guard u') guards in
    test_guards u && test_acts u u' in
  let sub_state s u = s ^ Expr.string_of_value u in
  let add_states acc (s,vv) = acc @ List.map (function u -> sub_state s u, vv) dom_v in
  let add_transitions acc ((q,guards,acts,q') as t) =
      let d2v = List.filter (filter_domain (guards,acts)) (Misc.cart_prod dom_v dom_v) in
      let guards' = remove_guard guards in
      let acts' = remove_act acts in
      acc @ List.map (fun (u,u') -> sub_state q u, guards', acts', sub_state q' u') d2v in
  let add_itransition (q,acts) = sub_state q ival, remove_act acts in
  let m' =
    { m with states = List.fold_left add_states [] m.states; 
             (* Each state [s] gives a set of states [{q^u | u in domain(v)}] *)
             trans = List.fold_left add_transitions [] m.trans;
             itrans = add_itransition m.itrans;
             vars = List.remove_assoc var m.vars
    } in
  if cleaned then clean m' else m'

let defactorize_var ?(cleaned=true) m (v,ty,iv) =
  match ty with
  | Types.TyInt (_, _, RgConst r) -> defact ~cleaned m (v,r,iv) 
  | _ -> raise (Illegal_var_type (v, ty))

let defactorize ~vars ?(cleaned=true) m =
  let lookup v = try List.assoc v m.vars with Not_found -> raise (Unknown_var v) in
  let vs = List.map (function (v,iv) -> v, Types.real_type (lookup v), iv) vars in
  List.fold_left (defactorize_var ~cleaned) m vs

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
