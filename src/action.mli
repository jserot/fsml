type t = 
  | Assign of Expr.ident * Expr.t
  [@@deriving show {with_path=false}, yojson]

val to_string: t -> string

val parse: Genlex.token Stream.t -> t
val of_string: string -> t
