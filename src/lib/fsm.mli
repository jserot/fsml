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
  (** [mealy_outps os m] returns the FSM obtained by moving the assignation of outputs
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
      If [outps] is omitted ot empty, the transformation is applied to all outputs. Raises [Unknown_output] if 
      [outps] contains a symbol not declared as output. *)

exception Unknown_var of string
exception Illegal_var_type of string * Types.t
                            
val defactorize: vars:(string * Expr.e_val) list -> ?cleaned:bool -> t -> t
  (** [defactorize vars m] returns an equivalent FSM obtained by removing variable listed in [vars] from [m] and 
      introducing new states accordingly.
      The value attached to each variable is used to select the initial state in the defactorized FSM. 
      Unreachable states are removed from the
      resulting automata unlesse the optional argument [clean] is set to false. Raises {!Unknown_var} if
      [vars] contains a symbol not declared as variable. Raises {!Illegal_var_type} if
      the specified var(s) do(es) not have an enumerable type (i.e. have not been declared with a range). *)
  
val clean: t -> t
  (** [clean m] removes all unreachable states (and associated transitions) from m *)
  
(** {2 JSON export/import} *)
       
val to_string: t -> string
  (** [to_string m] writes a representation of FSM [m] as a string using the [Yojson] library. *)

val from_string: string -> t
  (** [from_string s] returns the FSM [m] stored in string [s] using the [Yojson] library *)

val to_file: fname:string -> t -> unit
  (** [to_file f] writes a representation of FSM [m] in file [f] using the [Yojson] library. *)
    
val from_file: fname:string -> t
  (** [from_file f] returns the FSM [m] stored in file [f] using the [Yojson] library *)
