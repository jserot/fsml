type typ = 
  | TyInt of int_range option

and int_range = int * int

type t = {
  m_name: string;
  m_states: string list;
  m_inps: (string * typ) list;
  m_outps: (string * typ) list;
  m_vars: (string * typ) list;  
  m_init: State.t * Action.t list;
  m_body: (State.t * Transition.t list) list; (* Transitions, indexed by source state *)
     (* m_body = [case_1;...;case_n]
       means
        "while ( 1 ) { switch ( [state] ) { [case_1]; ...; [case_n] } }" *)
  }

let make f = 
  let open Fsm in
  let srm_states ts = 
    let rec scan acc ts = match ts with
      | [] -> List.rev acc
      | (src,_,_,_)::rest -> if List.mem src acc then scan acc rest else scan (src::acc) rest in
    scan [] ts in
  { m_name = f.id;
    m_states = f.states;
    m_inps = List.map (fun id -> id, TyInt None) f.inps;
    m_outps = List.map (fun id -> id, TyInt None) f.outps;
    m_vars = List.map (fun id -> id, TyInt None) f.vars;
    m_init = f.itrans;
    m_body = List.map (fun s -> s, List.filter (fun (s',_,_,_) -> s=s') f.trans) (srm_states f.trans)
    }

