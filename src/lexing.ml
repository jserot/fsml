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
