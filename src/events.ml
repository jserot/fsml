type t = Event.t list

let to_string = function
| [] -> "*"
| evs -> Misc.string_of_list ~f:Event.to_string ~sep:"," evs
