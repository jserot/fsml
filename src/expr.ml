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

exception Unbound of ident
exception Unknown of ident
exception Illegal_expr of t

let lookup env id = 
  try
    match List.assoc id env with
      Some v -> v
    | None -> raise (Unbound id)
  with 
    Not_found -> raise (Unknown id)

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
  | EVar id -> lookup env id 
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

(* BNF :
   <exp>  ::= INT
   | ID
   | <exp> <op> <exp>
   | '(' <exp> ')' <int>
   <op>    ::= '+' | '-' | '*' | '/' | '=' | ...
 *)

let keywords = List.map fst binops @ List.map fst relops @ ["("; ")"]

let lexer = Misc.lexer keywords
                      
open Genlex
   
let rec p_exp0 s =
  match Stream.next s with

    | Int n -> EInt n
    | Ident i -> EVar i
    | Kwd "(" ->
       let e = p_exp s in
       begin match Stream.peek s with
       | Some (Kwd ")") -> Stream.junk s; e
       | _ -> raise Stream.Failure
       end
    | _ -> raise Stream.Failure

and p_exp1 s =
  let e1 = p_exp0 s in
  p_exp2 e1 s
  
and p_exp2 e1 s =
  match Stream.peek s with
  | Some (Kwd op) when List.mem_assoc op binops -> Stream.junk s; let e2 = p_exp1 s in EBinop(op, e1, e2)
  | _ -> e1
  
(* Warning : no arithmetic operator precedence here ! *) 

and p_exp3 e1 s =
  match Stream.peek s with
  | Some (Kwd op) when List.mem_assoc op relops -> Stream.junk s; let e2 = p_exp s in ERelop(op, e1, e2)
  | _ -> e1

and p_exp s =
  let e1 = p_exp1 s in
  p_exp3 e1 s

let parse = p_exp

let of_string s = s |> lexer |> p_exp


