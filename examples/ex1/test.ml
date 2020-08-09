open Fsml
open Fsm

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
