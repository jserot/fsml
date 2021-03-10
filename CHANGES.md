# Changes

# 0.3.0 (Mar XX, 2021)
* output valuations can now be added to states (see for inst. `examples/ex{2,3}`)
* added functions `Fsm.mealy_outps`  and `Fsm.moore_outps` to move output valuations 
  from state to transitions and _vice versa_
* optional range attribute for `int` type (ex: `var k: int<0..7>`)
* added function `Fsm.defactorize` to defactorize an FSM wrt. to local variables (see `examples/ex5`)
* build now also builds a custom `utop` toplevel (which can be used, for instance, to evaluate the
  examples in `./examples/*` interactively)
  

# 0.2.1 (Oct 21, 2020)
* updated interface for functions `C.write` and `Vhdl.write` 
* distribution now correctly includes Makefile and testbenchs in examples `c` and `vhdl` subdirs

# 0.2 (Aug 14, 2020)
* first "public" version

# 0.1 (Aug 8, 2020)
* initial version 
