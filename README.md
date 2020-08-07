FSML 
====

FSML is a library for describing and simulating synchronous Finite State Machines in OCaml.

It is a simplified version of the library provided in the [Rfsm](http://github.com/jserot/rfsm)
package for which

* the system is composed of a single FSM

* this FSM has a single, implicit, triggering event (typically called the _clock_, hence the term
_synchronous_ used in the description)

The library provides

* a type `Fsm.t` for describing FSMs
  - possibly having _local variables_
  - for which _transitions_, implicitely triggered by a clock, are defined by a set of _boolean guards_ and a
  set of _actions_ 

* a set of _dedicated parsers_ for building values of type `Fsm.t` 

* functions for producing and viewing graphical representations of FSMs in the `.dot` format

* functions for saving and reading FSM representations in files using the JSON format

* functions for performing single or multi-step simulations of FSMs

* functions for generating C or VHDL code from a FSM representation (for integration into existing
  code and/or simulation)

Examples
--------

A few examples are provided in the [examples](https://github.com/jserot/fsml/tree/master/examples)
directory.

Here is the description of a simple FSM generating of fixed length impulsion on its output `s`
whenever its output `start` is set to 1:

```
let f = {
    id="genimp";
    states=["E0"; "E1"];
    itrans="E0", [];
    inps=["start"];
    outps=["s"];
    vars=["k"];
    trans=[
      mk_trans "E0 -> E1 when start=1 with k:=0, s:=1";
      mk_trans "E1 -> E1 when k<4 with k:=k+1";
      mk_trans "E1 -> E0 when k=4 with s:=0";
      ]
    }
```

Here is its graphical representation, obtained by evaluating `let _ = Dot.view f`:

![](https://github.com/jserot/fsml/blob/master/doc/figs/genimp.png "")


Documentation
-------------

The library API is documented [here](https://jserot.github.io/fsml/index.html)

Installation
------------

Pre-requisites :

* `ocaml` (>= 4.10.0) with the following packages installed
  - `dune`
  - `yojson`
  - `ppx_deriving`

Download the source tree (`git clone https://github.com/jserot/fsml`).

From the root of the source tree :

1. `make`

To try the examples :

1. go the directory containing the example (*e.g.* `cd examples/ex2`)
2. `dune exec ./test.exe`

Depending on the example, this will
- generate and view the graphical representation
- run the simulation
- generate C and/or VHDL code (in subdirectory `c` and `vhdl` resp.)

The generated C and/or VHDL code can be tested by going to corresponding subdir and invoking
`make` (you may have to adjust some definitions in the provided `Makefile`).
