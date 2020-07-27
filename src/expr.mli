(** Simple (int) expressions for FSMs *)

type ident = string 
  [@@deriving show {with_path=false}, yojson]
  (** The type of identifiers occuring in expressions *)

type value = int 
  [@@deriving show {with_path=false}, yojson]
  (** The type of expression values *)

(** The type of expressions *)
type t = 
  EConst of value            (** Constants *)   
| EVar of ident              (** Input, output or local variable *)
| EBinop of binop * t * t    (** Binary operation *)
  [@@deriving show {with_path=false}, yojson]

and binop = Plus | Minus | Mult | Div
and relop = | Eq | NEq | Lt | Gt | Lte | Gte

type env = (ident * value option) list
  
exception Unknown of ident
exception Unbound of ident
exception Illegal_expr

val to_string: t -> string

val of_string: string -> t

val lookup: env -> ident -> value

val eval: env -> t -> value

val lexer: string -> Genlex.token Stream.t
val parse: Genlex.token Stream.t -> t 

val binops : (string * (binop * (int -> int -> int))) list
val relops : (string * (relop * (int -> int -> bool))) list

val string_of_binop: binop -> string
val string_of_relop: relop -> string

