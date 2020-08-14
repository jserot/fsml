type t = 
  | Assign of Expr.ident * Expr.t        (* var/i/o, value *)
  [@@deriving show {with_path=false}, yojson]

let to_string a = match a with
  | Assign (id, expr) -> id ^ ":=" ^ Expr.to_string expr

(* Simulation *)

let perform env env' a = match a with
  | Assign (id, expr) -> 
     Expr.update_env env' id (Expr.eval (env @ env') expr)
