open Fsm

type clk = int

type trace = clk * ctx 

let run ~state ~env ~stim m = 
  let rec eval (clk, ctx, trace) stim =
    match stim with
    | [] -> List.rev trace (* Done ! *)
    | st::rest ->
       let ctx' = { ctx with env = List.fold_left Action.perform ctx.env st } in
       let ctx'' = Fsm.step ctx' m in
       eval (clk+1, ctx'', (clk, ctx'') :: trace) rest in
  let ctx = { state = state; env = env } in
  eval (1, ctx, [0, ctx]) stim

let mk_stim s = Stimuli.of_string s

let rec env_diff env env' = match env, env' with
| [], [] -> []
| (k,v)::rest, (k',v')::rest' when k=k' -> if v=v' then env_diff rest rest' else (k',v') :: env_diff rest rest'
| _, _ -> failwith "Simul.env_diff"

let ctx_diff ctx ctx' = { state = ctx'.state; env = env_diff ctx.env ctx'.env }

let trace_diff (_,ctx) (clk',ctx') = (clk', ctx_diff ctx ctx')

let filter_trace ts = 
  let rec scan prev ts = match ts with
    | [] -> []
    | t::ts -> let t' = trace_diff prev t in  t' :: scan t ts in
  match ts with 
| [] -> []
| t::ts -> t:: scan t ts 
