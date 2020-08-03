(** Simple (int) expressions for FSMs *)

type ident = string 
  [@@deriving show {with_path=false}, yojson]
  (** The type of identifiers occuring in expressions *)

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
  
exception Unknown of ident
exception Unbound of ident
exception Illegal_expr of t

val to_string: t -> string

val eval: env -> t -> value

val binops : (string * (int -> int -> int)) list
val relops : (string * (int -> int -> bool)) list

val lexer: string -> Genlex.token Stream.t

val parse: Genlex.token Stream.t -> t

val of_string: string -> t

