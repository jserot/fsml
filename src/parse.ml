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

exception Error of int * int * string * string (* Line, column, token, message *)

(* let report_error s lexbuf msg =
 *   let open Lexing in
 *   let loc_line offset l =
 *     let m = Bytes.make (String.length l) '.' in
 *     Bytes.set m offset '^';
 *     Bytes.to_string m in
 *   let pos = lexbuf.lex_curr_p in
 *   let l = 
 *     try s |> String.split_on_char '\n' |> Fun.flip List.nth (pos.pos_lnum-1)
 *     with Invalid_argument _ -> s in
 *   let offset = pos.pos_cnum - pos.pos_bol - 1 in
 *   Printf.printf "%s\n%s^\n%s" l (loc_line offset l) msg *)

let error lexbuf msg =
    let open Lexing in
    let pos = lexbuf.lex_curr_p in
    raise (Error( pos.pos_lnum-1, pos.pos_cnum-pos.pos_bol-1, Lexing.lexeme lexbuf, msg))
  
let parse f s = 
  let lexbuf =  Lexing.from_string s in
  try
    lexbuf |> f Fsm_lexer.main 
  with
  | Fsm_lexer.Illegal_character (_, _) -> error lexbuf "Illegal character"
  | Fsm_parser.Error -> error lexbuf "Syntax error"

let guard = parse Fsm_parser.guard_top
let guards = parse Fsm_parser.guards_top
let action = parse Fsm_parser.action_top
let actions = parse Fsm_parser.actions_top
let transition = parse Fsm_parser.transition_top
(* let stimuli = parse Fsm_parser.stimuli_top *)
let fsm = parse Fsm_parser.fsm
