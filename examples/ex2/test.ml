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

(* let st =
 *   [
 *     0, ["start", Expr.Bool false];
 *     1, ["start", Expr.Bool true];
 *     2, ["start", Expr.Bool false];
 *   ] *)
(* This formulation is OK ... *)

(* let st = Stimuli.changes "start"
 *   [
 *            0, Bool false;
 *            1, Bool true;
 *            2, Bool false
 *            ]        *)
(* This one also is also OK ... *)

(* But this one is shorter  :*)
      
let st = [%fsm_stim {|start: 0,'0'; 1,'1'; 2,'0'|}]

let _ =
  f2
  |> Simul.run ~stim:st ~stop_after:8
  |> Simul.filter_trace
  |> List.iter (fun t -> Printf.printf "%s\n" (Simul.show_trace t))
