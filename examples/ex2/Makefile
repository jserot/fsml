DOTVIEWER=open -a Graphviz
VCDVIEWER=gtkwave

all: run view

view:
	$(DOTVIEWER) test.dot
	$(VCDVIEWER) test.vcd test.gtkw

run: 
	dune exec ./test.exe

clean: 
	dune clean
	\rm -f *.vcd
	\rm -f test.dot

clobber: clean
	\rm -f *~

