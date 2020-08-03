type state = string
  [@@deriving show {with_path=false}, yojson]
           
type t = state * Guard.t list * Action.t list * state
  [@@deriving show {with_path=false}, yojson]

val to_string: t -> string
