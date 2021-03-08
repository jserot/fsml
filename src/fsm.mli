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
  states: (State.t * Valuation.t) list;
  inps: (string * Types.t) list;  (** Inputs *)
  outps: (string * Types.t) list; (** Outputs *)
  vars: (string * Types.t) list;  (** Local variables *)
  trans: Transition.t list;
  itrans: State.t * Action.t list;  (** Initial transition *)
} [@@deriving show {with_path=false}, yojson]
  (** The static description of a FSM *)

(** {2 Transformation functions} *)

exception Unknown_output of string

val mealy_outps : ?outps:string list -> t -> t
  (** mealy_outps os m] returns the FSM obtained by moving the assignation of outputs
      listed in [outps] from states to all incoming transitions. When the [outps] parameter is empty 
      or omitted, the transformation is applied to all outputs occuring in each state. Raises [Unknown_output] if 
      [outps] contains a symbol not declared as output. *)

val moore_outps : ?outps:string list -> t -> t
  (** [moore_outps os m] is the dual function of {!mealy_outps}. For each output [o] listed in
      in [outps], whenever all transitions leading to a state [s] carry the same action [o:=v], it removes 
      these actions and adds the assignation [o=v] to state [s]. The transformation is not applied if
      - the corresponding action does not occur on all transitions leading to state [s],
      - the value assigned to output [o] is not a constant,
      - not all actions assign the same value to [o]
      If [outps] is empty, the transformation is applied to all outputs. Raises [Unknown_output] if 
      [outps] contains a symbol not declared as output. *)
  
(** {2 JSON export/import} *)
       
val to_string: t -> string
  (** [to_string m] writes a representation of FSM [m] as a string using the [Yojson] library. *)

val from_string: string -> t
  (** [from_string s] returns the FSM [m] stored in string [s] using the [Yojson] library *)

val to_file: fname:string -> t -> unit
  (** [to_file f] writes a representation of FSM [m] in file [f] using the [Yojson] library. *)
    
val from_file: fname:string -> t
  (** [from_file f] returns the FSM [m] stored in file [f] using the [Yojson] library *)
