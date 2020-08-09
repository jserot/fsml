open Fsml
   
let print s = 
  s |> Transition.show |> print_endline

let () =
  print [%fsm_trans "S0 -> S1"];
  print [%fsm_trans "S0 -> S1 when c=1"];
  print [%fsm_trans "S0 -> S1 when c=1 with k:=k+1"];
  print [%fsm_trans "S0 -> S1 when c=1,u<2 with k:=k+1,rdy:=0"];
  print [%fsm_trans "S0 --> S1"] 
         
