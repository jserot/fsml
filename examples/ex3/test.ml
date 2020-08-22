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

let st =
  Stimuli.merge [
    [%fsm_stim "start: 0,'0'; 1,'1'; 2,'0'"];
    [%fsm_stim "m: 0,36"];
    [%fsm_stim "n: 0,24"];
    ]

let _ =
  f3
  |> Simul.run ~stim:st ~stop_when:[%fsm_guards {|rdy='1',clk>2|}]
  (* The extra condition "clk>2" prevents the initial setting of [rdy] to prematurely stop the simulation *)
  |> Simul.filter_trace
  |> List.iter (fun t -> Printf.printf "%s\n" (Simul.show_trace t))

(* Code generation *)

let () = C.write ~fname:"./c/fsm_pgcd" f3
let () = Vhdl.write ~fname:"./vhdl/fsm_pgcd" f3
