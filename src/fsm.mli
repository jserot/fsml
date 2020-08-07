(** {1 Finite State Machines} *)

type t = {
  id: string;  (** Name *)
  states: State.t list;
  itrans: State.t * Action.t list;  (** Initial transition *)
  inps: string list;  (** Inputs *)
  outps: string list; (** Outputs *)
  vars: string list;  (** Local variables *)
  trans: Transition.t list
} [@@deriving show {with_path=false}, yojson]
  (** The static description of a FSM *)

(* {2 Helping parsers} *)

val mk_trans: string -> Transition.t
  (** [mk_trans s] builds a FSM transition from a string representation.
      Example: [mk_trans "S1 -> S1 when c=0 with k:=1"] is
      [("S1", [ERelop ("=", EVar "c", EInt 0)],[Assign ("k", EInt 1)], "E1")].
      Raises [Lexing.Syntax_error] (with the current lookahead token) if parsing fails. *)

(* { 2 Serializing/deserializing functions} *)
       
val to_string: t -> string
  (** [to_string m] writes a representation of FSM [m] as a string using the [Yojson] library. *)

val from_string: string -> t
  (** [from_string s] returns the FSM [m] stored in string [s] using the [Yojson] library *)

val to_file: fname:string -> t -> unit
  (** [to_file f] writes a representation of FSM [m] in file [f] using the [Yojson] library. *)
  
val from_file: fname:string -> t
  (** [from_file f] returns the FSM [m] stored in file [f] using the [Yojson] library *)

(* {2 Simulation} *)

type ctx = {
  state: State.t;
  env: Expr.env
  }
[@@deriving show]
  (** A context is the dynamic view of a FSM. It records its current state
     and, in [env], the value of its inputs, outputs and local variables. *)

val step: ctx -> t -> ctx
  (** [step ctx m] performs one simulation step, within context [ctx] of FSM [m]. 
      The first fireable transition is selected according to the current state and
      value of the inputs and local variables. The actions associated to this transition
      are executed and both the state and context are updated accordingly.
      If no fireable transition is found, the context is left unchanged. *)

