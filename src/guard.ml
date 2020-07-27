type t = Expr.relop * Expr.t * Expr.t

let eval env (op, id, exp) = (snd @@ List.assoc op Expr.relops) (Expr.lookup env id) (Expr.eval env exp)

let parse s = 
  let open Genlex in
  let relops = List.map (fun (s,(op,_)) -> s, op) Expr.relops in
  match Stream.next s with
  | Ident v ->
     begin match Stream.next s with
     | Kwd op when List.mem_assoc op relops ->
        let e = Expr.parse s in (List.assoc op relops, v, e)
     | _ -> raise Stream.Failure 
     end
  | _ -> raise Stream.Failure

let of_string s = parse (Expr.lexer s)

let to_string (op, e1, e2) = Expr.to_string e1 ^ Expr.string_of_relop op ^ Expr.to_string e2 (* TODO: add parens *)
