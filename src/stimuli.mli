(** Simulation stimuli *)

type t = Events.t list
  (** A [stimuli] is a sequence of event sets.
      Example [[x:=1,y:=1; x:=0]] means that both [x] and [y] are set to [1] at step 1, then [x] is 
      set to [0] at step [2]. *)

(* {2 Parsing} *)

val of_string: string -> t

(* {2 Printing} *)

val to_string: t -> string
