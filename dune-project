(lang dune 2.6)
(name fsml)
(source (github jserot/fsml))
(license MIT)
(authors "Jocelyn Sérot <jocelyn.serot@uca.fr>")
(maintainers "Jocelyn Sérot <jocelyn.serot@uca.fr>")
(bug_reports "jocelyn.serot@uca.fr")
(homepage "http://github.com/jserot/fsml")
(documentation "http://jserot.github.io/fsml")
(using menhir 2.0)
(allow_approximate_merlin)

(package
  (name fsml)
  (synopsis "A library for describing and describing synchronous finite state machines")
  (depends
    (menhir (>= 20200624))
    (ocaml (>= 4.10 & < 4.11))))

(generate_opam_files true)
