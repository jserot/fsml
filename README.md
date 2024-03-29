FSML 
====

FSML is a library for describing, simulating synchronous Finite State Machines in OCaml.

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

* a set of PPX extensions for building values of type `Fsm.t` 

* functions to transforming FSMs (moving output valuations from states to transitions and _vice
  versa_ and defactorizing wrt. local variables)
  
* functions for producing and viewing graphical representations of FSMs in the `.dot` format

* functions for saving and reading FSM representations in files using the JSON format

* functions for performing single or multi-step simulations of FSMs and generating trace files in
  the `.vcd` format to be viewed by VCD viewers such as [gtkwave](http://gtkwave.sourceforge.net)

* functions for generating C or VHDL code from a FSM representation (for integration into existing
  code and/or simulation)

Examples
--------

A few examples are provided in the [examples](https://github.com/jserot/fsml/tree/master/examples)
directory.

Here is the description of a simple FSM generating of fixed length impulsion on its output `s`
whenever its output `start` is set to 1:

```
let f = [%fsm "
    name: gensig;
    states: E0, E1;
    inputs: start:bool;
    outputs: s:bool;
    vars: k:int<0..4>;
    trans:
      E0 -> E1 when start='1' with k:=0, s:='1';
      E1 -> E1 when k<4 with k:=k+1;
      E1 -> E0 when k=4 with s:='0';
    itrans: -> E0 with s:='0';
    "]
```

Here is its graphical representation, obtained by evaluating `let _ = Dot.view f`:

![](https://github.com/jserot/fsml/blob/master/docs/figs/genimp.png "")

Here is the result of evaluating `Simul.run ~stop_after:7 ~stim:[%fsm_stim "start: 0,'0'; 1,'1'; 2,'0'"] f`:

```
(0, [("start", (Bool false)); ("state", (Enum "E0")); ("s", (Bool false))])
(1, [("start", (Bool true)); ("state", (Enum "E1")); ("k", (Int 0)); ("s", (Bool true))])
(2, [("start", (Bool false)); ("k", (Int 1))])
(3, [("k", (Int 2))])
(4, [("k", (Int 3))])
(5, [("k", (Int 4))])
(6, [("state", (Enum "E0")); ("s", (Bool false))])
```

... and the corresponding generated VCD file, viewed by `gtkwave`:

![](https://github.com/jserot/fsml/blob/master/docs/figs/genimp-wave.png "")

The C and VHDL code generated for this FSM can be viewed
[here](https://github.com/jserot/fsml/blob/master/docs/code).

In example above, the `s` output is defined by attaching modifications of this output to the _transitions_ of the FSM. It is
also possible to attach output valuations to _states_, as illustrated below:

```
let f = [%fsm "
    name: gensig_bis;
    states: E0 with s=`0`, E1 with s=`1`;
    inputs: start:bool;
    outputs: s:bool;
    vars: k:int<0..4>;
    trans:
      E0 -> E1 when start='1' with k:=0;
      E1 -> E1 when k<4 with k:=k+1;
      E1 -> E0 when k=4;
    itrans: -> E0;
    "]
```

with the corresponding graphical representation :

![](https://github.com/jserot/fsml/blob/master/docs/figs/genimp-bis.png "")

The library provides two functions (`Fsm.mealy_outputs` and `Fsm.moore_outputs`) to automatically
convert FSM written using one style to the other.

The library also provide a function to "defactorize" a FSM wrt. to one (or several) of its local
variables, _i.e._ replacing these variables by sets of dedicated states. For example, writing

```
let f' = Fsm.defactorize ~vars:["k",Expr.Int 0] f 
```

gives the following FSM :

![](https://github.com/jserot/fsml/blob/master/docs/figs/genimp-defact.png "")

in which states denoted `E0i` (resp. `E1i`) correspond to initial state `E0` (resp. `E1`) and
value `i` for the removed variable `k`.

Documentation
-------------

The library API is documented [here](https://jserot.github.io/fsml/index.html)

Installation
------------

FSML is available as an [OPAM package](https://opam.ocaml.org/packages/fsml).

### Building from source

To build from source, the pre-requisites are :

* `ocaml` (>= 4.10.0) with the following packages installed
  - `dune`
  - `menhir`
  - `yojson`
  - `ppxlib`
  - `ppx_deriving`

Download the source tree (`git clone https://github.com/jserot/fsml`).

From the root of the source tree :

1. `make`

Running the examples
--------------------

To try the examples :

1. go the directory containing the example (*e.g.* `cd examples/ex2`)
2. `make run; make view`

Depending on the example, this will
- generate and view the graphical representation
- run the simulation
- generate C and/or VHDL code (in subdirectory `c` and `vhdl` resp.)

The generated C and/or VHDL code can be tested by going to corresponding subdir and invoking
`make` (you may have to adjust some definitions in the provided `Makefile`).

*NOTE* : Under Linux and Windows, the `dotty` application supplied in the `graphviz` package is
buggy. To view the generated `.dot` files, first convert it to the `gif` format using the
`dot` command and open the result file with any `gif` viewer. For example

```
dot -T gif -o test.gif test.dot
xv test.gif
```
