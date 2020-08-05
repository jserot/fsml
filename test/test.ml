open Newfsm
open Fsm

(** Example 1 *)

let f1_raw =
    let open Action in
    let open Expr in {
    id="altbit";
    states=["Init"; "E0"; "E1"];
    istate="Init", [];
    inps=["e"];
    outps=["s"];
    vars=[];
    trans=[
        "Init", [ERelop ("=", EVar "e", EInt 0)], [], "E0";
        "Init", [ERelop ("=", EVar "e", EInt 1)], [], "E1";
        "E0", [ERelop ("=", EVar "e", EInt 1)], [Assign ("s", EInt 0)], "E1";
        "E0", [ERelop ("=", EVar "e", EInt 0)], [Assign ("s", EInt 1)], "E0";
        "E1", [ERelop ("=", EVar "e", EInt 0)], [Assign ("s", EInt 0)], "E0";
        "E1", [ERelop ("=", EVar "e", EInt 1)], [Assign ("s", EInt 1)], "E1";
      ]
    }

let _ = Dot.view f1_raw

(* The same FSM with a parsing helper *)

let f1 = {
    id="altbit";
    states=["Init"; "E0"; "E1"];
    istate="Init", [];
    inps=["e"];
    outps=["s"];
    vars=[];
    trans=[
        mk_trans "Init -> E0 when e=0";
        mk_trans "Init -> E1 when e=1";
        mk_trans "E0 -> E1 when e=1 with s:=0";
        mk_trans "E0 -> E0 when e=0 with s:=1";
        mk_trans "E1 -> E0 when e=0 with s:=0";
        mk_trans "E1 -> E1 when e=1 with s:=1";
      ]
    }

let _ = Dot.view f1

(** Example 2 *)

let f2_raw =
    let open Action in
    let open Expr in {
    id="gensig";
    states=["E0"; "E1"];
    istate="E0", [];
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
    istate="E0", [];
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

open Expr
open Newfsm

let _ =
  Simul.run
    ~state:"E0"
    ~env:["start", Some (Int 0); "k", None; "s", None]
    ~stim:(Simul.mk_stim "*; start:=1; start:=0; *; *; *; *; *")
    f2 |> Simul.filter_trace

let f3 = {
    id="pgcd";
    states=["Repos"; "Calcul"];
    istate="Repos", [Assign ("rdy", EInt 1)];
    inps=["start"; "m"; "n"];
    outps=["rdy"; "r"];
    vars=["a"; "b"];
    trans=[
        mk_trans "Repos -> Calcul when start=1 with a:=m, b:=n, rdy:=0";
        mk_trans "Calcul -> Calcul when a<b with b:=b-a";
        mk_trans "Calcul -> Calcul when a>b with a:=a-b";
        mk_trans "Calcul -> Repos when a=b with rdy:=1, r:=a";
      ]
    }

let _ = Dot.view f3

let _ =
  f3
  |> Simul.run
    ~state:"Repos"
    ~env:["start", Some (Int 0); "m", None; "n", None; "a", None; "b", None]
    ~stim:(Simul.mk_stim "*; m:=12; n:=5; start:=1; start:=0; *; *; *; *; *")
  |> Simul.filter_trace
  |> List.iter (fun t -> Printf.printf "%s\n" (Simul.show_trace t))
