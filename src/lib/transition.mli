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

(** {1 FSM Transitions} *)

type t = State.t * Guard.t list * Action.t list * State.t
  [@@deriving show {with_path=false}, yojson]
  (** [(src,guards,actions,dst)] means that the FSM will go from state [src] to state 
      [dst] whenever all guards listed in [guards] evaluate to [true], performing, sequentially,
      all actions listed in [actions]. *)

(** {2 Printers} *)

val to_string: t -> string

(** {2 Simulation} *)

val is_fireable: State.t -> Expr.env -> t -> bool
  (** [is_fireable src env t] returns [true] iff transition [t] is fireable
      when the enclosing FSM is in state [state] and the inputs and local variables
      have values recorded in environment [env]. *)
