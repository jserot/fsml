(* Sequential model (used by C and VHDL backends) *)

type typ = 
  | TyInt of int_range option

and int_range = int * int

type t = {
  m_name: string;
  m_states: string list;
  m_inps: (string * typ) list;
  m_outps: (string * typ) list;
  m_vars: (string * typ) list;  
  m_init: Fsm.state * Action.t list;
  m_body: (Fsm.state * Transition.t list) list; (* Transitions, indexed by source state *)
     (* m_body = [case_1;...;case_n]
       means
        "while ( 1 ) { switch ( [state] ) { [case_1]; ...; [case_n] } }" *)
  }

val make: Fsm.t -> t
