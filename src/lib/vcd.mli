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

(** {1 VCD output} *)

val write: fname:string -> fsm:Fsm.t -> Tevents.t list -> unit
  (** [write ~fname:file ~fsm:f evs] writes a representation of a list of timed events sets [evs],
      for FSM [f] in VCD (Value Change Dump) format in file [file]. *)

val view: ?fname:string -> ?cmd:string -> fsm:Fsm.t -> Tevents.t list -> int
    (** [view m evs] views a simulation result for FSM [m] by first writing a [.vcd] file 
        and then launching a VCD viewer application. The name of the output file and
        of the viewer application can be changed using the [fname] and [cmd] optional
        arguments. Returns the issued command exit status. *)
