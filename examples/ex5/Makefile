DOTVIEWER=open -a Graphviz
VCDVIEWER=gtkwave

all: run view

view:
	$(DOTVIEWER) test.dot
	$(DOTVIEWER) test_bis.dot

run: 
#	OCAMLRUNPARAM=b=1 dune exec ./test.exe
	dune exec ./test.exe

clean: 
	dune clean
	\rm -f *.vcd
	\rm -f test.dot

clobber: clean
	\rm -f *~

