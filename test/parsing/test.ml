(* #use "include_ml" *)

open Fsml

let print p x = Printf.printf "%s\n" @@ match x with Result.Ok x -> p x | Result.Error _ -> ""

let () = 
  Parse.action "rdy:=1" |> print Action.show;
  Parse.transition "S0 -> S1 when start=1, k=0 with rdy:=1, k:=k+1" |> print Transition.show;
  Parse.fsm "
    name: altbit;
    states: Init, E0, E1;
    inputs: e;
    outputs: s;
    trans:
        Init -> E0 when e=0;
        Init -> E1 when e=1;
        E0 -> E1 when e=1 with s:=0;
        E0 -> E0 when e=0 with s:=1;
        E1 -> E0 when e=0 with s:=0;
        E1 -> E1 when e=1 with s:=1;
    itrans: -> Init;
    " |> print Fsm.show;
  Parse.stimuli "*; a:=1,b:=1; c:=2; *" |> print Stimuli.to_string

