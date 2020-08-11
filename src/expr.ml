(** Fsm expressions *)

type ident = string 
  [@@deriving show {with_path=false}, yojson]

type value = 
  | Int of int
  | Bool of bool 
  [@@deriving show {with_path=false}, yojson]

type t = 
  EInt of int
| EVar of ident             
| EBinop of string * t * t
| ERelop of string * t * t
  [@@deriving show {with_path=false}, yojson]

type env = (ident * value option) list
  [@@deriving show]

exception Unbound of ident
exception Unknown of ident
exception Illegal_expr of t

let lookup_env env id = 
  try
    match List.assoc id env with
      Some v -> v
    | None -> raise (Unbound id)
  with 
    Not_found -> raise (Unknown id)

let update_env env k v = 
  let rec scan = function
    | [] -> []
    | (k',v')::rest -> if k=k' then (k, Some v)::rest else (k',v')::scan rest in
  scan env

let binops = [
    "+", ( + );
    "-", ( - );
    "*", ( * );
    "/", ( / );
  ]

let relops = [
    "=", ( = );
    "!=", ( <> );
    "<", ( < );
    ">", ( > );
    "<=", ( <= );
    ">=", ( >= )
  ]

let rec eval : env -> t -> value = fun env exp ->
  let lookup_binop op = 
    try List.assoc op binops
    with Not_found -> raise (Unknown op) in
  let lookup_relop op = 
    try List.assoc op relops
    with Not_found -> raise (Unknown op) in
  match exp with
  | EInt v -> Int v
  | EVar id -> lookup_env env id 
  | EBinop (op, e1, e2) ->
     let f = lookup_binop op in
     begin match eval env e1, eval env e2 with
       | Int v1, Int v2 -> Int (f v1 v2)
       | _, _ -> raise (Illegal_expr exp)
     end
  | ERelop (op, e1, e2) ->
     let f = lookup_relop op in
     begin match eval env e1, eval env e2 with
       | Int v1, Int v2 -> Bool (f v1 v2)
       | _, _ -> raise (Illegal_expr exp)
     end

let rec to_string e = match e with
    EInt c -> string_of_int c
  | EVar n ->  n
  | EBinop (op,e1,e2) -> to_string e1 ^ op ^ to_string e2 (* TODO : add parens *)
  | ERelop (op,e1,e2) -> to_string e1 ^ op ^ to_string e2 (* TODO : add parens *)


