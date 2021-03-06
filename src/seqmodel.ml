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
  m_name: string;
  m_states: (string * Valuation.t) list;
  m_inps: (string * Types.t) list;
  m_outps: (string * Types.t) list;
  m_vars: (string * Types.t) list;  
  m_init: State.t * Action.t list;
  m_body: (State.t * Transition.t list) list; (* Transitions, indexed by source state *)
     (* m_body = [case_1;...;case_n]
       means
        "while ( 1 ) { switch ( [state] ) { [case_1]; ...; [case_n] } }" *)
  }

let make f = 
  let f = Typing.type_check_fsm ~mono:true f in
  let open Fsm in
  let src_states ts = 
    let rec scan acc ts = match ts with
      | [] -> List.rev acc
      | (src,_,_,_)::rest -> if List.mem src acc then scan acc rest else scan (src::acc) rest in
    scan [] ts in
  { m_name = f.id;
    m_states = f.states;
    m_inps = f.inps;
    m_outps = f.outps;
    m_vars = f.vars;
    m_init = f.itrans;
    m_body = List.map (fun s -> s, List.filter (fun (s',_,_,_) -> s=s') f.trans) (src_states f.trans)
    }

