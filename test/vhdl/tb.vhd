library ieee;
use ieee.std_logic_1164.all;	   
use ieee.numeric_std.all;

-- Note : this file was, mostly, automatically generated using
-- the RFSM compiler (https://github.com/jserot/rfsm)

entity tb is
end entity;

architecture struct of tb is

component pgcd is
  port(
        start: in integer;
        m: in integer;
        n: in integer;
        rdy: out integer;
        r: out integer;
        clk: in std_logic;
        rst: in std_logic
        );
end component;

signal clk: std_logic;
signal rst: std_logic;
signal start: integer;
signal m: integer;
signal n: integer;
signal rdy: integer;
signal r: integer;

begin

  inp_data: process
    type t_vc is record date: time; val1: integer; val2: integer; end record;
    type t_vcs is array ( 0 to 0 ) of t_vc;
    constant vcs : t_vcs := ( others => (0 ns, 24, 36) );
    variable i : natural := 0;
    variable t : time := 0 ns;
    begin
      for i in 0 to 0 loop
        wait for vcs(i).date-t;
        m <= vcs(i).val1;
        n <= vcs(i).val2;
        t := vcs(i).date;
      end loop;
      wait;
  end process;

  inp_start: process
    type t_vc is record date: time; val: integer; end record;
    type t_vcs is array ( 0 to 2 ) of t_vc;
    constant vcs : t_vcs := ( (0 ns,0), (15 ns,1), (35 ns,0) );
    variable i : natural := 0;
    variable t : time := 0 ns;
    begin
      for i in 0 to 2 loop
        wait for vcs(i).date-t;
        Start <= vcs(i).val;
        t := vcs(i).date;
      end loop;
      wait;
  end process;

  inp_clk: process
    type t_periodic is record period: time; t1: time; t2: time; end record;
    constant periodic : t_periodic := ( 10 ns, 10 ns, 100 ns );
    variable t : time := 0 ns;
    begin
      clk <= '0';
      wait for periodic.t1;
      t := t + periodic.t1;
      while ( t < periodic.t2 ) loop
        clk <= '1';
        wait for periodic.period/2;
        clk <= '0';
        wait for periodic.period/2;
        t := t + periodic.period;
      end loop;
      wait;
  end process;

  inp_reset: process
  begin
    rst <= '1';
    wait for 1 ns;
    rst <= '0';
    wait for 100 ns;
    wait;
  end process;

  UUT: pgcd port map(start, m, n, rdy, r, clk, rst);

end architecture;
