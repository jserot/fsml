(* This example illustrates the [Fsm.defactorize] function. 
   It converts the example given in ../ex2 in a variable-less FSM.
   This is possible because the local variable [k] is here given an enumerable type. *)

open Fsml

let f = [%fsm {|
    name: gensig;
    states: E0 with s='0', E1 with s='1';
    inputs: start: bool;
    outputs: s: bool;
    vars: k: int<0..4>;
    trans:
      E0 -> E1 when start='1' with k:=0;
      E1 -> E1 when k<4 with k:=k+1;
      E1 -> E0 when k=4;
    itrans: -> E0;
    |}]

let _ = Dot.write "test.dot" f

let f_bis = Fsm.defactorize ~vars:["k",Expr.Int 0] f 

let _ = Dot.write "test_bis.dot" f_bis
