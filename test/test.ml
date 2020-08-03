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
        "Init", [Eq, EVar "e", EConst 0], [], "E0";
        "Init", [Eq, EVar "e", EConst 1], [], "E1";
        "E0", [Eq, EVar "e", EConst 1], [Assign ("s", EConst 0)], "E1";
        "E0", [Eq, EVar "e", EConst 0], [Assign ("s", EConst 1)], "E0";
        "E1", [Eq, EVar "e", EConst 0], [Assign ("s", EConst 0)], "E0";
        "E1", [Eq, EVar "e", EConst 1], [Assign ("s", EConst 1)], "E1";
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
    "E0", [Eq, EVar "start", EConst 1],[Assign ("k", EConst 0); Assign ("s", EConst 1)], "E1";
    "E1", [Lt, EVar "k", EVar "n"], [Assign ("k", EBinop (Plus, EVar "k", EConst 1))], "E1";
    "E1", [Eq, EVar "k", EVar "n"], [Assign ("s", EConst 0)], "E0"
    ]
    }

let _ = Dot.view f2

let f3 = {
    id="pgcd";
    states=["Repos"; "Calcul"];
    istate="Repos", [Assign ("rdy", EConst 1)];
    vars=["a"; "b"];
    trans=[
        "Repos",
        [Eq, EVar "start", EConst 1],
        [Assign ("a", EVar "m");
         Assign ("b", EVar "n");
         Assign ("rdy", EConst 0)],
        "Calcul";

        "Calcul",
        [Lt, EVar "a", EVar "b"],
        [Assign ("b", EBinop (Minus, EVar "b", EVar "a"))],
        "Calcul";

        "Calcul",
        [Gt, EVar "a", EVar "b"],
        [Assign ("a", EBinop (Minus, EVar "a", EVar "b"))],
        "Calcul";

        "Calcul",
        [Eq, EVar "a", EVar "b"],
        [Assign ("r", EVar "a");
         Assign ("rdy", EConst 1)],
        "Repos";
    ]
    }

let _ = Dot.view f3

(* With PPX-supported EDSL notation for transitions *)

(* let f4 = {
 *     id="mini";
 *     states=["E0"; "E1"];
 *     istate="E0", [];
 *     vars=["k"];
 *     trans=[
 *     "E0", [%guard "start=1"] [ [%action "k:=0"]; [%action "s:=1"]], "E1"
 *     ]
 *     } *)
