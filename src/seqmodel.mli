(** {1 Sequential model (used by C and VHDL backends)} *)

type typ = 
  | TyInt of int_range option

and int_range = int * int

type t = {
  m_name: string;
  m_states: string list;
  m_inps: (string * typ) list;
  m_outps: (string * typ) list;
  m_vars: (string * typ) list;  
  m_init: State.t * Action.t list; (** Initial transition *)
  m_body: (State.t * Transition.t list) list; (** Transitions, indexed by source state *)
  }

val make: Fsm.t -> t
