open Fsm

type clk = int

type trace = clk * state * Expr.env 

let run ~state ~env ~stim m = 
  let rec eval (clk, state, env, trace) stim =
    match stim with
    | [] -> List.rev trace (* Done ! *)
    | st::rest ->
       let env' = List.fold_left Action.perform env st in
       let state', env'' = 
         begin
           match List.find_opt (Transition.is_fireable state env') m.trans with
           | Some (_, _, acts, dst) -> 
              dst,
              List.fold_left Action.perform env' acts
           | None ->
              state,
              env'
         end in
       eval (clk+1, state', env'', (clk, state', env'') :: trace) rest in
  eval (1, state, env, [0, state, env]) stim

let mk_stim s = Stimuli.of_string s
