open Fsml
open Fsm

let f3 = {
    id="pgcd";
    states=["Idle"; "Comp"];
    itrans="Idle", [[%fsm_action "rdy:=1"]];
    inps=["start"; "m"; "n"];
    outps=["rdy"; "r"];
    vars=["a"; "b"];
    trans=[
        [%fsm_trans "Idle -> Comp when start=1 with a:=m, b:=n, rdy:=0"];
        [%fsm_trans "Comp -> Comp when a<b with b:=b-a"];
        [%fsm_trans "Comp -> Comp when a>b with a:=a-b"];
        [%fsm_trans "Comp -> Idle when a=b with rdy:=1, r:=a"];
      ]
    }

let _ = Dot.view f3

(* Let's simulate it *)

let _ =
  f3
  |> Simul.run
    ~ctx:{ state="Idle";
           env=["start", Some (Int 0); "m", None; "n", None; "a", None; "b", None] }
    ~stim:(Simul.mk_stim "*; m:=12, n:=5; start:=1; start:=0; *; *; *; *; *")
  |> Simul.filter_trace
  |> List.iter (fun t -> Printf.printf "%s\n" (Simul.show_trace t))

(* ... using a higher-level interface *)

let () = 
  let nclk, result =
    f3 
    |> Simul.compute
         ~args:["m", Int 36; "n", Int 24]
         ~results:["r"]
   in
   Printf.printf "** Got %s after %d clk cycles\n" (Expr.show_env result) nclk

(* Code generation *)

let () = C.write ~fname:"./c/fsm_pgcd" f3
let () = Vhdl.write ~fname:"./vhdl/fsm_pgcd" f3
