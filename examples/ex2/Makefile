DOTVIEWER=open -a Graphviz
VCDVIEWER=gtkwave

all: run view

view:
	$(DOTVIEWER) test.dot
	$(DOTVIEWER) test_bis.dot
	$(DOTVIEWER) test_ter.dot
	$(VCDVIEWER) test.vcd test.gtkw >/tmp/$(VCDVIEWER).log 2>&1

run: 
	dune exec ./test.exe

clean: 
	dune clean
	\rm -f *.vcd
	\rm -f test*.dot
	(cd ./c; make clean)
	(cd ./vhdl; make clean)

clobber: clean
	\rm -f *~
	(cd ./c; make clobber)
	(cd ./vhdl; make clobber)

