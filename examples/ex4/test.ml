(* This example shows how to define parameterized FSM builders.
   Here, [genimp n] has the same behavior of the [gensig] FSM defined in [../ex2] but uses
   [n] states instead of a local variable.
   Note the use of the [fsm_trans] and [fsm_action] PPXs. *) 

open Fsml
open Fsm

let list_make f lo hi =
  (* [list_make f lo hi] is [[f lo; f (lo+1); ...; f hi]] *)
  let rec mk i = if i <= hi then f i :: mk (i+1) else [] in
  mk lo
  
let genimp n =
  let mk_state i = "E" ^ string_of_int i in
  let mk_attr_state i = mk_state i, [] in
  let mk_trans i = (mk_state i, [], [], mk_state (i+1)) in
  {
    id="gensig";
    states=("E0",[]) :: list_make mk_attr_state 1 n;
    itrans="E0", [[%fsm_action "s:='0'"]];
    inps=["start", Types.TyBool];
    outps=["s", Types.TyBool];
    vars=[];  (* No local var here *)
    trans=
      [ [%fsm_trans "E0 -> E1 when start='1' with s:='1'"];
        (mk_state n, [], [[%fsm_action "s:='0'"]], "E0") ]
     @ list_make mk_trans 1 (n-1);
    }

let f = genimp 4

let _ = Dot.view f
