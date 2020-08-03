open Newfsm
open Fsm
(* open Fsm.Action *)
(* open Fsm.Expr *)

let f1 = {
    id="altbit";
    states=["Init"; "E0"; "E1"];
    istate="Init", [];
    vars=[];
    trans=[
        "Init", mk_guard "e=0", mk_action "", "E0";
        "Init", mk_guard "e=1", mk_action "", "E1";
        "E0", mk_guard "e=1", mk_action "s:=0", "E1";
        "E0", mk_guard "e=0", mk_action "s:=1", "E0";
        "E1", mk_guard "e=0", mk_action "s:=0", "E0";
        "E1", mk_guard "e=1", mk_action "s:=1", "E1";
      ]
    }

let _ = Dot.view f1

let f2 = {
    id="gensig";
    states=["E0"; "E1"];
    istate="E0", [];
    vars=["k"];
    trans=[
    "E0", mk_guard "start=1", mk_action "k:=0, s:=1", "E1";
    "E1", mk_guard "k<4", mk_action "k:=k+1", "E1";
    "E1", mk_guard "k=4", mk_action "s:=0", "E0";
    ]
    }

let _ = Dot.view f2
