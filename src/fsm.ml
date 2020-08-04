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

let mk_trans s = Transition.of_string s

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

(* Simulation *)

type event = Action.t list

type clk = int

type trace = clk * state * Expr.env 

let run ~state ~env ~stim m = 
  let rec eval (clk, state, env, trace) stim =
    match stim with
    | [] -> List.rev trace (* Done ! *)
    | st::rest ->
       let env' = List.fold_left Action.perform env st in
       let state', env'' = 
         begin
           match List.find_opt (Transition.is_fireable state env') m.trans with
           | Some (_, _, acts, dst) -> 
              dst,
              List.fold_left Action.perform env' acts
           | None ->
              state,
              env'
         end in
       eval (clk+1, state', env'', (clk, state', env'') :: trace) rest in
  eval (1, state, env, [0, state, env]) stim
