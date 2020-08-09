(** {1 FSM Transitions} *)

type t = State.t * Guard.t list * Action.t list * State.t
  [@@deriving show {with_path=false}, yojson]
  (** [(src,guards,actions,dst)] means that the FSM will go from state [src] to state 
      [dst] whenever all guards listed in [guards] evaluate to [true], performing, sequentially,
      all actions listed in [actions]. *)

(** {2 Printers} *)

val to_string: t -> string

(** {2 Parsing} *)

val keywords: Lexing.Keywords.t

val parse: Genlex.token Stream.t -> t

val of_string: string -> t
  (** [of_string s] builds a transition from a string representation.
      The syntax of the string is

      {i src} [->] {i dst} \[ [when] {i guard}{_ 1} {b ,} ... {b ,} {i guard}{_ m} \] \[ [with] {i act}{_ 1} {b ,} ... {b ,} {i act}{_ n} \]

      where 
      - {i src} is the name of the source state
      - {i dst} is the name of the destination state
      - {i guard} is a boolean expression
      - {i act} is an action, of the form {i var} [:=] {i exp}

      For example : [t = of_string "S0 -> S1 when s=0 with rdy:=0, k:=k=1"]

      The [of_string] function can be invoked using the [%fsm_trans] PPX extension. In this case, the 
      previous example is written

      [t = \[%fsm_trans "S0 -> S1 when s=0 with rdy:=0, k:=k=1"\]].

      Raises {!Lexing.Syntax_error} if parsing [s] fails.

      When using the PPX extension, syntax errors in the transition description are detected 
      and reported at compile time.
   *) 

(** {2 Simulation} *)

val is_fireable: State.t -> Expr.env -> t -> bool
  (** [is_fireable src env t] returns [true] iff transition [t] is fireable
      when the enclosing FSM is in state [state] and the inputs and local variables
      have values recorded in environment [env]. *)
