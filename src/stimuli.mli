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

type clk = int
  [@@deriving show {with_path=false}]
  (** Clock cycle counter *)

type t = clk * Event.t list
  [@@deriving show {with_path=false}]
  (** A [stimuli] is list of events occuring at a given clock cycle.
      Example [4, [x:=1,y:=1] means that both [x] and [y] are set to [1] at clock cycle 4. *)

val ( @@@ ): t list -> t list -> t list
  (** The [@@@] infix operator merges two sequences of stimuli wrt. clock cycles.
      Ex: [[(0,[x:=1]; (2;[x:=0])] @@@ [(1,[y:=1]); [2;y:=0]]] gives  [(0,[x:=1]; (1,[y:=1]); (2;[x:=0;y:=0])]. *)
  
val merge: t list list -> t list
  (** [merge [st1; ...: stn] merges n sequences of stimuli wrt. clock cycles.
      In other words, [merge [l1; l2; ...; ln]] is [l1 @@@ l2 @@@ ... @@@ ln]. *)

(** {2 Wrappers} *)
  
val changes: string -> (clk * Expr.e_val) list -> t list
  (** [changes name vcs] builds a list of stimuli from a list [vcs] of {i value changes} related to signal
      [name], a value change being a pair of the clk cycle and a value.
      Ex: [changes "x" [0,Int 1; 2,Int 0]] is [[0,[x:=1]; 2,[x:=0]]]. *)

(** {2 Printing} *)

val to_string: t -> string
