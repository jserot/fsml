(** Fsm expressions *)

type ident = string 

type value = int 

type t = 
  EConst of value            (** Constants *)   
| EVar of ident              (** Input, output or local variable *)
| EBinop of binop * t * t    (** Binary operation *)

and binop = Plus | Minus | Mult | Div

and relop = | Eq | NEq | Lt | Gt | Lte | Gte

type env = (ident * value option) list

exception Unknown of ident
exception Unbound of ident
exception Illegal_expr

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

(* Parsing *)

(* BNF :
   <exp>  ::= INT
   | ID
   | <exp> <op> <exp>
   | '(' <exp> ')' <int>
   <op>    ::= '+' | '-' | '*' | '/'
 *)

let keywords = [
    "+"; "-"; "*"; "/";
    "="; "!="; "<"; ">"; "<="; ">=";
    "("; ")"; ";"]

let mk_binary_minus s = s |> String.split_on_char '-' |> String.concat " - "
                      
let lexer s = s |> mk_binary_minus |> Stream.of_string |> Genlex.make_lexer keywords 

open Genlex
   
let rec p_exp0 s =
  match Stream.next s with
    | Int n -> EConst n
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
  | Some (Kwd "*") -> Stream.junk s; let e2 = p_exp1 s in EBinop(Mult, e1, e2)
  | Some (Kwd "/") -> Stream.junk s; let e2 = p_exp1 s in EBinop(Div, e1, e2)
  | _ -> e1
  
and p_exp s =
  let e1 = p_exp1 s in p_exp3 e1 s
                     
and p_exp3 e1 s =
  match Stream.peek s with
  | Some (Kwd "+") -> Stream.junk s; let e2 = p_exp s in EBinop(Plus, e1, e2)
  | Some (Kwd "-") -> Stream.junk s; let e2 = p_exp s in EBinop(Minus, e1, e2)
  | _ -> e1

let parse = p_exp

let of_string s = s |> lexer |> p_exp

let rec to_string e = match e with
    EConst c -> string_of_int c
  | EVar n ->  n
  | EBinop (op,e1,e2) -> to_string e1 ^ string_of_binop op ^ to_string e2 (* TODO : add parens *)

and string_of_binop op = List.assoc op @@ List.map (fun (s,(op,_)) -> op, s) binops

let string_of_relop op = List.assoc op @@ List.map (fun (s,(op,_)) -> op, s) relops

