open Fsml

let f3 = [%fsm {|
    name: pgcd;
    states: Idle with rdy='1', Comp with rdy='0';
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
        Idle -> Comp when start='1' with a:=m, b:=n;
        Comp -> Comp when a<b with b:=b-a;
        Comp -> Comp when a>b with a:=a-b;
        Comp -> Idle when a=b with r:=a;
    itrans: -> Idle;
    |}] 

let _ = Dot.write "test.dot" f3

(* Let's simulate it *)

let st =
  Tevents.merge [
    [%fsm_stim "start: 0,'0'; 1,'1'; 2,'0'"];
    [%fsm_stim "m: 0,36"];
    [%fsm_stim "n: 0,24"];
    ]

open Tevents.Ops

let res, _ = Simul.run ~stop_when:[%fsm_guards {|rdy='1',clk>5|}] ~stim:st f3
let _ = List.iter (fun t -> Printf.printf "%s\n" (Tevents.show t)) (st @@@ res)
let _ = Vcd.write ~fname:"test.vcd" ~fsm:f3 (st @@@ res)

(* Code generation *)

let () = C.write ~dir:"./c" ~prefix:"fsm_pgcd" f3
let () = Vhdl.write ~dir:"./vhdl" ~prefix:"fsm_pgcd" f3
