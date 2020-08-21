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

(** Typing *)

exception Typing_error of string * string * string (** what, where,  msg *)

type env = (string * Types.typ_scheme) list
  (** Typing environment *)

val type_check_fsm: ?mono:bool -> Fsm.t -> Fsm.t
  (** [type_check_fsm f] type checks FSM [f], raising [!Typing_error] when 
      appropriate. Passing the optional [mono] argument also checks that all types occuring in the
      FSM definitions are monomorphic. This is required, for instance to generate C or VHDL code. *)

val type_check_fsm_guard: ?mono:bool -> ?with_clk:bool -> Fsm.t -> Guard.t -> Guard.t
  (** [type_check_fsm_guard f e] type checks guard expression [e] in the context of FSM [f]. *)

val type_check_fsm_action: ?mono:bool -> Fsm.t -> Action.t -> Action.t
  (** [type_check_fsm_action f a] type checks action [a] in the context of FSM [f]. *)

val type_check_stimuli: Fsm.t -> Stimuli.t list -> Stimuli.t list
  (** [type_check_stimuli f s] type checks a sequence [s] of stimuli for a FSM [f], raising [!Typing_error] when 
      appropriate (for example if an event [e] refers to a non-existent input of [f] or if the type of value asssociated 
      to [e] does not match the type of the corresponding input in [f]. *)
