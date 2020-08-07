(** {1 High-level simulation interface} *)

type clk = int
  [@@deriving show]
  (** Clock cycle counter *)

type trace = clk * Fsm.ctx 
  [@@deriving show]
  (** A [trace] gives the value of a FSM context at a given clock cycle *)

(** {2 Simulation functions} *)

val run:
  ctx:Fsm.ctx ->
  stim:Events.t list ->
  Fsm.t ->
  trace list
  (** [run ctx stim m] performs a multi-step simulation of FSM [m] starting from
      context [ctx] and applying a sequence of stimuli described by [stim], producing
      a sequence of traces. *)

val compute:
  ?istate:string (** Initial state (default: "Idle") *)
  -> ?start:string  (** Start input signal (default: "start") *)
  -> ?rdy:string    (** Rdy output signal (default: "rdy") *)
  -> ?outps:string list (** Watched outputs (default: all declared) *)
  -> Fsm.t        
  -> (string * Expr.value) list  (** Input arguments *)
  -> int * (string * Expr.value option) list 
  (**
      [compute m args] is a special version of [run] dedicated to FSMs describing {i co-processing
      units}. The assumption is that such FSMs have
      - a pair of synchronizing signals, typically named [start] and [rdy]
      - a set of input arguments,
      - a set of computation results.

      and the following behavior :
      - the FSM is initially in state [Idle], with output [rdy] set to 1
      - when input [start] is set to 1, all inputs arguments are registered, output [rdy] is set to 0,
        and the FSM starts to compute the result (this my involve an unknown number of states and/or steps
      - when the computation is done, the results are written on the outputs, [rdy] set to 1 and FSM back to the 
        initial state.

      The [compute] function takes care of generating the corresponding stimuli and waiting for the end of the
      computation (watching the [rdy] output). It returns
      - the number of steps required to get the results
      - the value of these results as a association list mapping their names to the corresponding value.

      The name of of initial state, of the [start] and [rdy] signals can be modified using the optional 
      arguments [istate], [start] and [rdy] respectively.
      By default, all outputs will be considered as results. The [outps] optional argument can be used to
      modify this. *)
 
(** {2 Post-processors} *)

val filter_trace: trace list -> trace list
  (** [filter_trace ts] modifies a sequence of trace by removing, from each inserted context,
      the fields which have not been modified wrt. the previous step. *)

(** {2 Helping parsers} *)

val mk_stim: string -> Events.t list
  (** [mk_stim s] builds a sequence stimuli from a string representation.
      Example: [mk_stim "e:=1; e:=0,k:=1"] is
      [[[Assign ("e", EInt 1)]; [Assign ("e", EInt 0); Assign ("k", EInt 1)]]].
      Raises [Lexing.Syntax_error] (with the current lookahead token) if parsing fails. *)
