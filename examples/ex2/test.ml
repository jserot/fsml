open Fsml

let f2 = [%fsm {|
    name: gensig;
    states: E0, E1;
    inputs: start: bool;
    outputs: s: bool;
    vars: k: int<8>;
    trans:
      E0 -> E1 when start='1' with k:=0, s:='1';
      E1 -> E1 when k<4 with k:=k+1;
      E1 -> E0 when k=4 with s:='0';
    itrans: -> E0 with s:='0';
    |}]

let _ = Dot.write "test.dot" f2

(* Simulation *)

let stim = [%fsm_stim {|start: 0,'0'; 1,'1'; 2,'0'|}]

open Tevents.Ops

let res, _ = Simul.run ~stop_after:8 ~stim:stim f2
let _ = List.iter (fun t -> Printf.printf "%s\n" (Tevents.show t)) (stim @@@ res)
let _ = Vcd.write ~fname:"test.vcd" ~fsm:f2 (stim @@@ res)

(* Code generation *)

let () = C.write ~dir:"./c" ~prefix:"genimp" f2
let () = Vhdl.write ~dir:"./vhdl" ~prefix:"genimp" f2

