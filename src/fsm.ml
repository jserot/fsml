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

(* Helping parsers *)

let mk_guard s = Misc.list_parse ~parse_item:Guard.parse ~sep:"," (Expr.lexer s)
let mk_action s = Misc.list_parse ~parse_item:Action.parse ~sep:"," (Expr.lexer s)

(* Serializing/deserializing fns *)
       
let to_string m =
  m |> to_yojson |> Yojson.Safe.to_string 

let from_string s = 
  match Yojson.Safe.from_string s |> of_yojson with
    | Ok v -> v
    | Error _ -> Yojson.json_error "Fsm.from_string: invalid JSON string"

let to_file fname m = 
  m |> to_yojson |> Yojson.Safe.to_file fname;
  Printf.printf "Wrote file %s\n" fname
  
let from_file fname = 
  match fname |> Yojson.Safe.from_file |> of_yojson with
    | Ok v -> v
    | Error _ -> Yojson.json_error "Fsm.from_string: invalid JSON file"
