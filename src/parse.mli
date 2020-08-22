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

(** Interface to the Menhir parsers *)

exception Error of int * int * string * string (* Line, char pos, token, message *)
  (** Raised when parsing PPX nodes *)

val guard: string -> Guard.t
  (** [guard s] builds an guard from a string representation.
      The syntax of the string is {i exp}, where {i exp} denotes a boolean expression.

      For example : [start=1] or [k<2] 

      Raises {!Error} if parsing [s] or if {i exp} does not denote a boolean expression.

      The [Parse.guard] function can be invoked using the [%fsm_guard] PPX extension. In this case, 
      [Parse.guard s] is denoted [\[%fsm_guard s\]]

      When using the PPX extension, syntax errors in the transition description are detected 
      and reported at compile time. *) 

val guards: string -> Guard.t list
  (** [guard s] builds a list of guards from a string representation.
      The syntax of the string is {i exp1,...,expn}, where each {i expi} denotes a boolean expression.

      For example : [start=1,k<2]

      Raises {!Error} if parsing [s] or if {i expi} does not denote a boolean expression.

      The [Parse.guards] function can be invoked using the [%fsm_guards] PPX extension. In this case, 
      [Parse.guards s] is denoted [\[%fsm_guards s\]]

      When using the PPX extension, syntax errors in the transition description are detected 
      and reported at compile time. *) 
                 
val action: string -> Action.t
  (** [action s] builds an action from a string representation.
      The syntax of the string is {i var} [:=] {i exp}

      For example : [rdy:=0]

      Raises {!Error} if parsing [s] fails.

      The [Parse.action] function can be invoked using the [%fsm_action] PPX extension. In this case, 
      [Parse.action s] is denoted [\[%fsm_action s\]]

      When using the PPX extension, syntax errors in the transition description are detected 
      and reported at compile time. *) 

val actions: string -> Action.t list
  (** [action s] builds a list of actions from a string representation.
      The syntax of the string is {i act1, ..., actn} where {i act} is an action.

      For example : [rdy:=0,s:=1]

      Raises {!Error} if parsing [s] fails.

      The [Parse.actions] function can be invoked using the [%fsm_actions] PPX extension. In this case, 
      [Parse.actions s] is denoted [\[%fsm_actions s\]]

      When using the PPX extension, syntax errors in the transition description are detected 
      and reported at compile time. *) 

val transition: string -> Transition.t
  (** [transition s] builds a transition from a string representation.
      The syntax of the string is

      {i src} [->] {i dst} \[ [when] {i guard}{_ 1} {b ,} ... {b ,} {i guard}{_ m} \] \[ [with] {i act}{_ 1} {b ,} ... {b ,} {i act}{_ n} \]

      where 
      - {i src} is the name of the source state
      - {i dst} is the name of the destination state
      - {i guard} is a boolean expression
      - {i act} is an action, of the form {i var} [:=] {i exp}

      For example : [t = Parse.transition "S0 -> S1 when s=0 with rdy:=0, k:=k=1"]

      Raises {!Error} if parsing [s] fails.

      The [Parse.transition] function can be invoked using the [%fsm_trans] PPX extension. In this case, 
      [Parse.transition s] is denoted [\[%fsm_trans s\]].

      When using the PPX extension, syntax errors in the transition description are detected 
      and reported at compile time. *) 

val fsm: string -> Fsm.t
 (** [fsm s] builds a FSM from a string representation.
      The syntax of the string is

     ["][name:] {i name} [;]

     [states:] {i state}{_ 1}, [...], {i state}{_ ns} [;]

     [inputs:] {i in}{_ 1}, [...], {i in}{_ ni} [;]

     [outputs:] {i out}{_ 1}, [...], {i out}{_ no} [;]

     \[[vars:] {i var}{_ 1}, [...], {i var}{_ nv} [;]\]

     [trans:] {i t}{_ 1}; [...]; {i t}{_ nt} [;]

     [itrans:] [->] {i state} \[[with] {i act}{_ 1}, [...], {i act}{_ na}\]["]

      where 
      - {i name} is the name of defined FSM
      - {i state}{_ 1}, ..., {i state}{_ ns} is a comma-separated list of state names
      - {i in}{_ 1}, ..., {i in}{_ ni} is a comma-separated list of input names 
      - {i out}{_ 1}, ..., {i out}{_ no} is a comma-separated list of output names 
      - {i var}{_ 1}, ..., {i out}{_ nv} is an optional, comma-separated list of local variable names 
      - {i t}{_ 1}, ..., {i t}{_ nt} is a semicolon-separated list of transitions (with syntax defined in {!transition})
      - {i act}{_ 1}, ..., {i act}{_ na} is an optional, comma-separated list of initial actions

      For example : [
      "name: f1;
       states: E0, E1;
       inputs: e;
       outputs: s;
       trans:
          E0 -> E1 when e=1 with s:=1;
          E1 -> E0 when e=0 with s:=0;
      itrans: -> Init with s:=0;"
      ]

      Raises {!Error} if parsing [s] fails.

      The [Parse.fsm] function can be invoked using the [%fsm] PPX extension. In this case, 
      [Parse.fsm s] is denoted [\[%fsm s\]].

      When using the PPX extension, syntax errors in the transition description are detected 
      and reported at compile time. *) 

val stimuli: string -> Stimuli.t list
      (** [stimuli s] builds a sequence of stimuli from a string representation.
      The syntax of the string is

      "{i name} [:] {i t}{_ 1} [,] {i v}{_ 1} [;] ..., [;] {i t}{_ m} [,] {i v}{_ m}" 

      where {i t} is a clock cycle counter and {i v} a value.

      For example, the sequence [stimuli "start: 0,'1'; 2,'0'"], where [start] is a signal of type [bool] 
      - set [start] to ['1'] ([true]) at time step 0
      - set [start] to ['0'] ([false]) at time step 2

      The [Parse.stimuli] function can be invoked using the [%fsm_stim] PPX extension. In this case, 
      [Parse.stimuli s] is denoted [\[%fsm_stim s\]].

      Raises {!Error} if parsing [s] fails.

      When using the PPX extension, syntax errors in the transition description are detected 
      and reported at compile time. *)
      
