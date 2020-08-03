type t = Expr.relop * Expr.t * Expr.t
  [@@deriving show {with_path=false}, yojson]

let eval env (op, id, exp) = (snd @@ List.assoc op Expr.relops) (Expr.lookup env id) (Expr.eval env exp)

let to_string (op, e1, e2) = Expr.to_string e1 ^ Expr.string_of_relop op ^ Expr.to_string e2 (* TODO: add parens *)
