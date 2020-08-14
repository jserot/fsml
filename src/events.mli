(** {1 Event sets} *)

type t = Event.t list
   (** Event sets are lists of updates occuring at the same instant *) 

(** {2 Printing} *)

val to_string: t -> string
