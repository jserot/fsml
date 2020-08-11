type t = {
  id: string;
  states: State.t list;
  itrans: State.t * Action.t list;
  inps: string list;
  outps: string list;
  vars: string list;
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

(* Simulation *)

type ctx = {
    state: State.t;
    env: Expr.env
  }
[@@deriving show]

let step ctx m = 
    match List.find_opt (Transition.is_fireable ctx.state ctx.env) m.trans with
    | Some (_, _, acts, dst) -> 
       { state = dst;
         env = List.fold_left Action.perform ctx.env acts }
    | None ->
       ctx

