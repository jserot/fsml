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
  | TyInt of t * int_size * int_range (** [t] is for signness *)
  | TyBool
  | TyArrow of t * t  (** Internal use only *)
  | TyProduct of t list  (** Internal use only *)
  | TyVar of t var  (** Internal use only *)
  | TySigned    (** Phantom type *)
  | TyUnsigned  (** Phantom type *)
  [@@deriving show {with_path=false}, yojson]

and int_size =
  | SzConst of int
  | SzVar of int_size var
  [@@deriving show {with_path=false}, yojson]

and int_range =
  | RgConst of range
  | RgVar of int_range var
  [@@deriving show {with_path=false}, yojson]

and range = { lo: int; hi: int }
  [@@deriving show {with_path=false}, yojson]
          
and 'a var =
  { stamp: string;
    mutable value: 'a value }
  [@@deriving show {with_path=false}, yojson]

and 'a value =
  | Unknown
  | Known of 'a
  [@@deriving show {with_path=false}, yojson]

type typ_scheme =
  { ts_tparams: (t var) list;
    ts_sparams: (int_size var) list;
    ts_rparams: (int_range var) list;
    ts_body: t }
  [@@deriving show {with_path=false}, yojson]

(* Builders *)

let new_stamp =
  let var_cnt = ref 0 in
  function () -> incr var_cnt; "_" ^ string_of_int !var_cnt

let make_var () = { value = Unknown; stamp=new_stamp () }

let new_type_var () = make_var ()
let new_size_var () = make_var ()
let new_range_var () = make_var ()

let type_int () = TyInt (TyVar (new_type_var ()), SzVar (new_size_var ()), RgVar (new_range_var()))

let trivial_scheme t = { ts_tparams=[]; ts_sparams=[]; ts_rparams=[]; ts_body=t }
                     
(* Path compression *)

let rec type_repr = function
  | TyVar ({value = Known ty1; _} as var) ->
      let ty = type_repr ty1 in
      var.value <- Known ty;
      ty
  | ty -> ty

let rec size_repr = function
  | SzVar ({value = Known sz1; _} as var) ->
      let sz = size_repr sz1 in
      var.value <- Known sz;
      sz
  | sz -> sz

let rec range_repr = function
  | RgVar ({value = Known rg1; _} as var) ->
      let rg = range_repr rg1 in
      var.value <- Known rg;
      rg
  | rg -> rg

let rec real_type ty = 
  match type_repr ty with
  | TyInt (sg, sz, rg) -> TyInt (real_type sg, real_size sz, real_range rg)
  | TyVar { value=Known ty'; _} -> ty'
  | ty -> ty

and real_size sz = 
  match size_repr sz with
  | SzVar { value=Known sz'; _} -> sz'
  | sz -> sz

and real_range rg = 
  match range_repr rg with
  | RgVar { value=Known rg'; _} -> rg'
  | rg -> rg

exception Polymorphic of t
                       
let rec mono_type = function
  | TyInt (sg, sz, rg) as t -> TyInt (mono_type sg, mono_size t sz, mono_range t rg)
  | TyArrow (t1, t2) -> TyArrow (mono_type t1, mono_type t2)
  | TyProduct ts -> TyProduct (List.map mono_type ts)
  | TyVar ({value = Known ty1; _}) -> mono_type ty1
  | TyVar ({value = Unknown; _}) as t -> raise (Polymorphic t)
  | ty -> ty 

and mono_size t = function
  | SzVar ({value = Known sz1; _}) -> mono_size t sz1
  | SzVar ({value = Unknown; _}) -> raise (Polymorphic t)
  | sz -> sz 

and mono_range t = function
  | RgVar ({value = Known rg1; _}) -> mono_range t rg1
  | RgVar ({value = Unknown; _}) -> raise (Polymorphic t)
  | rg -> rg 

(* Unification *)

exception TypeConflict of t * t
exception TypeCircularity of t * t

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
     unify sg1 sg2;
     unify_size (val1,val2) sz1 sz2;
     unify_range (val1,val2) rg1 rg2
  | TyArrow(ty1, ty2), TyArrow(ty1', ty2') ->
      unify ty1 ty1';
      unify ty2 ty2'
  | TyProduct ts1, TyProduct ts2 when List.length ts1 = List.length ts2 ->
      List.iter2 unify ts1 ts2
  | TyUnsigned, TyUnsigned -> ()
  | TySigned, TySigned -> ()
  | _, _ ->
     raise (TypeConflict(val1, val2))

and unify_size (ty1,ty2) sz1 sz2 =
  let val1 = real_size sz1
  and val2 = real_size sz2 in
  if val1 == val2 then ()
  else
  match (val1, val2) with
    | SzConst s1, SzConst s2 when s1 = s2 -> ()
    | SzVar var1, SzVar var2 when var1 == var2 -> ()  (* This is hack *)
    | SzVar var, sz -> var.value <- Known sz
    | sz, SzVar var -> var.value <- Known sz
    | _, _ -> raise (TypeConflict(ty1, ty2))

and unify_range (ty1,ty2) rg1 rg2 =  (* TODO: to be shared with [unify_size] ! *)
  let val1 = real_range rg1
  and val2 = real_range rg2 in
  if val1 == val2 then ()
  else
  match (val1, val2) with
    | RgConst r1, RgConst r2 when r1 = r2 -> ()
    | RgVar var1, RgVar var2 when var1 == var2 -> ()  (* This is hack *)
    | RgVar var, rg -> var.value <- Known rg
    | rg, RgVar var -> var.value <- Known rg
    | _, _ -> raise (TypeConflict(ty1, ty2))

and occur_check var ty =
  let test s =
    match type_repr s with
    | TyVar var' ->
        if var == var' then raise(TypeCircularity(TyVar var,ty))
    | _ ->
        ()
  in test ty

let rec copy_type tvbs svbs rvbs ty =
  let rec copy ty = 
    match type_repr ty with
    | TyVar var as ty ->
        begin try
          List.assq var tvbs
        with Not_found ->
            ty
        end
    | TyInt (sg, sz, rg) ->
       TyInt (copy sg, copy_size svbs sz, copy_range rvbs rg)
    | TyArrow (ty1, ty2) ->
       TyArrow (copy ty1, copy ty2)
    | TyProduct ts ->
       TyProduct (List.map copy ts)
    | ty -> ty in
  copy ty

and copy_size svbs sz =
  match size_repr sz with
  | SzVar var as sz ->
      begin try
        List.assq var svbs 
      with Not_found ->
        sz
      end
  | sz -> sz

and copy_range rvbs rg =
  match range_repr rg with
  | RgVar var as rg ->
      begin try
        List.assq var rvbs 
      with Not_found ->
        rg
      end
  | rg -> rg

let type_instance ts =
  match ts.ts_tparams, ts.ts_sparams, ts.ts_rparams with
  | [], [], [] -> ts.ts_body
  | tparams, sparams, rparams ->
      let unknown_ts = List.map (fun var -> (var, TyVar (new_type_var()))) tparams in
      let unknown_ss = List.map (fun var -> (var, SzVar (new_size_var()))) sparams in
      let unknown_rs = List.map (fun var -> (var, RgVar (new_range_var()))) rparams in
      copy_type unknown_ts unknown_ss unknown_rs ts.ts_body

(* Printing *)
   
let rec to_string t = match t with
  | TyBool -> "bool"
  (* | TyInt (sg, sz) -> string_of_signness sg ^ string_of_size sz *)
  | TyInt (_, _, RgConst r) -> "int<" ^ string_of_int r.lo ^ ".." ^ string_of_int r.hi ^ ">" (* Special case *)
  | TyInt (sg, sz, _) -> "int<" ^ to_string sg ^ "," ^ string_of_size sz ^ ">"
  | TyArrow (t1, t2) -> to_string t1 ^ "->" ^ to_string t2
  | TyProduct ts -> Misc.string_of_list ~f:to_string ~sep:"*" ts
  | TyVar v -> v.stamp
  | TySigned -> "signed"
  | TyUnsigned -> "unsigned"

and string_of_size sz = match sz with
  | SzConst s -> string_of_int s
  | SzVar v -> v.stamp

(* and string_of_signness sg = match real_type sg with
 *   | TyUnsigned -> "uint"
 *   | _ -> "int" *)

