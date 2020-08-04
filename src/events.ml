type t = Action.t list

let p_events s = match Stream.peek s with
  | Some (Genlex.Kwd "*") -> Stream.junk s; []  (* Empty event set; means "only clock" *)
  | Some _  -> Misc.list_parse ~parse_item:Action.parse ~sep:"," s
  | _ -> raise Stream.Failure

let parse = p_events

let keywords = Lexing.Keywords.add Action.keywords ["*"]

let lexer = Lexing.lexer keywords

let of_string s = parse (lexer s)

let to_string = Misc.string_of_list ~f:Action.to_string ~sep:","
