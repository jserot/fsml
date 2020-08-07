open Fsm

type clk = int
  [@@deriving show]

type trace = clk * ctx 
  [@@deriving show]

let run ~ctx ~stim m = 
  let rec eval (clk, ctx, trace) stim =
    match stim with
    | [] -> List.rev trace (* Done ! *)
    | st::rest ->
       let ctx' = { ctx with env = List.fold_left Action.perform ctx.env st } in
       let ctx'' = Fsm.step ctx' m in
       eval (clk+1, ctx'', (clk, ctx'') :: trace) rest in
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

let compute ?(istate="Idle") ?(start="start") ?(rdy="rdy") ?(outps=[]) m inps =
  let init id = id, None in
  let update inps env =
    List.fold_left 
      (fun env (i,v) -> Expr.update_env env i v)
      env
      inps in
  let outps = match outps with [] -> m.outps | _ -> outps in
  let rec eval (clk, ctx) stim =
    match stim, List.assoc rdy ctx.env with
    | [], Some (Int 1) -> (* Done. Return ... *)
       clk,  (* ... final clock count *)
       List.filter (fun (o,_) -> List.mem o outps) ctx.env (* ... and value of outputs *)
    | [], _ -> (* No more stimuli, but still waiting for end of computation *)
       let ctx'' = Fsm.step ctx m in
       eval (clk+1, ctx'') []
    | st::rest, _ -> (* Still some stimuli to apply *)
       let ctx' = { ctx with env = List.fold_left Action.perform ctx.env st } in
       let ctx'' = Fsm.step ctx' m in
       eval (clk+1, ctx'') rest in
  let ctx = {
      state = istate;
      env = List.map init (m.inps @ m.outps @ m.vars) |> update inps
    } in
  let stim = [ [Action.Assign (start, EInt 1)]; [Action.Assign (start, EInt 0)] ] in
  eval (1, ctx) stim
  
