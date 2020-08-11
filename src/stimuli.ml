type t = Events.t list

let to_string = Misc.string_of_list ~f:Events.to_string ~sep:";" 
