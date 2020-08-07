.PHONY: test doc

all: build

build:
	dune build src/fsml.cma
	dune build src/fsml.cmxa

html: README.md
	pandoc -t html -o README.html README.md

doc: 
	dune build @doc
	rm -rf doc/lib
	cp -r _build/default/_doc/_html doc/lib

clean:
	dune clean

clobber: clean
	\rm -f *~


