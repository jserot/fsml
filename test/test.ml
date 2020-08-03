open Newfsm
open Fsm
open Fsm.Action
open Fsm.Expr

let f1 = {
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

let _ = Dot.view f1

(* Check serializing / deserializing fns *)
      
let f1' = f1 |> Fsm.to_string |> Fsm.from_string |> Dot.view ~fname:"/tmp/fsm_f1_bis.dot"
let _ = f1 |> Fsm.to_file "/tmp/fsm_f1.json" 
let f1'' = Fsm.from_file "/tmp/fsm_f1.json"
let _ = Dot.view ~fname:"/tmp/fsm_f1_ter.dot" f1''

let f2 = {
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

let _ = Dot.view f2

let f3 = {
    id="pgcd";
    states=["Repos"; "Calcul"];
    istate="Repos", [Assign ("rdy", EInt 1)];
    vars=["a"; "b"];
    trans=[
        "Repos",
        [ERelop ("=", EVar "start", EInt 1)],
        [Assign ("a", EVar "m");
         Assign ("b", EVar "n");
         Assign ("rdy", EInt 0)],
        "Calcul";

        "Calcul",
        [ERelop ("<", EVar "a", EVar "b")],
        [Assign ("b", EBinop ("-", EVar "b", EVar "a"))],
        "Calcul";

        "Calcul",
        [ERelop (">", EVar "a", EVar "b")],
        [Assign ("a", EBinop ("-", EVar "a", EVar "b"))],
        "Calcul";

        "Calcul",
        [ERelop ("=", EVar "a", EVar "b")],
        [Assign ("r", EVar "a");
         Assign ("rdy", EInt 1)],
        "Repos";
    ]
    }

let _ = Dot.view f3

