.PHONY: test

all: build

build:
	dune build src/fsml.cma
	dune build src/fsml.cmxa

clean:
	dune clean

clobber: clean
	\rm -f *~


