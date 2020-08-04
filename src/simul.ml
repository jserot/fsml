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

let rec env_diff env env' = match env, env' with
| [], [] -> []
| (k,v)::rest, (k',v')::rest' when k=k' -> if v=v' then env_diff rest rest' else (k',v') :: env_diff rest rest'
| _, _ -> failwith "Simul.env_diff"

let trace_diff (_,_,env) (clk',state',env') = (clk', state', env_diff env env')

let filter_trace ts = 
  let rec scan prev ts = match ts with
    | [] -> []
    | t::ts -> let t' = trace_diff prev t in  t' :: scan t ts in
  match ts with 
| [] -> []
| t::ts -> t:: scan t ts 
