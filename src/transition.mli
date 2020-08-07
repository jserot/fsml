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

(** {2 Simulation} *)

val is_fireable: State.t -> Expr.env -> t -> bool
  (** [is_fireable src env t] returns [true] iff transition [t] is fireable
      when the enclosing FSM is in state [state] and the inputs and local variables
      have values recorded in environment [env]. *)
