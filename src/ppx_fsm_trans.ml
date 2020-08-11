open Ppxlib
open Fsml

let name = "fsm_trans"
         
let expand ~loc ~path:_ (s:_) =
  let _ =
    try Parse.transition s
    with Parse.Error (line,col,tok,msg) ->
      Location.raise_errorf ~loc "%s at line %d, col %d near token \"%s\"" msg line col tok in
  let e = Ast_builder.Default.estring ~loc s in
  [%expr Parse.transition [%e e]]

let ext =
  Extension.declare
    name
    Extension.Context.expression
    Ast_pattern.(single_expr_payload (estring __))
    expand

let () = Ppxlib.Driver.register_transformation name ~extensions:[ext]
