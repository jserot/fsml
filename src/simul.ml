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

type ctx = {
  state: State.t;
  env: Expr.env
  }
[@@deriving show]

let check_fsm m = Typing.type_check_fsm m
let check_stimuli m st = Typing.type_check_stimuli m st

let output_state_events m state =
  (try List.assoc state m.states
  with Not_found -> failwith "Simul.output_state_events: invalid state") (* should not happen *)
  |> List.map (fun (o,e) -> Action.Assign (o,e))

let step ctx m = 
  match List.find_opt (Transition.is_fireable ctx.state (Builtins.eval_env @ ctx.env)) m.trans with
    | Some (src, _, acts, dst) -> 
       let acts' = acts @ output_state_events m dst in
       let evs = List.concat @@ List.map (Action.perform (Builtins.eval_env @ ctx.env)) acts' in
       (if src <> dst then ("state",Expr.Enum dst)::evs else evs),
       { state = dst;
         env = List.fold_left Expr.update_env ctx.env evs }
    | None ->
       [],
       ctx

let run ?ctx ?(stop_when=[]) ?(stop_after=0) ?(trace=false) ~stim m =
  let open Clock in
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
  let trace_log = ref ([] : ctx clocked list) in
  let rec eval (clk, ctx, evs) stim =
    if eval_stop_conds clk ctx then List.rev evs, List.rev !trace_log (* Done ! *)
    else
      match stim with
      | (t,evs')::rest when t=clk ->
         let ctx' = { ctx with env = List.fold_left Expr.update_env ctx.env evs' } in
         let evs'', ctx'' = step ctx' m in
         if trace then trace_log := (t,ctx'')::!trace_log;
         let evs''' =
           begin match evs with
           | (t',es)::rest when t'=t -> (t',es@evs'')::rest
           | _ -> (t,evs'')::evs
           end in
         eval (clk+1, ctx'', evs''') rest
      | _ ->  (* No applicable stimuli *)
         let evs', ctx' = step ctx m in
         if trace then trace_log := (clk,ctx')::!trace_log;
         eval (clk+1, ctx', (clk, evs')::evs) [] in
  let ctx, evs = match ctx, m.Fsm.itrans with
    | Some c, _ ->
       c,
       []
    | None, (s0,acts0) ->
       let env0 = List.map (fun (id,_) -> id, Expr.Unknown) (m.inps @ m.outps @ m.vars) in
       let acts0' = acts0 @ output_state_events m s0 in
       let evs0 = List.concat @@ List.map (Action.perform (Builtins.eval_env @ env0)) acts0' in
       { state = s0; env = List.fold_left Expr.update_env env0 evs0 },
       [0, ("state",Expr.Enum s0)::evs0] in
  if trace then trace_log := [0,ctx];
  eval (0, ctx, evs) stim
