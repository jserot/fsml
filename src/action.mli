(** {1 Transition actions} *)

type t = 
  | Assign of Expr.ident * Expr.t
  [@@deriving show {with_path=false}, yojson]
  (** The type of actions associated to FSM transitions *)

(** {2 Printer} *)

val to_string: t -> string

(** {2 Simulation} *)

val perform: Expr.env -> Expr.env -> t -> Expr.env
  (** [perform env env' a] performs action [a] in the context of environment [env @ env']
       returning and updated version of [env'] *)                                
