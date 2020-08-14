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

type clk = int
  [@@deriving show]
  (** Clock cycle counter *)

type trace = clk * Fsm.ctx 
  [@@deriving show]
  (** A [trace] gives the value of a FSM context at a given clock cycle *)

(** {2 Simulation functions} *)

val run:
  ?ctx:Fsm.ctx ->
  stim:Events.t list ->
  Fsm.t ->
  trace list
  (** [run ctx stim m] performs a multi-step simulation of FSM [m] starting from
      context [ctx] and applying a sequence of stimuli described by [stim], producing
      a sequence of traces. FSM [m] is first type-checked. 
      If the initial context [ctx] is not given it is built by triggering the initial transition
      of [m] and gathers its inputs, local variables and outputs. *)

val compute:
  ?istate:string (** Initial state (default: "Idle") *)
  -> ?start:string  (** Start input signal (default: "start") *)
  -> ?rdy:string    (** Rdy output signal (default: "rdy") *)
  -> args:(string * Expr.e_val) list  (** Input arguments *)
  -> ?results:string list (** Results (default: all outputs) *)
  -> Fsm.t        
  -> int * (string * Expr.e_val) list 
  (**
      [compute args m] is a special version of [run] dedicated to FSMs describing {i co-processing
      units}. The assumption is that such FSMs have
      - a pair of synchronizing signals, typically named [start] and [rdy]
      - a set of input arguments,
      - a set of computation results.

      and the following behavior :
      - the FSM is initially in state [Idle], with output [rdy] set to 1
      - when input [start] is set to 1, all inputs arguments are registered, output [rdy] is set to 0,
        and the FSM starts to compute the result (this my involve an unknown number of states and/or steps
      - when the computation is done, the results are written on the outputs, [rdy] set to 1 and FSM back to the 
        initial state.

      The [compute] function takes care of generating the corresponding stimuli and waiting for the end of the
      computation (watching the [rdy] output). It returns
      - the number of steps required to get the results
      - the value of these results as a association list mapping their names to the corresponding value.

      The name of of initial state, of the [start] and [rdy] signals can be modified using the optional 
      arguments [istate], [start] and [rdy] respectively.
      By default, all outputs will be considered as results. The [results] optional argument can be used to
      modify this. 

      As for [!run], FSM [m] is first type-checked. *)
 
(** {2 Post-processors} *)

val filter_trace: trace list -> trace list
  (** [filter_trace ts] modifies a sequence of trace by removing, from each inserted context,
      the fields which have not been modified wrt. the previous step. *)
