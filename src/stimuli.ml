type t = Events.t list

let parse s =
  try Misc.list_parse ~parse_item:Events.parse ~sep:";" s
  with Stream.Failure -> Lexing.syntax_error s

let keywords = Lexing.Keywords.add Events.keywords [";"]

let lexer = Lexing.lexer keywords

let of_string s = parse (lexer s)

let to_string = Misc.string_of_list ~f:Events.to_string ~sep:";" 
