(* Dot output *)

type options = {
    node_shape: string;
    node_style: string;
    rankdir: string;
    layout: string;
    mindist: float
  }

let default_options = {
    node_shape = "circle";
    node_style = "solid";
    rankdir = "UD";
    layout = "dot"; 
    mindist = 1.0;
  }

let output oc ?(options=default_options) m = 
    let open Fsm in
    let ini_id = "_ini" in
    let dump_istate () = 
      Printf.fprintf oc "%s [shape=point; label=\"\"; style = invis]\n" ini_id in
    let dump_state id =
      Printf.fprintf oc "%s [label = \"%s\", shape = %s, style = %s]\n"
        id
        id
        options.node_shape
        options.node_style in
    let dump_itransition (dst,actions) =
      let l = String.length @@ Transition.string_of_actions actions in
      let sep = "\n" ^ String.make l '_' ^ "\n" in
      let t = (ini_id,[],actions,dst) in
      Printf.fprintf oc "%s\n" (Transition.to_string ~label_sep:sep ~label_ldelim:"[label=\"" ~label_rdelim:"\"]" t) in
    let dump_transition ((_,guards,actions,_) as t) =
      let l = max (String.length @@ Transition.string_of_guards guards) (String.length @@ Transition.string_of_actions actions) in
      let sep = "\n" ^ String.make l '_' ^ "\n" in
        Printf.fprintf oc "%s\n" (Transition.to_string ~label_sep:sep ~label_ldelim:"[label=\"" ~label_rdelim:"\"]" t) in
    Printf.fprintf oc "digraph %s {\nlayout = %s;\nrankdir = %s;\nsize = \"8.5,11\";\nlabel = \"\"\n center = 1;\n nodesep = \"0.350000\"\n ranksep = \"0.400000\"\n fontsize = 14;\nmindist=\"%1.1f\"\n"
      m.id
      options.layout
      options.rankdir
      options.mindist;
    dump_istate ();
    List.iter dump_state m.states;
    dump_itransition m.istate;
    List.iter dump_transition m.trans;
    Printf.fprintf oc "}\n"

let write fname ?(options=default_options) m = 
  let oc = open_out fname in
  output oc ~options m;
  Printf.printf "Wrote file %s\n" fname;
  close_out oc
  
let view ?(options=default_options) ?(fname="") ?(cmd="open -a Graphviz") m = 
  let fname = match fname with
    | "" -> "/tmp/" ^ m.Fsm.id ^ "_fsm.dot"
    | _ -> fname in
  let _ = write fname ~options m in
  Sys.command (cmd ^ " " ^ fname)
