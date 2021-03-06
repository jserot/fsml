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

(** {1 Sequential model (used by C and VHDL backends)} *)

type t = {
  m_name: string;
  m_states: (string * Valuation.t) list;
  m_inps: (string * Types.t) list;
  m_outps: (string * Types.t) list;
  m_vars: (string * Types.t) list;  
  m_init: State.t * Action.t list; (** Initial transition *)
  m_body: (State.t * Transition.t list) list; (** Transitions, indexed by source state *)
  }

val make: Fsm.t -> t
  (** [make f] builds a sequential model from FSM [f]. The FSM is first type-checked. *)
