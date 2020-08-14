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

(** Simulation stimuli *)

type t = Events.t list
  (** A [stimuli] is a sequence of event sets.
      Example [[x:=1,y:=1; x:=0]] means that both [x] and [y] are set to [1] at step 1, then [x] is 
      set to [0] at step [2]. *)

(* {2 Printing} *)

val to_string: t -> string
