open Fsml

let f2 = [%fsm {|
    name: gensig;
    states: E0, E1;
    inputs: start: bool;
    outputs: s: bool;
    vars: k: int;
    trans:
      E0 -> E1 when start='1' with k:=0, s:='1';
      E1 -> E1 when k<4 with k:=k+1;
      E1 -> E0 when k=4 with s:='0';
    itrans: -> E0;
    |}]

let _ = Dot.view f2

(* Let's simulate it *)

let _ =
  f2
  |> Simul.run ~stim:[%fsm_stim {| start:='0'; start:='1'; start:='0'; *; *; *; *; * |}]
  |> Simul.filter_trace
  |> List.iter (fun t -> Printf.printf "%s\n" (Simul.show_trace t))
