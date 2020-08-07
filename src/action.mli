(** {1 Transition actions} *)

type t = 
  | Assign of Expr.ident * Expr.t
  [@@deriving show {with_path=false}, yojson]
  (** The type of actions associated to FSM transitions *)

(** {2 Printer} *)

val to_string: t -> string

(** {2 Parsing} *)

val keywords: Lexing.Keywords.t

val parse: Genlex.token Stream.t -> t
val of_string: string -> t

(** {2 Simulation} *)

val perform: Expr.env -> t -> Expr.env
  (** [perform env a] performs action [a] in the context of environment [env],
      returning an updated env *)                                
