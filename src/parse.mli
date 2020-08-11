(** Interface to the Menhir parsers *)

exception Error of int * int * string * string (* Line, column, token, message *)
                 
val action: string -> Action.t
  (** [action s] builds an action from a string representation.
      The syntax of the string is {i var} [:=] {i exp}

      For example : [rdy:=0]

      The [Parse.action] function can be invoked using the [%fsm_action] PPX extension. In this case, the 
      previous example is written

      [\[%fsm_action "rdy:=0"\]].

      Raises {Error} if parsing [s] fails.

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

      For example : [t = of_string "S0 -> S1 when s=0 with rdy:=0, k:=k=1"]

      The [Parse.transition] function can be invoked using the [%fsm_trans] PPX extension. In this case, the 
      previous example is written

      [t = \[%fsm_trans "S0 -> S1 when s=0 with rdy:=0, k:=k=1"\]].

      Raises {Error} if parsing [s] fails.

      When using the PPX extension, syntax errors in the transition description are detected 
      and reported at compile time. *) 

val fsm: string -> Fsm.t

val stimuli: string -> Stimuli.t
      (** [stimuli s] builds a sequence of stimuli from a string representation.
      The syntax of the string is

      "{i evs}{_ 1} [;] ..., [;] {i evs}{_ m}" 

      where {i evs}, an event set, is either

      - [*], denoting the empty event (implicitely reduced to the clock event)
      - {i act}{_ 1} {b ,} ... {b ,} {i act}{_ n}, where {i act} is an action, of the form {i var} [:=] {i exp}

      For example, the stimuli sequence [of_string "*; *; start:=1; start:=0, c:=1"] 
      - set [start] to 1 at time step 2
      - set [start] to 0 and [c] to 1 at time step 3

      The [Parse.stimuli] function can be invoked using the [%fsm_stim] PPX extension. In this case, the 
      previous example is written

      [\[%fsm_stim "*; *; start:=1; start:=0, c:=1"\]].

      Raises {Error} if parsing [s] fails.

      When using the PPX extension, syntax errors in the transition description are detected 
      and reported at compile time. *)
      
