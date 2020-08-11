type t = Action.t list

let to_string = function
| [] -> "*"
| evs -> Misc.string_of_list ~f:Action.to_string ~sep:"," evs
