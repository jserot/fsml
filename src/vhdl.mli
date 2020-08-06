(* VHDL backend *)

type config = {
  mutable enum_prefix: string;
  mutable state_var: string;
  mutable reset_sig: string;
  mutable clk_sig: string;
  mutable use_numeric_std: bool;
  mutable act_sem: act_semantics;
  }

and act_semantics =  (** Interpretation of actions associated to transitions *)
  | Sequential        (** sequential (ex: [x:=x+1,y:=x] with [x=1] gives [x=2,y=2]) *)
  | Synchronous       (** synchronous (ex: [x:=x+1,y=x] with [x=1] gives [x=2,y=1]) *)

val cfg : config

exception Error of string * string   (* where, message *)

val write: fname:string -> Fsm.t -> unit
