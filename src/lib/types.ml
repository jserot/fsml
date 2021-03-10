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
  | TyInt of sign attr * size attr * range attr
  | TyBool
  | TyArrow of t * t  (** Internal use only *)
  | TyProduct of t list  (** Internal use only *)
  | TyVar of t var  (** Internal use only *)
  [@@deriving show {with_path=false}, yojson]

and 'a attr =
  | Const of 'a
  | Var of ('a attr) var
  [@@deriving show {with_path=false}, yojson]

and 'a var =
  { stamp: string;
    mutable value: 'a value }
  [@@deriving show {with_path=false}, yojson]

and 'a value =
  | Unknown
  | Known of 'a
  [@@deriving show {with_path=false}, yojson]

and sign = Signed | Unsigned [@@deriving show {with_path=false}, yojson]
and size = int [@@deriving show {with_path=false}, yojson]
and range = { lo: int; hi: int } [@@deriving show {with_path=false}, yojson]
          
type typ_scheme =
  { ts_params: ts_params;
    ts_body: t }
  [@@deriving show {with_path=false}, yojson]

and ts_params = {
  tp_typ: (t var) list;
  tp_sign: ((sign attr) var) list;
  tp_size: ((size attr) var) list;
  tp_range: ((range attr) var) list;
  }

(* Builders *)

let new_stamp =
  let var_cnt = ref 0 in
  function () -> incr var_cnt; "_" ^ string_of_int !var_cnt

let make_var () = { value = Unknown; stamp=new_stamp () }

let new_type_var () = make_var ()
let new_attr_var () = make_var ()

let type_int () = TyInt (Var (make_var ()), Var (make_var ()), Var (make_var()))

let empty_params = { tp_typ=[]; tp_sign=[]; tp_size=[]; tp_range=[] }
let trivial_scheme t = { ts_params=empty_params; ts_body=t }
                     
(* Path compression *)

let rec type_repr = function
  | TyVar ({value = Known ty1; _} as var) ->
      let ty = type_repr ty1 in
      var.value <- Known ty;
      ty
  | ty -> ty

(* TODO: find a way to share type_xxx and attr_xxx fns .. *)
        
let rec attr_repr = function
  | Var ({value = Known r1; _} as var) ->
      let r = attr_repr r1 in
      var.value <- Known r;
      r
  | r -> r

let real_attr a = 
  match attr_repr a with
  | Var { value=Known v'; _} -> v'
  | r -> r

let real_type ty = 
  match type_repr ty with
  | TyInt (sg, sz, rg) -> TyInt (real_attr sg, real_attr sz, real_attr rg)
  | TyVar { value=Known ty'; _} -> ty'
  | ty -> ty

exception Polymorphic of t

(* let rec mono_attr t = function
 *   | Var ({value = Known v1; _}) -> mono_attr t v1
 *   | Var ({value = Unknown; _}) -> raise (Polymorphic t)
 *   | r -> r  *)
                       
let rec mono_type = function
  (* | TyInt (sg, sz, rg) as t -> TyInt (mono_attr t sg, mono_attr t sz, mono_attr t rg) *)
  | TyArrow (t1, t2) -> TyArrow (mono_type t1, mono_type t2)
  | TyProduct ts -> TyProduct (List.map mono_type ts)
  | TyVar ({value = Known ty1; _}) -> mono_type ty1
  | TyVar ({value = Unknown; _}) as t -> raise (Polymorphic t)
  | ty -> ty 

(* Unification *)

exception TypeConflict of t * t
exception TypeCircularity of t * t

let unify_attr (ty1,ty2) a1 a2 =
  let val1 = real_attr a1
  and val2 = real_attr a2 in
  if val1 == val2 then ()
  else
  match (val1, val2) with
    | Const s1, Const s2 when s1 = s2 -> ()
    | Var var1, Var var2 when var1 == var2 -> ()  (* This is hack *)
    | Var var, v -> var.value <- Known v
    | v, Var var -> var.value <- Known v
    | _, _ -> raise (TypeConflict(ty1, ty2))

let rec unify ty1 ty2 =
  let val1 = real_type ty1
  and val2 = real_type ty2 in
  if val1 == val2 then () else
  match (val1, val2) with
  | TyVar v1, TyVar v2 when v1==v2 -> 
      ()
  | TyVar var, ty ->
      occur_check var ty;
      var.value <- Known ty
  | ty, TyVar var ->
      occur_check var ty;
      var.value <- Known ty
  | TyBool, TyBool -> ()
  | TyInt (sg1,sz1,rg1), TyInt (sg2,sz2,rg2) ->
     unify_attr (val1,val2) sg1 sg2;
     unify_attr (val1,val2) sz1 sz2;
     unify_attr (val1,val2) rg1 rg2
  | TyArrow(ty1, ty2), TyArrow(ty1', ty2') ->
      unify ty1 ty1';
      unify ty2 ty2'
  | TyProduct ts1, TyProduct ts2 when List.length ts1 = List.length ts2 ->
      List.iter2 unify ts1 ts2
  | _, _ ->
     raise (TypeConflict(val1, val2))


and occur_check var ty =
  let test s =
    match type_repr s with
    | TyVar var' ->
        if var == var' then raise(TypeCircularity(TyVar var,ty))
    | _ ->
        ()
  in test ty

let copy_attr bs a =
  match attr_repr a with
  | Var var as v ->
      begin try
        List.assq var bs 
      with Not_found ->
        v
      end
  | r -> r

type bindings =
  { tb_typ: (t var * t) list;
    tb_sign: ((sign attr) var * sign attr) list;
    tb_size: ((size attr) var * size attr) list;
    tb_range: ((range attr) var * range attr) list; }
  
let copy_type bs ty =
  let rec copy ty = 
    match type_repr ty with
    | TyVar var as ty ->
        begin try
          List.assq var bs.tb_typ
        with Not_found ->
            ty
        end
    | TyInt (sg, sz, rg) ->
       TyInt (copy_attr bs.tb_sign sg, copy_attr bs.tb_size sz, copy_attr bs.tb_range rg)
    | TyArrow (ty1, ty2) ->
       TyArrow (copy ty1, copy ty2)
    | TyProduct ts ->
       TyProduct (List.map copy ts)
    | ty -> ty in
  copy ty

let type_instance ts =
  match ts.ts_params with
  | { tp_typ=[]; tp_sign=[]; tp_size=[]; tp_range=[] } -> ts.ts_body  (* Monotype *)
  | _ ->
     copy_type
       { tb_typ = List.map (fun var -> (var, TyVar (make_var()))) ts.ts_params.tp_typ;
         tb_sign = List.map (fun var -> (var, Var (make_var()))) ts.ts_params.tp_sign;
         tb_size = List.map (fun var -> (var, Var (make_var()))) ts.ts_params.tp_size;
         tb_range = List.map (fun var -> (var, Var (make_var()))) ts.ts_params.tp_range }
       ts.ts_body

(* Printing *)

let string_of_sign, string_of_size, string_of_range =
  let string_of_attr sf a = match a with
    | Const c -> sf c
    | Var v -> v.stamp in
  (string_of_attr (function Unsigned -> "unsigned" | Signed -> "signed"),
   string_of_attr string_of_int,
   string_of_attr (function r -> string_of_int r.lo ^ ".." ^ string_of_int r.hi))
   
let rec to_string t = match t with
  | TyBool -> "bool"
  (* | TyInt (Const Signed, _, _) -> "signed"
   * | TyInt (Const Unsigned, _, _) -> "unsigned" *)
  | TyInt (_, _, Const r) -> "int<" ^ string_of_int r.lo ^ ".." ^ string_of_int r.hi ^ ">" (* Special case *)
  | TyInt (sg, sz, rg) ->
     "int<" ^ string_of_sign sg ^ "," ^ string_of_size sz ^ "," ^ string_of_range rg ^ ">"
  | TyArrow (t1, t2) -> to_string t1 ^ "->" ^ to_string t2
  | TyProduct ts -> Misc.string_of_list ~f:to_string ~sep:"*" ts
  | TyVar v -> v.stamp

