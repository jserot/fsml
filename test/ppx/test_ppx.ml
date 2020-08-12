open Fsml
   
let print_t s = 
  s |> Transition.show |> print_endline

let print_f s = 
  s |> Fsm.show |> print_endline

let () =
  print_t [%fsm_trans "S0 --> S1"];
  print_t [%fsm_trans "S0 -> S1 when c=1"];
  print_t [%fsm_trans "S0 -> S1 when c=1 with k:=k+1"];
  print_t [%fsm_trans "S0 -> S1 when c=1,u<2 with k:=k+1,rdy:=0"];
  (* print [%fsm_trans "S0 --> S1"] *)
  print_f [%fsm {|
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
         
