type state = string
  [@@deriving show {with_path=false}, yojson]
type var = string
  [@@deriving show {with_path=false}, yojson]
             
module Expr = Expr
module Guard = Guard
module Action = Action
module Transition = Transition
            
type t = {
  id: string;
  states: state list;
  istate: state * Action.t list;
  vars: var list;  (** Inputs, outputs and local variables *)
  trans: Transition.t list
} [@@deriving show {with_path=false}, yojson]

(* Helping parsers *)

val mk_trans: string -> Transition.t

(* Serializing/deserializing fns *)
       
val to_string: t -> string

val from_string: string -> t

val to_file: fname:string -> t -> unit
  
val from_file: fname:string -> t
