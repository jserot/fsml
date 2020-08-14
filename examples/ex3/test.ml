open Fsml

let f3 = [%fsm {|
    name: pgcd;
    states: Idle, Comp;
    inputs:
      start: bool,
      m: uint<8>,
      n: uint<8>;
    outputs:
      rdy: bool,
      r: uint<8>;
    vars:
      a: uint<8>,
      b: uint<8>;
    trans:
        Idle -> Comp when start='1' with a:=m, b:=n, rdy:='0';
        Comp -> Comp when a<b with b:=b-a;
        Comp -> Comp when a>b with a:=a-b;
        Comp -> Idle when a=b with rdy:='1', r:=a;
    itrans: -> Idle with rdy:='1';
    |}] 

let _ = Dot.view f3

(* Let's simulate it *)

let _ =
  f3
  |> Simul.run ~stim:[%fsm_stim {| start:='0',m:=12,n:=5; start:='1'; start:='0'; *; *; *; *; * |}]
  |> Simul.filter_trace
  |> List.iter (fun t -> Printf.printf "%s\n" (Simul.show_trace t))

(* ... using a higher-level interface *)

let () = 
  let nclk, result =
    f3 
    |> Simul.compute ~args:["m", Int 36; "n", Int 24] ~results:["r"]
   in
   Printf.printf "** Got %s after %d clk cycles\n" (Expr.show_env result) nclk

(* Code generation *)

let () = C.write ~fname:"./c/fsm_pgcd" f3
let () = Vhdl.write ~fname:"./vhdl/fsm_pgcd" f3
