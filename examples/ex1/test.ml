open Fsml

let f1 = [%fsm {|
    name: altbit;
    states: Init, E0, E1;
    inputs: e;
    outputs: s;
    trans:
        Init -> E0 when e=0;
        Init -> E1 when e=1;
        E0 -> E1 when e=1 with s:=0;
        E0 -> E0 when e=0 with s:=1;
        E1 -> E0 when e=0 with s:=0;
        E1 -> E1 when e=1 with s:=1;
    itrans: -> Init;
    |}]

let _ = Dot.view f1
