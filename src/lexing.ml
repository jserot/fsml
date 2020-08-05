module type KEYWORDS = 
sig
  type t
  val make: string list -> t
  val elems: t -> string list
  val add: t -> string list -> t
  val union: t -> t -> t
end

module Keywords = struct
  module R = Set.Make(String)
  type t = R.t
  let elems = R.elements
  let make = R.of_list
  let add s xs = List.fold_left (Fun.flip R.add) s xs
  let union = R.union
end

let mk_binary_minus s = s |> String.split_on_char '-' |> String.concat " - "

let lexer keywords s =
  s |> mk_binary_minus |> Stream.of_string |> Genlex.make_lexer (Keywords.elems keywords )

exception Syntax_error of string

let string_of_token t =
  let open Genlex in
  match t with
  | Ident i -> i
  | Kwd k -> k
  | Int i -> string_of_int i
  | Float i -> string_of_float i
  | String s -> s
  | Char c -> String.make 1 c 

let syntax_error s = raise (Syntax_error (Misc.string_of_opt string_of_token (Stream.peek s)))

