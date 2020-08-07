open Fsml
open Fsm

let f2_raw =
    let open Action in
    let open Expr in {
    id="gensig";
    states=["E0"; "E1"];
    itrans="E0", [];
    inps=["start"];
    outps=["s"];
    vars=["k"];
    trans=[
    "E0", [ERelop ("=", EVar "start", EInt 1)],[Assign ("k", EInt 0); Assign ("s", EInt 1)], "E1";
    "E1", [ERelop ("<", EVar "k", EVar "n")], [Assign ("k", EBinop ("+", EVar "k", EInt 1))], "E1";
    "E1", [ERelop ("=", EVar "k", EVar "n")], [Assign ("s", EInt 0)], "E0"
    ]
    }

(* Again, nicer this way : *)

let f2 = {
    id="gensig";
    states=["E0"; "E1"];
    itrans="E0", [];
    inps=["start"];
    outps=["s"];
    vars=["k"];
    trans=[
    mk_trans "E0 -> E1 when start=1 with k:=0, s:=1";
    mk_trans "E1 -> E1 when k<4 with k:=k+1";
    mk_trans "E1 -> E0 when k=4 with s:=0";
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
    ~stim:(Simul.mk_stim "*; start:=1; start:=0; *; *; *; *; *")
    f2
  |> Simul.filter_trace
  |> List.iter (fun t -> Printf.printf "%s\n" (Simul.show_trace t))
