type state = string
  [@@deriving show {with_path=false}, yojson]
           
type t = state * Guard.t list * Action.t list * state
  [@@deriving show {with_path=false}, yojson]

let to_string (src,guards,actions,dst) =
  let s0 = src ^ " -> " ^ dst in
  let s1 = Misc.string_of_list ~f:Guard.to_string ~sep:"." guards in
  let s2 = Misc.string_of_list ~f:Action.to_string ~sep:"," actions in
  let s3 = match s1, s2 with
    | "", "" -> ""
    | s1, "" -> s1
    | s1, s2 -> s1 ^ "/" ^ s2 in
  match s3 with
    "" -> s0
  | _ -> s0 ^ " [" ^ s3 ^ "]"
