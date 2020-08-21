(**********************************************************************)
(*                                                                    *)
(*              This file is part of the FSML library                 *)
(*                     github.com/jserot/fsml                         *)
(*                                                                    *)
(*  Copyright (c) 2020-present, Jocelyn SEROT.  All rights reserved.  *)
(*                                                                    *)
(*  This source code is licensed under the license found in the       *)
(*  LICENSE file in the root directory of this source tree.           *)
(*                                                                    *)
(**********************************************************************)

open Fsm

type trace = Stimuli.clk * ctx 
  [@@deriving show]

let check_fsm m = Typing.type_check_fsm m
let check_stimuli m st = Typing.type_check_stimuli m st

let run ?ctx ?(stop_when=[]) ?(stop_after=0) ~stim m =
  let m = check_fsm m in
  let stim = check_stimuli m stim in
  let stop_conds =
    let open Expr in
    if stop_after > 0 then
      [mk_bool_expr (EBinop(">=", (mk_int_expr (EVar "clk")), (mk_int_expr (EInt stop_after))))]
    else
      List.map (Typing.type_check_fsm_guard ~with_clk:true m) stop_when in
  let eval_stop_conds clk ctx =
    let env' = Builtins.eval_env @ ctx.env @ ["clk", Expr.Int clk] in
    List.for_all (Guard.eval env') stop_conds in
  let rec eval (clk, ctx, trace) stim =
    if eval_stop_conds clk ctx then List.rev trace (* Done ! *)
    else
      match stim with
      | [] -> (* No more stimuli *)
         let ctx'' = Fsm.step ctx m in
         (* Printf.printf "clk=%d ctx''=%s\n" clk (Fsm.show_ctx ctx''); *)
         eval (clk+1, ctx'', (clk, ctx'') :: trace) []
      | (t,evs)::rest ->
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
[@@warning "-27"]

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

