#use "topfind";;
#require "yojson";;
#require "ppx_deriving.runtime";;
#require "ppx_deriving_yojson.runtime";;
#directory "../../_build/default/src";;
#directory "../../_build/default/src/.fsml.objs/byte";;
#load "fsml.cma";;

open Fsml
open Fsm
   
let f = Parse.fsm "
    name: pgcd;
    states: Idle, Comp;
    inputs:
      start: bool,
      m: uint<8>;
    outputs:
      rdy: bool,
      r: uint<8>;
    vars:
      a: uint<8>;
    trans:
        Idle -> Comp when start='0' with a:=m, rdy:='0';
        Comp -> Idle when a=0 with rdy:='1', r:=a+a;
    itrans: -> Idle with rdy:='1';
    " |> Typing.type_check_fsm
      
let _ = Dot.view f
let _ = Vhdl.write ~fname:"test1" f
let _ = Vhdl.cfg.Vhdl.use_numeric_std <- true
let _ = Vhdl.write ~fname:"test2" f
          
