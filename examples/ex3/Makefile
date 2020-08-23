DOTVIEWER=open -a Graphviz
VCDVIEWER=gtkwave

all: run view

view:
	$(DOTVIEWER) test.dot
	$(VCDVIEWER) test.vcd test.gtkw

c:
	(cd c; make)

vhdl:
	(cd vhdl; make)

run: 
	dune exec ./test.exe

clean: 
	dune clean
	\rm -f *.vcd
	\rm -f test.dot
	(cd c; make clean)
	(cd vhdl; make clean)

clobber: clean
	\rm -f *~
	(cd c; make clobber)
	(cd vhdl; make clobber)

