(** {1 Sequential model (used by C and VHDL backends)} *)

type t = {
  m_name: string;
  m_states: string list;
  m_inps: (string * Types.t) list;
  m_outps: (string * Types.t) list;
  m_vars: (string * Types.t) list;  
  m_init: State.t * Action.t list; (** Initial transition *)
  m_body: (State.t * Transition.t list) list; (** Transitions, indexed by source state *)
  }

val make: Fsm.t -> t
  (** [make f] builds a sequential model from FSM [f]. The FSM is first type-checked. *)
