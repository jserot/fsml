all: 
	dune exec ./test.exe
	(cd c; make)
	(cd vhdl; make)

clean: 
	dune clean
	(cd c; make clean)
	(cd vhdl; make clean)

clobber: clean
	\rm -f *~
	(cd c; make clobber)
	(cd vhdl; make clobber)

