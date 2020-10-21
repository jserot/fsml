GHDL=ghdl
GHDLOPTS=-fno-color-diagnostics -P$(LIBDIR)/lib/vhdl
VCDVIEWER=gtkwave

all: run

run: tb
	$(GHDL) -r $(GHDLOPTS) tb --vcd=tb.vcd

view: run
	$(VCDVIEWER) tb.vcd tb.gtkw > /tmp/gtkwave.log 2>&1; echo $$?

clean:
	\rm -f work*.cf
	\rm -f *.o
	\rm -f tb
	\rm -f tb.vcd
	\rm -f tb.ghw

clobber: clean
	\rm -f *~
	\rm -f fsm_pgcd.vhd
	\rm -rf html

tb: genimp.vhd tb.vhd
	$(GHDL) -a $(GHDLOPTS) genimp.vhd
	$(GHDL) -a $(GHDLOPTS) tb.vhd
	$(GHDL) -e $(GHDLOPTS) tb
