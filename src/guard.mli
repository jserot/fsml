type t = Expr.t
  [@@deriving show {with_path=false}, yojson]

exception Illegal_guard_expr of Expr.t

val eval: Expr.env -> Expr.t -> bool

val to_string: Expr.t -> string

val keywords: string list

val parse: Genlex.token Stream.t -> t
val of_string: string -> Expr.t
