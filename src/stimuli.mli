(** Simulation stimuli *)

type t = Events.t list
  (** A [stimuli] is a sequence of event sets.
      Example [[x:=1,y:=1; x:=0]] means that both [x] and [y] are set to [1] at step 1, then [x] is 
      set to [0] at step [2]. *)

(* {2 Parsing} *)

val of_string: string -> t
      (** [of_string s] builds a sequence stimuli from a string representation.
      The syntax of the string is

      "{i evs}{_ 1} [;] ..., [;] {i evs}{_ m}" 

      where {i evs}, an event set, is either

      - [*], denoting the empty event (implicitely reduced to the clock event)
      - {i act}{_ 1} {b ,} ... {b ,} {i act}{_ n}, where {i act} is an action, of the form {i var} [:=] {i exp}

      For example, the stimuli sequence [of_string "*; *; start:=1; start:=0, c:=1"] 
      - set [start] to 1 at time step 2
      - set [start] to 0 and [c] to 1 at time step 3

      The [of_string] function can be invoked using the [%fsm_stim] PPX extension. In this case, the 
      previous example is written

      [\[%fsm_stim "*; *; start:=1; start:=0, c:=1"\]].

      Raises {!Lexing.Syntax_error} if parsing [s] fails.

      When using the PPX extension, syntax errors in the transition description are detected 
      and reported at compile time. *)
      
(* {2 Printing} *)

val to_string: t -> string
