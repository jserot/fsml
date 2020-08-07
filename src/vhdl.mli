(** {1 VHDL backend} *)

type config = {
  mutable state_var: string; (** Name of signal storing the current state (default: [state]) *)
  mutable reset_sig: string; (** Name of the asynchronous reset input (default: [rst]) *)
  mutable clk_sig: string;   (** Name of the clock input (default: [clk]) *)
  mutable use_numeric_std: bool; (** Encode integers as VHDL [Signed] or [Unsigned] (default: false) *)
  mutable act_sem: act_semantics; (** Use sequential or synchronous semantics for actions (default: sequential) *)
  }

and act_semantics =  
  | Sequential       
  | Synchronous     
  (** Interpretation of actions associated to transitions.
      With a a [Sequential] interpretation, the sequence [x:=x+1,y:=x], with [x=1], will lead to [x=2,y=2].
      With a a [Synchronous] interpretation, the same sequence will lead to [x=2,y=1].
      The default behavior is set to [Sequential] in order to make OCaml, C and VHDL behaviors observationaly equivalent. 
      Synchronous behavior is implemented (and can be selected) but potentially breaks this equivalence because it
      is not (yet) implemented at the OCaml and C level. *)

val cfg : config

exception Error of string * string   (* where, message *)

val write: fname:string -> Fsm.t -> unit
  (** [write fname m] writes in file [fname.vhd] a representation of FSM [m] as a VHDL entity and architecture.
      The architecture is a synchronous FSM, with a [clk] signal and a asynchronous, active high, [rst] signal. 
      Transitions are performed on the rising edge of the [clk] signal. *)
