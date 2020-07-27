.PHONY: test

all: build

build:
	dune build src/newfsm.cma
	dune build src/newfsm.cmxa

test:
	dune build test/test.exe
	_build/default/test/test.exe

clean:
	dune clean

clobber: clean
	\rm -f *~


