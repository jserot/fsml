all: test_fsm_pgcd

test_fsm_pgcd: fsm_pgcd.o test_fsm_pgcd.o
	gcc -o test_fsm_pgcd fsm_pgcd.o test_fsm_pgcd.o
	./test_fsm_pgcd

fsm_pgcd.o: fsm_pgcd.h fsm_pgcd.c
	gcc -c -I ../../etc/c fsm_pgcd.h fsm_pgcd.c

test_fsm_pgcd.o: fsm_pgcd.h test_fsm_pgcd.c
	gcc -c -I ../../etc/c test_fsm_pgcd.c

clean: 
	\rm -f *.o
	\rm -f test_fsm_pgcd

clobber: clean
	\rm -f *~
	\rm -f fsm_pgcd.{c,h}

