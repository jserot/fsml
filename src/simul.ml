open Fsm

type clk = int
  [@@deriving show]

type trace = clk * ctx 
  [@@deriving show]

let check_fsm m = Typing.type_check_fsm m
let check_stimuli m st = Typing.type_check_stimuli m st

let run ?ctx ~stim m = 
  let m = check_fsm m in
  let stim = check_stimuli m stim in
  let rec eval (clk, ctx, trace) stim =
    match stim with
    | [] -> List.rev trace (* Done ! *)
    | evs::rest ->
       let acts = List.map (fun (id,v) -> Action.Assign (id, Expr.of_value v)) evs in
       (* Printf.printf "clk=%d acts=%s\n" clk (Misc.string_of_list ~f:Action.show ~sep:"," acts); *)
       let ctx' = { ctx with env = List.fold_left (Action.perform Builtins.eval_env) ctx.env acts } in
       (* Printf.printf "clk=%d ctx'=%s\n" clk (Fsm.show_ctx ctx'); *)
       let ctx'' = Fsm.step ctx' m in
       (* Printf.printf "clk=%d ctx''=%s\n" clk (Fsm.show_ctx ctx''); *)
       eval (clk+1, ctx'', (clk, ctx'') :: trace) rest in
  let ctx = match ctx, m.Fsm.itrans with
    | Some c, _ -> c
    | None, (s0,acts0) ->
       let env0 = List.map (fun (id,_) -> id, Expr.Unknown) (m.inps @ m.outps @ m.vars) in
       { state = s0; env = List.fold_left (Action.perform Builtins.eval_env) env0 acts0 } in
  eval (1, ctx, [0, ctx]) stim

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

let compute ?(istate="Idle") ?(start="start") ?(rdy="rdy") ~args ?(results=[]) m =
  let m = check_fsm m in
  let init args (id,_) =
    id, try List.assoc id args with Not_found -> Expr.Unknown in
  let outps = match results with [] -> List.map fst m.outps | _ -> results in
  let rec eval (clk, ctx) stim =
    match stim, List.assoc rdy ctx.env with
    | [], Bool true -> (* Done. Return ... *)
       clk,  (* ... final clock count *)
       List.filter (fun (o,_) -> List.mem o outps) ctx.env (* ... and value of outputs *)
    | [], _ -> (* No more stimuli, but still waiting for end of computation *)
       let ctx'' = Fsm.step ctx m in
       eval (clk+1, ctx'') []
    | evs::rest, _ -> (* Still some stimuli to apply *)
       let acts = List.map (fun (id,v) -> Action.Assign (id, Expr.of_value v)) evs in
       let ctx' = { ctx with env = List.fold_left (Action.perform Builtins.eval_env) ctx.env acts } in
       let ctx'' = Fsm.step ctx' m in
       eval (clk+1, ctx'') rest in
  let ctx = {
      state = istate;
      env = List.map (init args) (m.inps @ m.outps @ m.vars);
    } in
  let stim =
    [ [start, Expr.Bool true]; [start, Expr.Bool false] ] in
  eval (1, ctx) stim
  
