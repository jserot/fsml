(* This example shows how to define parameterized FSM builders.
   Here, [genimp n] has the same behavior of the [gensig] FSM defined in [../ex2] but uses
   [n] states instead of a local variable. *) 

open Fsml
open Fsm

let list_make f lo hi =
  let rec mk i = if i <= hi then f i :: mk (i+1) else [] in
  mk lo
  
let genimp n =
  let open Expr in
  let open Action in
  let mk_state i = "E" ^ string_of_int i in
  let mk_trans i = (mk_state i, [], [], mk_state (i+1)) in
  {
    id="gensig";
    states="E0" :: list_make mk_state 1 n;
    itrans="E0", [];
    inps=["start"];
    outps=["s"];
    vars=[];  (* No local var here *)
    trans=
       [ ("E0", [ERelop ("=", EVar "start", EInt 1)], [Assign ("s", EInt 1)], "E1");
         (mk_state n, [], [Assign ("s", EInt 0)], "E0") ]
     @ list_make mk_trans 1 (n-1);
    }

let f = genimp 4

let _ = Dot.view f
