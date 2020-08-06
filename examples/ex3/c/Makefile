all: tb

tb: fsm_pgcd.o tb.o
	gcc -o tb fsm_pgcd.o tb.o
	./tb

fsm_pgcd.o: fsm_pgcd.h fsm_pgcd.c
	gcc -c -I ../../../etc/c fsm_pgcd.h fsm_pgcd.c

tb.o: fsm_pgcd.h tb.c
	gcc -c -I ../../../etc/c tb.c

clean: 
	\rm -f *.o
	\rm -f *.gch
	\rm -f tb

clobber: clean
	\rm -f *~
	\rm -f fsm_pgcd.{c,h}

