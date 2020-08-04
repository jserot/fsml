type state = string
  [@@deriving show {with_path=false}, yojson]
           
type t = state * Guard.t list * Action.t list * state
  [@@deriving show {with_path=false}, yojson]

let to_string (src,guards,actions,dst) =
  let s0 = src ^ " -> " ^ dst in
  let s1 = Misc.string_of_list ~f:Guard.to_string ~sep:"." guards in
  let s2 = Misc.string_of_list ~f:Action.to_string ~sep:"," actions in
  let s3 = match s1, s2 with
    | "", "" -> ""
    | s1, "" -> s1
    | s1, s2 -> s1 ^ "/" ^ s2 in
  match s3 with
    "" -> s0
  | _ -> s0 ^ " [" ^ s3 ^ "]"

(* BNF :
   <trans>  ::= ID '->' ID ['when' <guards>] ['with' <actions>] 
   <guards> ::= <guard>^{+}_{,}
   <actions > ::= <action>^{+}_{,}
   <guard> :: <expr>
   <action> :: ID ':=' <expr>
 *)

open Genlex

exception Syntax_error of Genlex.token option

let syntax_error s = raise (Syntax_error (Stream.peek s))


let rec p_trans0 s = 
  match Stream.npeek 4 s with
  | [ Ident src; Kwd "-"; Kwd ">"; Ident dst ] -> 
     Stream.junk s; Stream.junk s; Stream.junk s; Stream.junk s;
     begin match Stream.peek s with
       | None -> (src, [], [], dst)
       | Some (Kwd "when") -> Stream.junk s; let guards, actions = p_trans1 s in (src,guards,actions,dst)
       | Some (Kwd "with") -> Stream.junk s; let actions = p_trans2 s in (src,[],actions,dst)
       | _ -> raise Stream.Failure
     end
  | _ -> raise Stream.Failure

and p_trans1 s = 
  let guards = Misc.list_parse ~parse_item:Guard.parse ~sep:"," s in
  match Stream.peek s with
  | Some (Kwd "with") -> Stream.junk s; let actions = p_trans2 s in (guards,actions)
  | _ -> flush stdout; guards, []

and p_trans2 s =
  Misc.list_parse ~parse_item:Action.parse ~sep:"," s

let parse s =
  try p_trans0 s
  with Stream.Failure -> syntax_error s

let keywords = Lexing.Keywords.add (Lexing.Keywords.union Guard.keywords Action.keywords) ["when"; "with"; ","]
  (* Note: the "->" keyword is lexed as ["-"; ">"] here *)

let lexer = Lexing.lexer keywords

let of_string s = s |> lexer |> parse

(* Simulation *)

let is_fireable src env (src',guards,_,_) =
       src = src'
    && List.for_all (Guard.eval env) guards
