type clk = int

type trace = clk * Fsm.state * Expr.env 

val run:
  state:Fsm.state ->
  env:Expr.env ->
  stim:Events.t list ->
  Fsm.t ->
  trace list

(* Post-processors *)

val filter_trace: trace list -> trace list

(* Helping parsers *)

val mk_stim: string -> Events.t list
