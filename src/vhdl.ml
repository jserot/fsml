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

(* VHDL backend *)

open Printf

exception Error of string * string  (* where, msg *)

type config = {
  mutable state_var: string;
  mutable reset_sig: string;
  mutable clk_sig: string;
  mutable use_numeric_std: bool;
  mutable act_sem: act_semantics;
  }

and act_semantics =  (** Interpretation of actions associated to transitions *)
  | Sequential        (** sequential (ex: [x:=x+1,y:=x] with [x=1] gives [x=2,y=2]) *)
  | Synchronous       (** synchronous (ex: [x:=x+1,y=x] with [x=1] gives [x=2,y=1]) *)

let cfg = {
  state_var = "state";
  reset_sig = "rst";
  clk_sig = "clk";
  use_numeric_std = false;
  act_sem = Sequential;
    (* Note. This is to make OCaml, C and VHDL behaviors observationaly equivalent. 
       Synchronous behavior is implemented (and can be selected) but potentially
       breaks this equivalence because it is not (yet) implemented at the OCaml and
       C level. *)
  }

type vhdl_type = 
  | Unsigned of int
  | Signed of int
  | Integer of int_range option
  | Std_logic

and int_range = int * int (* lo, hi *)             

let vhdl_type_of t =
  let open Types in
  match t with 
  | TyBool -> Std_logic
  | TyInt (sg, SzConst sz) ->
     begin match Types.real_type sg, cfg.use_numeric_std with
     | TyUnsigned, true -> Unsigned sz
     | TyUnsigned, false -> Integer (Some (0, Misc.pow2 sz - 1))
     | _, true -> Signed sz
     | _, false -> Integer (Some (-Misc.pow2 (sz-1), Misc.pow2 (sz-1) - 1))
     end
  | TyInt (_, _) -> Integer None
  | _ -> failwith ("VHDL backend: illegal type: " ^ Types.to_string t)

type type_mark = TM_Full | TM_Abbr | TM_None [@@warning "-37"]
                                   
let string_of_vhdl_type ?(type_marks=TM_Full) t = match t, type_marks with 
  | Unsigned n, TM_Full -> Printf.sprintf "unsigned(%d downto 0)" (n-1)
  | Unsigned n, TM_Abbr -> Printf.sprintf "unsigned%d" n
  | Unsigned _, TM_None -> "unsigned"
  | Signed n, TM_Full -> Printf.sprintf "signed(%d downto 0)" (n-1)
  | Signed n, TM_Abbr -> Printf.sprintf "signed%d" n
  | Signed _, TM_None -> "signed"
  | Integer (Some (lo,hi)), TM_Full -> Printf.sprintf "integer range %d to %d" lo hi
  | Integer _, _ -> "integer"
  | Std_logic, _ -> "std_logic"

let string_of_type ?(type_marks=TM_Full) t =
  string_of_vhdl_type ~type_marks:type_marks (vhdl_type_of t)

let string_of_op = function
  | "!=" -> " /= "
  | op ->  op

let string_of_expr e =
  let paren level s = if level > 0 then "(" ^ s ^ ")" else s in
  let rec string_of level e =
    match e.Expr.e_desc, vhdl_type_of (e.Expr.e_typ)  with
    | Expr.EInt n, Unsigned s -> Printf.sprintf "to_unsigned(%d,%d)" n s
    | Expr.EInt n, Signed s -> Printf.sprintf "to_signed(%d,%d)" n s
    | Expr.EInt n, _ -> string_of_int n
    | Expr.EBool b, _ -> if b then "'1'" else "'0'"
    | Expr.EVar n, _ ->  n
    | Expr.EBinop (op,e1,e2), ty -> 
       let s1 = string_of (level+1) e1 
       and s2 = string_of (level+1) e2 in 
       begin match op, ty with
       | "*", Signed _
       | "*", Unsigned _ -> "mul(" ^ s1 ^ "," ^ s2 ^ ")"
       | _, _ -> paren level (s1 ^ string_of_op op ^ s2)
       end
  in
  string_of 0 e

(* and string_of_int_expr e = match e.Expr.e_desc, vhdl_type_of (e.Expr.e_typ) with
 *     Expr.EInt n, _ -> string_of_int n
 *   | _, Integer _ -> string_of_expr e
 *   | _, _ -> "to_integer(" ^ string_of_expr e ^ ")"
 * 
 * and string_of_range id hi lo = id ^ "(" ^ string_of_int_expr hi ^ " downto " ^ string_of_int_expr lo ^ ")" *)

let string_of_action m a =
  let open Seqmodel in
  let asn id = if List.mem_assoc id m.m_vars && cfg.act_sem = Sequential then " := " else " <= " in
  match a with
  | Action.Assign (id, expr) ->
     id ^ asn id ^ string_of_expr expr

