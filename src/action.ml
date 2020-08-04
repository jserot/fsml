type t = 
  | Assign of Expr.ident * Expr.t        (* var/i/o, value *)
  [@@deriving show {with_path=false}, yojson]

let to_string a = match a with
  | Assign (id, expr) -> id ^ ":=" ^ Expr.to_string expr

let rec p_act s = match Stream.next s with
  | Genlex.Ident e1 -> p_act1 e1 s
  | _ -> raise Stream.Failure
and p_act1 e1 s = match Stream.next s with
  | Genlex.Kwd ":=" -> let e2 = Expr.parse s in Assign (e1, e2)
  | _ -> raise Stream.Failure

let parse = p_act

let keywords = [":="]

let lexer = Misc.lexer (Expr.keywords @ keywords)

let of_string s = p_act (lexer s)

(* Simulation *)

let perform env a = match a with
  | Assign (id, expr) -> 
     Expr.update_env env id (Expr.eval env expr)
