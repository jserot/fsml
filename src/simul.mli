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

(** {1 Simulation} *)

type ctx = {
  state: State.t;
  env: Expr.env
  }
[@@deriving show]
  (** A context is the dynamic view of a FSM. It records its current state
     and, in [env], the value of its inputs, outputs and local variables. *)

(** {2 Simulation functions} *)

val step: ctx -> Fsm.t -> Event.t list * ctx
  (** [step ctx m] performs a single simulation step, within context [ctx] of FSM [m]. 
      The first fireable transition is selected according to the current state and
      value of the inputs and local variables. The actions associated to this transition
      are executed and both the state and context are updated accordingly.
      If no fireable transition is found, the context is left unchanged.
      Returns a list timed output events and the updated context. *)

val run:
  ?ctx:ctx ->
  ?stop_when:Guard.t list ->
  ?stop_after:Clock.clk ->
  ?trace:bool ->
  stim:Tevents.t list ->
  Fsm.t ->
  Tevents.t list * (ctx Clock.clocked) list
  (** [run ctx stim m] performs a multi-step simulation of FSM [m] starting from
      context [ctx] and applying a ordered sequence of stimuli listed in [stim], producing
      a sequence of timed event sets and, if the optional argument [trace] is set, the corresponding sequence of contexts.
      FSM [m] is first type-checked. 
      If the initial context [ctx] is not given it is built by triggering the initial transition
      of [m] and gathers its inputs, local variables and outputs.
      Passing an initial context may be used to start a simulation from a given state obtained from
      a previous simulation.
      If a list of guards is given as optional argument [stop_when], then simulation stops as soon all of these guards 
      of the these guards becomes true. The guards may include relational operators on the special variable
      [clk], refering to the current simulation step. Ex: [-stop_when [%fsm_guard {|rdy=1|}]]; 
      If a clock cycle count [n] is given as optional argument [stop_after], then simulation stops after exactly 
      [n] steps (so that [-stop_after n] is actually a shorthand for [-stop_when "clk=n"]). *)
