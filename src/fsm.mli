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

(** {1 Finite State Machines} *)

type t = {
  id: string;  (** Name *)
  states: State.t list;
  inps: (string * Types.t) list;  (** Inputs *)
  outps: (string * Types.t) list; (** Outputs *)
  vars: (string * Types.t) list;  (** Local variables *)
  trans: Transition.t list;
  itrans: State.t * Action.t list;  (** Initial transition *)
} [@@deriving show {with_path=false}, yojson]
  (** The static description of a FSM *)

(* { 2 JSON export/import} *)
       
val to_string: t -> string
  (** [to_string m] writes a representation of FSM [m] as a string using the [Yojson] library. *)

val from_string: string -> t
  (** [from_string s] returns the FSM [m] stored in string [s] using the [Yojson] library *)

val to_file: fname:string -> t -> unit
  (** [to_file f] writes a representation of FSM [m] in file [f] using the [Yojson] library. *)
    
val from_file: fname:string -> t
  (** [from_file f] returns the FSM [m] stored in file [f] using the [Yojson] library *)
