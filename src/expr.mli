(** {1 Simple (int) expressions for FSMs} *)

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
  [@@deriving show]
  (** Value [None] means [Undefined] *)

val binops: (string * (int -> int -> int)) list
  (** ["+"; "-"; "*"; "/"] *)
val relops: (string * (int -> int -> bool)) list
  (** ["="; "!="; "<"; ">"; ">="; "<="] *)

(** {2 Parsing} *)

val keywords: Lexing.Keywords.t

val parse: Genlex.token Stream.t -> t

val of_string: string -> t

(** {2 Printing} *)

val to_string: t -> string

(** {2 Simulation} *)

val lookup_env: env -> ident -> value
val update_env: env -> ident -> value -> env
  
exception Unknown of ident
exception Unbound of ident
exception Illegal_expr of t

val eval: env -> t -> value
