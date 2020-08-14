(** Typing *)

exception Typing_error of string * string * string (** what, where,  msg *)

type env = (string * Types.typ_scheme) list
  (** Typing environment *)

val type_check_fsm: ?mono:bool -> Fsm.t -> Fsm.t
  (** [type_check_fsm env f] type checks FSM [f] in environment [env], raising [!Typing_error] when 
      appropriate. Passing the optional [mono] argument also checks that all types occuring in the
      FSM definitions are monomorphic. This is required, for instance to generate C or VHDL code. *)

val type_check_stimuli: Fsm.t -> Stimuli.t -> Stimuli.t
  (** [type_check_stimuli f s] type checks a sequence [s] of stimuli for a FSM [f], raising [!Typing_error] when 
      appropriate (for example if an event [e] refers to a non-existent input of [f] or if the type of value asssociated 
      to [e] does not match the type of the corresponding input in [f]. *)
