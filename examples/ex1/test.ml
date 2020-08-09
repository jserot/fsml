open Fsml
open Fsm

let f1_raw =
    let open Action in
    let open Expr in {
    id="altbit";
    states=["Init"; "E0"; "E1"];
    itrans="Init", [];
    inps=["e"];
    outps=["s"];
    vars=[];
    trans=[
        "Init", [ERelop ("=", EVar "e", EInt 0)], [], "E0";
        "Init", [ERelop ("=", EVar "e", EInt 1)], [], "E1";
        "E0", [ERelop ("=", EVar "e", EInt 1)], [Assign ("s", EInt 0)], "E1";
        "E0", [ERelop ("=", EVar "e", EInt 0)], [Assign ("s", EInt 1)], "E0";
        "E1", [ERelop ("=", EVar "e", EInt 0)], [Assign ("s", EInt 0)], "E0";
        "E1", [ERelop ("=", EVar "e", EInt 1)], [Assign ("s", EInt 1)], "E1";
      ]
    }

let _ = Dot.view f1_raw

(* The same FSM with PPX-denoted transitions *)

let f1 = {
    id="altbit";
    states=["Init"; "E0"; "E1"];
    itrans="Init", [];
    inps=["e"];
    outps=["s"];
    vars=[];
    trans=[
        [%fsm_trans "Init -> E0 when e=0"];
        [%fsm_trans "Init -> E1 when e=1"];
        [%fsm_trans "E0 -> E1 when e=1 with s:=0"];
        [%fsm_trans "E0 -> E0 when e=0 with s:=1"];
        [%fsm_trans "E1 -> E0 when e=0 with s:=0"];
        [%fsm_trans "E1 -> E1 when e=1 with s:=1"];
      ]
    }

let _ = Dot.view f1
