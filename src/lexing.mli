(** {1 Lexing helpers} *)

module type KEYWORDS = 
sig
  type t
  val make: string list -> t
  val elems: t -> string list
  val add: t -> string list -> t
  val union: t -> t -> t
end

module Keywords : KEYWORDS

val lexer: Keywords.t -> string -> Genlex.token Stream.t

val syntax_error: Genlex.token Stream.t -> 'a
