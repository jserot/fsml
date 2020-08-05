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
  vars: var list;
  trans: Transition.t list
} [@@deriving show {with_path=false}, yojson]

(* Serializing/deserializing fns *)
       
let to_string m =
  m |> to_yojson |> Yojson.Safe.to_string 

let from_string s = 
  match Yojson.Safe.from_string s |> of_yojson with
    | Ok v -> v
    | Error _ -> Yojson.json_error "Fsm.from_string: invalid JSON string"

let to_file ~fname m = 
  m |> to_yojson |> Yojson.Safe.to_file fname;
  Printf.printf "Wrote file %s\n" fname
  
let from_file ~fname = 
  match fname |> Yojson.Safe.from_file |> of_yojson with
    | Ok v -> v
    | Error _ -> Yojson.json_error "Fsm.from_string: invalid JSON file"

(* Helping parsers *)

let mk_trans s = Transition.of_string s

(* Simulation *)

type ctx = {
  state: state;
  env: Expr.env
  }

let step ctx m = 
    match List.find_opt (Transition.is_fireable ctx.state ctx.env) m.trans with
    | Some (_, _, acts, dst) -> 
       { state = dst;
         env = List.fold_left Action.perform ctx.env acts }
    | None ->
       ctx

