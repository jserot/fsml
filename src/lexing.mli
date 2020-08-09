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

exception Syntax_error of string
  (** Raised by explicit string parsers and PPX extensions. The argument gives the current lookahead token. *)
                        
val syntax_error: Genlex.token Stream.t -> 'a
  (** [syntax_error s] raises [Syntax_error], extracting the current lookahead token from stream [s]. *)
