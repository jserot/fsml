open Fsml
open Fsm

let f2 = {
    id="gensig";
    states=["E0"; "E1"];
    itrans="E0", [];
    inps=["start"];
    outps=["s"];
    vars=["k"];
    trans=[
    [%fsm_trans "E0 -> E1 when start=1 with k:=0, s:=1"];
    [%fsm_trans "E1 -> E1 when k<4 with k:=k+1"];
    [%fsm_trans "E1 -> E0 when k=4 with s:=0"];
    ]
    }

let _ = Dot.view f2

(* Let's simulate it *)

open Expr
open Fsml

let _ =
  Simul.run
    ~ctx:{ state="E0";
           env=["start", Some (Int 0); "k", None; "s", None] }
    ~stim:[%fsm_stim "*; start:=1; start:=0; *; *; *; *; *"]
    f2
  |> Simul.filter_trace
  |> List.iter (fun t -> Printf.printf "%s\n" (Simul.show_trace t))
