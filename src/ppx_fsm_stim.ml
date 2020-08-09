open Ppxlib
open Fsml

let name = "fsm_stim"
         
let expand ~loc ~path:_ (s:_) =
  let _ =
    try Stimuli.of_string s
    with Lexing.Syntax_error s -> Location.raise_errorf ~loc "parse error near: \"%s\"" s in
  let e = Ast_builder.Default.estring ~loc s in
  [%expr Stimuli.of_string [%e e]]

let ext =
  Extension.declare
    name
    Extension.Context.expression
    Ast_pattern.(single_expr_payload (estring __))
    expand

let () = Ppxlib.Driver.register_transformation name ~extensions:[ext]
