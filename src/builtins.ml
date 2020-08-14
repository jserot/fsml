open Types

let type_arithm () = 
  let sg = Types.new_type_var () in
  let sz = Types.new_size_var () in
  { ts_tparams=[]; ts_sparams=[sz];
    ts_body=TyArrow (TyProduct [TyInt (TyVar sg, SzVar sz); TyInt (TyVar sg, SzVar sz)], TyInt (TyVar sg, SzVar sz)) }
   
let type_compar () = 
  let tv = Types.new_type_var () in
  { ts_tparams=[tv]; ts_sparams=[]; ts_body=TyArrow (TyProduct [TyVar tv; TyVar tv], TyBool) }

exception Unknown_value
        
let encode_int n =
    Expr.Int n
let decode_int = function
  | Expr.Int n -> n
  | Expr.Unknown -> raise Unknown_value
  | _ -> failwith "Builtins.decode_int" (* should not happen *)
let encode_bool b =
    Expr.Bool b
(* let decode_bool = function
 *   | Expr.Bool b -> b
 *   | Expr.Unknown -> raise Unknown_value
 *   | _ -> failwith "Builtins.decode bool" (\* should not happen *\) *)

let prim2 encode op decode =
  function
   | [v1;v2] ->
      begin
        try encode (op (decode v1) (decode v2))
        with Unknown_value -> Expr.Unknown
      end
   | _ -> failwith "Builtins.prim2"

let cprim2 op =
  let decode v = v  in
  function
  | [v1;v2] ->
      begin
        try encode_bool (op (decode v1) (decode v2))
        with Unknown_value -> Expr.Unknown
      end
   | _ -> failwith "Builtins.cprim2"

let prims = [
    "+", (type_arithm (), prim2 encode_int  ( + ) decode_int);
    "-", (type_arithm (), prim2 encode_int  ( - ) decode_int);
    "*", (type_arithm (), prim2 encode_int  ( * ) decode_int);
    "/", (type_arithm (), prim2 encode_int  ( / ) decode_int);
    "=", (type_compar () , cprim2 ( = ));
    "!=", (type_compar (), cprim2 ( <> ));
    "<", (type_compar (), cprim2 ( < ));
    ">", (type_compar (), cprim2 ( > ));
    "<=", (type_compar (), cprim2 ( <= ));
    ">=", (type_compar (), cprim2 ( >= ))
]

let typing_env = List.map (fun (id, (ty, _)) -> id, ty) prims

let eval_env = List.map (fun (id, (_, f)) -> id, Expr.Prim f) prims
