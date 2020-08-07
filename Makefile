.PHONY: test doc

all: build

build:
	dune build src/fsml.cma
	dune build src/fsml.cmxa

html: README.md
	pandoc -t html -o README.html README.md

doc: 
	dune build @doc
	rm -rf ../../github.io/fsml
	cp -r _build/default/_doc/_html ../../github.io/fsml

clean:
	dune clean

clobber: clean
	\rm -f *~


