type t = Action.t list

val keywords: Lexing.Keywords.t

val parse: Genlex.token Stream.t -> t
val of_string: string -> t

val to_string: t -> string
