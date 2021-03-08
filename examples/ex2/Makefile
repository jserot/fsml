DOTVIEWER=open -a Graphviz
VCDVIEWER=gtkwave

all: run view

view:
	$(DOTVIEWER) test.dot
	$(DOTVIEWER) test_bis.dot
	$(DOTVIEWER) test_ter.dot
	$(VCDVIEWER) test.vcd test.gtkw

run: 
	dune exec ./test.exe

clean: 
	dune clean
	\rm -f *.vcd
	\rm -f test.dot

clobber: clean
	\rm -f *~