let string_of_guards gs =  
  Misc.string_of_list ~f:string_of_expr ~sep:" and " gs

let dump_action oc tab m a = fprintf oc "%s%s;\n" tab (string_of_action m a)

let dump_transition oc tab src m (is_first,_) (_,guards,acts,dst) =
  match guards with
    [] -> 
       List.iter (dump_action oc tab m) acts;
       fprintf oc "%s%s <= %s;\n" tab cfg.state_var dst;
       (false,false)
  | _ ->
       fprintf oc "%s%s ( %s ) then\n" tab (if is_first then "if" else "elsif ") (string_of_guards guards);
       List.iter (dump_action oc (tab ^ "  ") m) acts;
       if dst <> src then fprintf oc "%s  %s <= %s;\n" tab cfg.state_var dst;
       (false,true)

let dump_sync_transitions oc src _ m ts =
   let tab = "        " in
   let (_,needs_endif) = List.fold_left (dump_transition oc tab src m) (true,false) ts in
   if needs_endif then fprintf oc "        end if;\n"
     
let dump_state oc m (src,tss) =
  match tss with
  | [] -> raise (Error (m.Seqmodel.m_name, "VHDL: state " ^ src ^ " has no output transition"))
  | _ -> dump_sync_transitions oc src false m tss

let dump_state_case oc m (src, tss) =
    fprintf oc "      when %s =>\n" src;
    dump_state oc m (src,tss)

let dump_module_arch oc m =
  let open Seqmodel in
  let modname = m.m_name in
  fprintf oc "architecture RTL of %s is\n" modname;
  fprintf oc "  type t_%s is ( %s );\n" cfg.state_var (Misc.string_of_list ~f:Fun.id ~sep:", " m.m_states);
  fprintf oc "  signal %s: t_state;\n" cfg.state_var;
  if cfg.act_sem = Synchronous then 
    List.iter
      (fun (id,ty) -> fprintf oc "  signal %s: %s;\n" id (string_of_type ~type_marks:TM_Abbr ty))
      m.m_vars;
  fprintf oc "begin\n";
  fprintf oc "  process(%s, %s)\n" cfg.reset_sig cfg.clk_sig;
  if cfg.act_sem = Sequential then 
    List.iter
      (fun (id,ty) -> fprintf oc "    variable %s: %s;\n" id (string_of_type ty))
      m.m_vars;
  fprintf oc "  begin\n";
  fprintf oc "    if ( %s='1' ) then\n" cfg.reset_sig;
  fprintf oc "      %s <= %s;\n" cfg.state_var (fst m.m_init);
  List.iter (dump_action oc "      " m) (snd m.m_init);
  fprintf oc "    elsif rising_edge(%s) then \n" cfg.clk_sig;
  begin match m.m_body with
    [] -> () (* should not happen *)
  | [c] -> dump_state oc m c 
  | _ -> 
      fprintf oc "      case %s is\n" cfg.state_var;
      List.iter (dump_state_case oc m) m.m_body;
      fprintf oc "    end case;\n"
  end;
  fprintf oc "    end if;\n";
  fprintf oc "  end process;\n";
  fprintf oc "end architecture;\n"

let dump_module_intf kind oc m = 
  let open Seqmodel in
  let modname = m.m_name in
  fprintf oc "%s %s %s\n" kind modname (if kind = "entity" then "is" else "");
  fprintf oc "  port(\n";
  List.iter (fun (id,ty) -> fprintf oc "        %s: in %s;\n" id (string_of_type ty)) m.m_inps;
  List.iter (fun (id,ty) -> fprintf oc "        %s: out %s;\n" id (string_of_type ty)) m.m_outps;
  fprintf oc "        %s: in std_logic;\n" cfg.clk_sig;
  fprintf oc "        %s: in std_logic\n);\n" cfg.reset_sig;
  fprintf oc "end %s;\n" kind

let dump_model fname m =
  let oc = open_out fname in
  fprintf oc "library ieee;\n";
  fprintf oc "use ieee.std_logic_1164.all;\n";
  if cfg.use_numeric_std then fprintf oc "use ieee.numeric_std.all;\n";
  (* fprintf oc "library %s;\n" cfg.support_library;
   * fprintf oc "use %s.%s.all;\n" cfg.support_library cfg.support_package; *)
  fprintf oc "\n";
  dump_module_intf "entity" oc m;
  fprintf oc "\n";
  dump_module_arch oc m;
  printf "Wrote file %s\n" fname;
  close_out oc

let write ~fname f = 
  let m = Seqmodel.make f in
  dump_model (fname ^ ".vhd") m
