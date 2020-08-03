type t = Expr.t
  (* Note: ideally, this should be [bool Expr.t] where [t] is defined as a GADT.
     Unfortunately, GADTs are not supported by most of [deriving] PPX extensions :(
     See branch [gadt] for a preliminary attempt *)
  [@@deriving show {with_path=false}, yojson]

exception Illegal_guard_expr of Expr.t

let eval env exp =
  match Expr.eval env exp with
  | Bool b -> b
  | Int _ -> raise (Illegal_guard_expr exp)
  (* Note: this is typically this kind of runtime failure that GADTs can make impossible.. *)

let to_string exp = Expr.to_string exp
