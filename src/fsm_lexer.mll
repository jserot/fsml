{
open Fsm_parser

exception Illegal_character of int * string

(* The table of keywords *)

let keyword_table = [
  "name", NAME;
  "states", STATES;
  "vars", VARS;
  "trans", TRANS;
  "itrans", ITRANS;
  "inputs", INPUTS;
  "outputs", OUTPUTS;
  (* "int", TYINT;
   * "bool", TYBOOL; *)
  "when", WHEN;
  "with", WITH;
  (* "true", TRUE;
   * "false", FALSE; *)
]
}

rule main = parse
  | [' ' '\t'] +
      { main lexbuf }
  | ['\010' '\013' ]
      { Lexing.new_line lexbuf; main lexbuf }
  | ['a'-'z' ] ( ['A'-'Z' 'a'-'z' '0'-'9' '_' ] ) *
      { let s = Lexing.lexeme lexbuf  in
        try List.assoc s keyword_table
        with Not_found -> LID s }
  | ['A'-'Z' 'a'-'z' ] ( ['A'-'Z' 'a'-'z' '0'-'9' '_' ] ) *
      { UID (Lexing.lexeme lexbuf) }
  | ['0'-'9']+
      { INT (int_of_string(Lexing.lexeme lexbuf)) }
  | ";" { SEMICOLON }
  | "(" { LPAREN }
  | ")" { RPAREN }
  | "," { COMMA }
  | "->" { ARROW }
  | ":" { COLON }
  | "=" { EQUAL }
  | ":=" { COLEQ }
  | "!="    { NOTEQUAL }
  | '>'    { GT }
  | '<'    { LT }
  | ">="    { GTE }
  | "<="    { LTE }
  | '+' { PLUS }
  | '-' { MINUS }
  | '*' { TIMES }
  | '/' { DIV }
  (* | '&' { LAND }
   * | "||" { LOR }
   * | '^' { LXOR }
   * | ">>" { SHR }
   * | "<<" { SHL } *)
  | eof { EOF }
  | _ { raise (Illegal_character (Lexing.lexeme_start lexbuf, Lexing.lexeme lexbuf)) }
