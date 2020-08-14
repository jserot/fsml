(** {1 Simulation events} *)

type t = Expr.ident * Expr.e_val
  [@@deriving show {with_path=false}]
  (** [(id,v)] means that input or local variable [v] take value [v] *)

(** {2 Printer} *)

val to_string: t -> string
