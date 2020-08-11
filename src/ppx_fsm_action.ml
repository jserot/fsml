open Ppxlib
open Fsml

let name = "fsm_action"
         
let expand ~loc ~path:_ (s:_) =
  let _ =
    try Parse.action s
    with Parse.Error (line,col,tok,msg) ->
      Location.raise_errorf ~loc "%s at line %d, col %d near token \"%s\"" msg line col tok in
  let e = Ast_builder.Default.estring ~loc s in
  [%expr Parse.action [%e e]]

let ext =
  Extension.declare
    name
    Extension.Context.expression
    Ast_pattern.(single_expr_payload (estring __))
    expand

let () = Ppxlib.Driver.register_transformation name ~extensions:[ext]
