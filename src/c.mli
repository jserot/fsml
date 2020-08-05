(* C backend *)

type config = {
  state_var_name: string;
  incl_file: string
  }

val cfg: config

exception Error of string * string   (* where, message *)

val write: fname:string -> Fsm.t -> unit
