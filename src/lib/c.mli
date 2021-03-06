(**********************************************************************)
(*                                                                    *)
(*              This file is part of the FSML library                 *)
(*                     github.com/jserot/fsml                         *)
(*                                                                    *)
(*  Copyright (c) 2020-present, Jocelyn SEROT.  All rights reserved.  *)
(*                                                                    *)
(*  This source code is licensed under the license found in the       *)
(*  LICENSE file in the root directory of this source tree.           *)
(*                                                                    *)
(**********************************************************************)

(** {1 C backend} *)

type config = {
  mutable state_var: string;  (** Name of variable storing the current state (default: [state]) *)
  mutable incl_file: string   (** Name of the support include file (default: [fsml.h] *)
  }

val cfg: config

exception Error of string * string   (* where, message *)

val write: ?dir:string -> prefix:string -> Fsm.t -> unit
  (** [write prefix m] writes in files [prefix.h] and [prefix.c] a representation of FSM [m] as a C function.
      This function has prototype [void fsm_xxx(ctx_t *ctx)], where [xxx] is [m.m_id] and [ctx_t] is the
      type of a structure recording the value of inputs and outputs of the machine.
      Each call to the [fsm_xxx] function will correspond to one execution step of the machine: it 
      first looks for a fireable transition (depending on the values of the inputs read in the context [ctx]
      and of the local variables) and, if found, performs the action associated to this transition (updating 
      the value of outputs and local variables) and updates the current state.
      The generated files are written in the current working directory unless a target directory is specified
      with the [dir] argument. If the target directory does not exist, an attempt is made to create it. *)
