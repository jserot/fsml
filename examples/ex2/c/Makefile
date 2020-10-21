all: tb

tb: genimp.o tb.o
	gcc -o tb genimp.o tb.o
	./tb

genimp.o: genimp.h genimp.c
	gcc -c -I ../../../etc/c genimp.h genimp.c

tb.o: genimp.h tb.c
	gcc -c -I ../../../etc/c tb.c

clean: 
	\rm -f *.o
	\rm -f *.gch
	\rm -f tb

clobber: clean
	\rm -f *~
	\rm -f genimp.{c,h}

