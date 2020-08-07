(** {1 C backend} *)

type config = {
  mutable state_var: string;  (** Name of variable storing the current state (default: [state]) *)
  mutable incl_file: string   (** Name of the support include file (default: [fsml.h] *)
  }

val cfg: config

exception Error of string * string   (* where, message *)

val write: fname:string -> Fsm.t -> unit
  (** [write fname m] writes in files [fname.h] and [fname.c] a representation of FSM [m] as a C function.
      This function has prototype [void fsm_xxx(ctx_t *ctx)], where [xxx] is [m.m_id] and [ctx_t] is the
      type of a structure recording the value of inputs and outputs of the machine.
      Each call to the [fsm_xxx] function will correspond to one execution step of the machine: it 
      first looks for a fireable transition (depending on the values of the inputs read in the context [ctx]
      and of the local variables) and, if found, performs the action associated to this transition (updating 
      the value of outputs and local variables) and updates the current state. *)
