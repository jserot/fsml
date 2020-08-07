(** {1 Dot output} *)

type options = {
    mutable node_shape: string;
    mutable node_style: string;
    mutable rankdir: string;
    mutable layout: string;
    mutable mindist: float
  }

val default_options: options

val write: string -> ?options:options -> Fsm.t -> unit
    (** [write fname m] writes a [.dot] representation of FSM [m] in file [fname].
        Rendering can be modified with the [options] optional argument. *)
  
val view: ?options:options -> ?fname:string -> ?cmd:string -> Fsm.t -> int
    (** [view m] views FSM [m] by first writing its [.dot] representation in file 
        and then launching a DOT viewer application. The name of the output file and
        of the viewer application can be changed using the [fname] and [cmd] optional
        arguments. Returns the issued command exit status. *)
