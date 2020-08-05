open Newfsm
open Fsm

let f3 = {
    id="pgcd";
    states=["Idle"; "Comp"];
    istate="Idle", [Assign ("rdy", EInt 1)];
    inps=["start"; "m"; "n"];
    outps=["rdy"; "r"];
    vars=["a"; "b"];
    trans=[
        mk_trans "Idle -> Comp when start=1 with a:=m, b:=n, rdy:=0";
        mk_trans "Comp -> Comp when a<b with b:=b-a";
        mk_trans "Comp -> Comp when a>b with a:=a-b";
        mk_trans "Comp -> Idle when a=b with rdy:=1, r:=a";
      ]
    }

let _ = Dot.view f3

let _ =
  f3
  |> Simul.run
    ~state:"Idle"
    ~env:["start", Some (Int 0); "m", None; "n", None; "a", None; "b", None]
    ~stim:(Simul.mk_stim "*; m:=12, n:=5; start:=1; start:=0; *; *; *; *; *")
  |> Simul.filter_trace
  |> List.iter (fun t -> Printf.printf "%s\n" (Simul.show_trace t))

let () = 
  let nclk, result = Simul.compute f3 ~outps:["r"] ["m", Int 36; "n", Int 24] in
  Printf.printf "** Got %s after %d clk cycles\n" (Expr.show_env result) nclk
