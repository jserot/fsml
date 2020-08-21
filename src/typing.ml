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

exception Typing_error of string * string * string (** what, where,  msg *)

type env = (string * Types.typ_scheme) list

let typing_error what where msg = raise (Typing_error (what, where, msg))
let unify_error what where t1 t2 =
  typing_error what where (Printf.sprintf "cannot unify types %s and %s" (Types.to_string t1) (Types.to_string t2)) 
                           

let lookup_tenv what where env id =
  try List.assoc id env
  with Not_found -> raise (Typing_error (what, where, "undefined symbol \"" ^ id ^ "\""))

let try_unify what where ty ty'  =
  try
    Types.unify ty ty';
  with
  | Types.TypeConflict _ 
  | Types.TypeCircularity _ -> unify_error what where ty ty'

(* Typing expressions *)
                                    
let rec type_expression tenv expr =
  let where = Expr.to_string expr in
  let type_expr expr = match expr.Expr.e_desc with
    Expr.EInt _ -> Types.type_int ()
  | Expr.EBool _ -> Types.TyBool
  | Expr.EVar id -> Types.type_instance @@ lookup_tenv "expression" where tenv id
  | Expr.EBinop (op,e1,e2) ->
      let ty_fn = Types.type_instance @@ lookup_tenv "expression" where tenv op in
      type_application where tenv ty_fn [e1;e2] in
  let ty = type_expr expr in
  expr.e_typ <- ty;
  ty

and type_application where tenv ty_fn args =
  let open Types in
  let ty_arg = TyProduct (List.map (type_expression tenv) args) in
  let ty_result = TyVar (Types.new_type_var ()) in
  try_unify "application" where ty_fn (TyArrow (ty_arg,ty_result));
  ty_result

(* and type_cast e t1 t2 = match t1, t2 with
 *   | TyInt _, TyInt _
 *   | TyInt _, TyBool
 *   | TyBool, TyBool
 *   | TyBool, TyInt _
 *   | _, _ -> raise (Illegal_cast e) *)

let type_check_fsm_action_ tenv act = match act with 
  | Action.Assign (id, exp) -> 
     let t = Types.type_instance @@ lookup_tenv "variable" id tenv id in
     let t' = type_expression tenv exp in
     try_unify "action" (Action.to_string act) t t'

let type_check_fsm_guard_ tenv gexp =
  let t = type_expression tenv gexp in
  try_unify "guard" (Guard.to_string gexp) t Types.TyBool

let type_check_fsm_state f s =
  if not (List.mem s f.Fsm.states)
  then typing_error "state" s "invalid state"

let type_check_fsm_transition f tenv (src,guards,actions,dst) =
  (* For each transition [s -> s' when guards with acts] check that
     - [s] are [s'] are listed as states in [f] declaration
     - each [guardi] has type [bool]
     - for each [act]=[id:=exp] in [actions], [type(id)=type(exp)] *)
  type_check_fsm_state f src;
  type_check_fsm_state f dst;
  List.iter (type_check_fsm_guard_ tenv) guards;
  List.iter (type_check_fsm_action_ tenv) actions

let type_check_fsm_itransition f tenv (s,acts) =
  (* For the initial transition [s with acts] check that
     - [s'] is listed as state if [n] declaration
     - for each [act]=[id:=exp] in [actions], [type(id)=type(exp)] *)
  type_check_fsm_state f s;
  List.iter (type_check_fsm_action_ tenv) acts

(* Final type shortening and cleaning *)

let type_clean_expression ~mono expr =
  let where = Expr.to_string expr in
  let actual_type t =
    try Types.mono_type t
    with Types.Polymorphic t ->
      if mono then typing_error "expression" where ("polymorphic type: " ^ Types.to_string t)
      else t in
  let open Expr in 
  let rec clean e = match e.e_desc with
  | EInt _
  | EBool _
  | EVar _ ->
     e.e_typ <- actual_type e.e_typ 
  | EBinop (_,e1,e2) ->
     clean e1;
     clean e2;
     e.e_typ <- actual_type e.e_typ  in
  clean expr

let type_clean_fsm_action act = match act with 
  | Action.Assign (_, exp) -> type_clean_expression exp

let type_clean_fsm_guard ~mono gexp =
  type_clean_expression ~mono gexp

let type_clean_fsm_transition ~mono (_,guards,actions,_) =
  List.iter (type_clean_fsm_guard ~mono) guards;
  List.iter (type_clean_fsm_action ~mono) actions

let type_clean_fsm_itransition ~mono (_,acts) =
  List.iter (type_clean_fsm_action ~mono) acts

let type_clean_fsm ~mono f = 
  List.iter (type_clean_fsm_transition ~mono) f.Fsm.trans;
  type_clean_fsm_itransition ~mono f.Fsm.itrans
          
let fsm_tenv ?(with_clk=false) f = 
  let open Fsm in
  List.map
      (fun (id, t) -> id, Types.trivial_scheme t)
      (f.vars @ f.inps @ f.outps)
  @ Builtins.typing_env
  @ (if with_clk then ["clk", Types.trivial_scheme (Types.type_int ())] else [])

let type_check_fsm ?(mono=false)  f =
  let tenv = fsm_tenv f in
  List.iter (type_check_fsm_transition f tenv) f.trans;
  type_check_fsm_itransition f tenv f.itrans;
  type_clean_fsm ~mono f;
  f

let type_check_fsm_guard ?(mono=false) ?(with_clk=false) f e =
  type_check_fsm_guard_ (fsm_tenv ~with_clk f) e;
  type_clean_fsm_guard ~mono e;
  e

let type_check_fsm_action ?(mono=false) f a =
  type_check_fsm_action_ (fsm_tenv f) a;
  type_clean_fsm_action ~mono a;
  a

(* Type checking values *)

let type_value v = match v with
  | Expr.Int _ -> Types.type_int ()
  | Expr.Bool _ -> Types.TyBool
  | _ -> failwith "Typing.type_value"

(* Type checking stimuli *)
  
let type_check_event f ((id,v) as e) = 
     let t = lookup_tenv "input" id f.Fsm.inps id in
     let t' = type_value v in
     try_unify "event" (Event.to_string e) t t'

let type_check_events f (_,evs) = List.iter (type_check_event f) evs
                            
let type_check_stimuli f st =
  List.iter (type_check_events f) st;
  st
