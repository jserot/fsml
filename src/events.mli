(** {1 Event sets} *)

type t = Action.t list
   (** Event sets are lists of updates occuring at the same instant *) 

(** {2 Parsing} *)

val keywords: Lexing.Keywords.t

val parse: Genlex.token Stream.t -> t
val of_string: string -> t

(** {2 Printing} *)

val to_string: t -> string
