open Newfsm
open Fsm

(** Example 1 *)

let f1_raw =
    let open Action in
    let open Expr in {
    id="altbit";
    states=["Init"; "E0"; "E1"];
    istate="Init", [];
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
    vars=["k"];
    trans=[
    mk_trans "E0 -> E1 when start=1 with k:=0, s:=1";
    mk_trans "E1 -> E1 when k<4 with k:=k+1";
    mk_trans "E1 -> E0 when k=4 with s:=0";
    ]
    }

let _ = Dot.view f2

open Expr

let _ =
  Simul.run
    ~state:"E0"
    ~env:["start", Some (Int 0); "k", None; "s", None]
    ~stim:(Simul.mk_stim "*; start:=1; start:=0; *; *; *; *; *")
    f2
