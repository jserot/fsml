open Ppxlib
open Fsml

let name = "fsm_stim"
         
let expand ~loc ~path:_ (s:_) =
  let _ =
    try Parse.stimuli s
    with Parse.Error (line,_,tok,msg) ->
      Location.raise_errorf ~loc "%s at line %d near token \"%s\"" msg (loc.loc_start.pos_lnum+line) tok in
  let e = Ast_builder.Default.estring ~loc s in
  [%expr Parse.stimuli [%e e]]

let ext =
  Extension.declare
    name
    Extension.Context.expression
    Ast_pattern.(single_expr_payload (estring __))
    expand

let () = Ppxlib.Driver.register_transformation name ~extensions:[ext]
