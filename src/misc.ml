let string_of_list ~f ~sep l =
  let rec h = function
      [] -> ""
    | [x] -> f x
    | x::xs -> f x ^ sep ^ h xs in
  h l

let list_parse ~parse_item ~sep s =
 let rec parse s =
  match Stream.peek s with
  | Some _ ->
     let e = parse_item s in
     let es = parse_aux s in
     e::es
  | None ->
     []
 and parse_aux s =
  match Stream.peek s with
  | Some (Genlex.Kwd sep') when sep=sep' ->
     Stream.junk s;
     parse s
  | _ ->
     [] in
 parse s

let mk_binary_minus s = s |> String.split_on_char '-' |> String.concat " - "

let lexer keywords s = s |> mk_binary_minus |> Stream.of_string |> Genlex.make_lexer keywords 
