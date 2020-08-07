.PHONY: test doc

all: build

build:
	dune build src/fsml.cma
	dune build src/fsml.cmxa

html: README.md
	pandoc -t html -o README.html README.md

doc: 
	dune build @doc

clean:
	dune clean

clobber: clean
	\rm -f *~


