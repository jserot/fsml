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

(** {1 High-level simulation interface} *)

type trace = Stimuli.clk * Fsm.ctx 
  [@@deriving show]
  (** A [trace] gives the value of a FSM context at a given clock cycle *)

(** {2 Simulation functions} *)

val run:
  ?ctx:Fsm.ctx ->
  ?stop_when:Guard.t list ->
  ?stop_after:Stimuli.clk ->
  stim:Stimuli.t list ->
  Fsm.t ->
  trace list
  (** [run ctx stim m] performs a multi-step simulation of FSM [m] starting from
      context [ctx] and applying a ordered sequence of stimuli listed in [stim], producing
      a sequence of traces. FSM [m] is first type-checked. 
      If the initial context [ctx] is not given it is built by triggering the initial transition
      of [m] and gathers its inputs, local variables and outputs.
      Passing an initial context may be used to start a simulation from a given state obtained from
      a previous simulation.
      If a list of guards is given as optional argument [stop_when], then simulation stops as soon all of these guards 
      of the these guards becomes true. The guards may include relational operators on the special variable
      [clk], refering to the current simulation step. Ex: [-stop_when [%fsm_guard {|rdy=1|}]]; 
      If a clock cycle count [n] is given as optional argument [stop_after], then simulation stops after exactly 
      [n] steps (so that [-stop_after n] is actually a shorthand for [-stop_when "clk=n"]). *)

(** {2 Post-processors} *)

val filter_trace: trace list -> trace list
  (** [filter_trace ts] modifies a sequence of trace by removing, from each inserted context,
      the fields which have not been modified wrt. the previous step. *)
