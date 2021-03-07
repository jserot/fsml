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

(* C backend *)

open Printf

type config = {
  mutable state_var: string;
  mutable incl_file: string
  }

let cfg = {
  state_var = "state";
  incl_file = "fsml.h"
  }

exception Error of string * string   (* where, message *)

let string_of_type t = match t with 
  | Types.TyBool -> "int"
  | Types.TyInt (sg, _) when Types.real_type sg = TyUnsigned-> "unsigned int"
  | Types.TyInt _ -> "int"
  | _ -> failwith ("C backend: illegal type: " ^ Types.to_string t)

let string_of_typed_item ?(ptr=false) (id,ty) = match ty with 
  | _ -> string_of_type ty ^ " " ^ (if ptr then "*" else "") ^ id

(* let string_of_value v = match v with
 *   | Expr.Int i -> string_of_int i
 *   | Expr.Bool b -> string_of_bool b *)

let string_of_comp m id = 
  if List.mem_assoc id m.Seqmodel.m_vars then id else "ctx->" ^ id


let rec string_of_expr m e =
  let paren level s = if level > 0 then "(" ^ s ^ ")" else s in
  let rec string_of level e = match e.Expr.e_desc with
    Expr.EInt c -> string_of_int c
  | Expr.EBool c -> if c then "1" else "0"
  | Expr.EVar n -> string_of_comp m n
  | Expr.EBinop (op,e1,e2) -> paren level (string_of (level+1) e1 ^ string_of_op op ^ string_of (level+1) e2) in
  string_of 0 e

and string_of_op = function
    "=" -> "=="
  | op ->  op

let string_of_guard m exp = string_of_expr m exp

let string_of_action m a = match a with
    | Action.Assign (id, expr) -> string_of_comp m id ^ "=" ^ string_of_expr m expr

let dump_action oc m tab a = fprintf oc "%s%s;\n" tab (string_of_action m a)

let dump_transition oc m tab is_first src (_,guards,acts,dst) =
  match guards with
  | [] ->
       List.iter (dump_action oc m tab) acts;
       if dst <> src then fprintf oc "%s%s = %s;\n" tab cfg.state_var dst
  | _  -> 
       fprintf oc "%s%sif ( %s ) {\n"
        tab
        (if is_first then "" else "else ")
        (Misc.string_of_list ~f:(string_of_guard m) ~sep:" && " guards);
       List.iter (dump_action oc m (tab ^ "  ")) acts;
       if dst <> src then fprintf oc "%s  %s = %s;\n" tab cfg.state_var dst;
       fprintf oc "%s  }\n" tab

let dump_transitions oc m src after tss =
   if after then fprintf oc "      else {\n";
   let tab = if after then "        " else "      " in
   begin match tss with 
      [] -> ()  (* no wait in this case *)
    | _ ->
       Misc.iter_fst (fun is_first t -> dump_transition oc m tab is_first src t) tss;
   end;
   if after then fprintf oc "      }\n"
     
let dump_output_valuation oc m state =
  let open Seqmodel in
  assert (List.mem_assoc state m.m_states);
  List.iter
    (fun (o,e) -> fprintf oc "      %s = %s;\n" (string_of_comp m o) (string_of_expr m e))
    (List.assoc state m.m_states)

let dump_state_case oc m (src, tss) =
  fprintf oc "    case %s:\n" src;
  dump_output_valuation oc m src;
  dump_transitions oc m src false tss;
  fprintf oc "      break;\n"

let dump_impl prefix fname m =
  let open Seqmodel in
  let modname = "fsm_" ^ m.m_name in
  let oc = open_out fname in
  fprintf oc "#include \"%s.h\"\n" prefix;
  fprintf oc "#include <stdio.h>\n\n";
  let ctx_comps = List.map fst (m.m_inps @ m.m_outps @ m.m_vars) in
  fprintf oc "void dump_ctx(ctx_t ctx)\n";
  fprintf oc "{\n";
  fprintf oc "  printf(\"%s\\n\", %s);\n" 
    (Misc.string_of_list ~f:(fun id -> id ^ "=%d") ~sep:" " ctx_comps)
    (Misc.string_of_list ~f:(fun id -> "ctx." ^ id) ~sep:", " ctx_comps);
  fprintf oc "}\n\n";
  fprintf oc "void %s(ctx_t *ctx)\n" modname;
  fprintf oc "{\n";
  List.iter (fun (id,ty) -> fprintf oc "  static %s;\n" (string_of_typed_item (id,ty))) m.m_vars;
  if List.length m.m_states > 1 then 
    fprintf oc "  static enum { %s } %s = %s;\n"
      (Misc.string_of_list ~f:fst ~sep:", " m.m_states)
      cfg.state_var
      (fst m.m_init);
  fprintf oc "  static int _init = 1;\n";
  fprintf oc "  if ( _init ) {\n";
  List.iter (dump_action oc m "    ") (snd m.m_init);
  fprintf oc "    _init=0; \n";
  fprintf oc "    }\n";
  begin match m.m_body with
    [] -> () (* should not happen *)
  | [c] -> dump_state_case oc m c 
  | _ -> 
      fprintf oc "  switch ( %s ) {\n" cfg.state_var;
      List.iter (dump_state_case oc m) m.m_body;
      fprintf oc "    }\n"
  end;
  List.iter (fun (id,_) -> fprintf oc "  ctx->%s = %s;\n" id id) m.m_vars;
  fprintf oc "};\n";
  printf "Wrote file %s\n" fname;
  close_out oc

let dump_intf prefix fname m =
  let open Seqmodel in
  let oc = open_out fname in
  let modname = "fsm_" ^ m.m_name in
  fprintf oc "#ifndef _%s_h\n" prefix;
  fprintf oc "#define _%s_h\n\n" prefix;
  fprintf oc "#include \"%s\"\n\n" cfg.incl_file;
  fprintf oc "typedef struct {\n";
  List.iter (fun (id,ty) -> fprintf oc "  IN %s;\n" (string_of_typed_item (id,ty))) m.m_inps;
  List.iter (fun (id,ty) -> fprintf oc " OUT %s;\n" (string_of_typed_item (id,ty))) m.m_outps;
  List.iter (fun (id,ty) -> fprintf oc "     %s;\n" (string_of_typed_item (id,ty))) m.m_vars;
  fprintf oc "} ctx_t;\n\n";
  fprintf oc "void dump_ctx(ctx_t ctx);\n";
  fprintf oc "void %s(ctx_t *ctx);\n\n" modname;
  fprintf oc "#endif\n";
  printf "Wrote file %s\n" fname;
  close_out oc

let write ?(dir="") ~prefix f = 
  let m = Seqmodel.make f in
  let () = Misc.check_dir dir in
  let p = dir ^ Filename.dir_sep ^ prefix in
  dump_intf prefix (p ^ ".h") m;
  dump_impl prefix (p ^ ".c") m
