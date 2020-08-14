(** Builtin environments *)

val typing_env: (string * Types.typ_scheme) list

val eval_env: (string * Expr.e_val) list
