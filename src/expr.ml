(** Fsm expressions *)

type ident = string 
  [@@deriving show {with_path=false}, yojson]

type value = int 
  [@@deriving show {with_path=false}, yojson]

type t = 
  EConst of value            (** Constants *)   
| EVar of ident              (** Input, output or local variable *)
| EBinop of binop * t * t    (** Binary operation *)
  [@@deriving show {with_path=false}, yojson]

and binop = Plus | Minus | Mult | Div

and relop = | Eq | NEq | Lt | Gt | Lte | Gte

type env = (ident * value option) list

exception Unbound of ident
exception Unknown of ident

let lookup env id = 
  try
    match List.assoc id env with
      Some v -> v
    | None -> raise (Unbound id)
  with 
    Not_found -> raise (Unknown id)

let binops = [
    "+", (Plus, ( + ));
    "-", (Minus, ( - ));
    "*", (Mult, ( * ));
    "/", (Div, ( / ));
  ]

let relops = [
    "=", (Eq, ( = ));
    "!=", (NEq, ( <> ));
    "<", (Lt, ( < ));
    ">", (Gt, ( > ));
    "<=", (Lte, ( <= ));
    ">=", (Gte, ( >= ))
  ]

let rec eval : env -> t -> value = fun env exp ->
  match exp with
    EConst v -> v
  | EVar id -> lookup env id 
  | EBinop (op, exp1, exp2) -> (List.assoc op @@ List.map snd binops) (eval env exp1) (eval env exp2)

let rec to_string e = match e with
    EConst c -> string_of_int c
  | EVar n ->  n
  | EBinop (op,e1,e2) -> to_string e1 ^ string_of_binop op ^ to_string e2 (* TODO : add parens *)

and string_of_binop op = List.assoc op @@ List.map (fun (s,(op,_)) -> op, s) binops

let string_of_relop op = List.assoc op @@ List.map (fun (s,(op,_)) -> op, s) relops

