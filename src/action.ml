type t = 
  | Assign of Expr.ident * Expr.t        (* var/i/o, value *)
  [@@deriving show {with_path=false}, yojson]

let to_string a = match a with
  | Assign (id, expr) -> id ^ ":=" ^ Expr.to_string expr

(* let of_string s = Parsing.parse Fsm_parser.action_top s *)
(* let of_string _ = Result.error () *)

(* Simulation *)

let perform env a = match a with
  | Assign (id, expr) -> 
     Expr.update_env env id (Expr.eval env expr)
