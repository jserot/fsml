type state = string
  [@@deriving show {with_path=false}, yojson]
             
module Expr = Expr
module Guard = Guard
module Action = Action
module Transition = Transition
            
type t = {
  id: string;
  states: state list;
  istate: state * Action.t list;
  inps: string list;
  outps: string list;
  vars: string list;
  trans: Transition.t list
} [@@deriving show {with_path=false}, yojson]

(* Helping parsers *)

val mk_trans: string -> Transition.t

(* Serializing/deserializing fns *)
       
val to_string: t -> string

val from_string: string -> t

val to_file: fname:string -> t -> unit
  
val from_file: fname:string -> t

(* Simulation *)

type ctx = {
  state: state;
  env: Expr.env
  }
[@@deriving show]

val step: ctx -> t -> ctx

