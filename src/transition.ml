type state = string
           
type t = state * Guard.t list * Action.t list * state

let string_of_guards guards = Misc.string_of_list ~f:Guard.to_string ~sep:"." guards

let string_of_actions actions = Misc.string_of_list ~f:Action.to_string ~sep:"," actions

let to_string ?(label_sep="/") ?(label_ldelim="") ?(label_rdelim="") (src,guards,actions,dst) =
  let s0 = src ^ " -> " ^ dst
  and s3 = match string_of_guards guards, string_of_actions actions with
    | "", "" -> ""
    | s1, "" -> s1
    | s1, s2 -> s1 ^ label_sep ^ s2 in
  match s3 with
    "" -> s0
  | _ -> s0 ^ " " ^ label_ldelim ^ s3 ^ label_rdelim

let guards_of_string s = Misc.list_parse ~parse_item:Guard.parse ~sep:";" (Expr.lexer s)

let conds_of_string s = Misc.list_parse ~parse_item:Action.parse ~sep:";" (Expr.lexer s)
