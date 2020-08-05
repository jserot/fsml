type clk = int
  [@@deriving show]

type trace = clk * Fsm.ctx 
  [@@deriving show]

val run:
  state:Fsm.state ->
  env:Expr.env ->
  stim:Events.t list ->
  Fsm.t ->
  trace list

val compute:
  ?istate:string -> (** Initial state (default: "Idle") *)
  ?start:string ->  (** Start input signal (default: "start") *)
  ?rdy:string ->    (** Rdy output signal (default: "rdy") *)
  ?outps:string list -> (** Watched outputs (default: all declared) *)
  Fsm.t ->        
  (string * Expr.value) list ->  (** Input data *)
  int * (string * Expr.value option) list    (** Final clock count and output values *)

(* Post-processors *)

val filter_trace: trace list -> trace list

(* Helping parsers *)

val mk_stim: string -> Events.t list
