type t = Expr.ident * Expr.e_val
  [@@deriving show {with_path=false}]

let to_string a = match a with
  | (id, v) -> id ^ ":=" ^ Expr.string_of_value v
