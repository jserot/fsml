(** {1 Transition guards} *)

type t = Expr.t
  [@@deriving show {with_path=false}, yojson]
  (** The type of guards associated to transitions. 
      Guards are just boolean expressions. *)

(** {2 Parsing} *)

val keywords: Lexing.Keywords.t

val parse: Genlex.token Stream.t -> t
val of_string: string -> Expr.t

(** {2 Printing} *)

val to_string: Expr.t -> string

(** {2 Simulation} *)

exception Illegal_guard_expr of Expr.t

val eval: Expr.env -> Expr.t -> bool
  (** [eval env e] evaluates guard expression [e] in environment [env], returning 
      the corresponding boolean value. 
      Raises [Illegal_guard_expr] if the expression does not denote a boolean value. *)


