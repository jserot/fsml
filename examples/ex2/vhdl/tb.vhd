library ieee;
use ieee.std_logic_1164.all;	   
use ieee.numeric_std.all;

entity tb is
end entity;

architecture struct of tb is

component gensig is
  port(
        start: in std_logic;
        s: out std_logic;
        clk: in std_logic;
        rst: in std_logic
);
end component;

signal clk: std_logic;
signal rst: std_logic;
signal start: std_logic;
signal s: std_logic;

begin

  inp_start: process
    type t_vc is record date: time; val: std_logic; end record;
    type t_vcs is array ( 0 to 2 ) of t_vc;
    constant vcs : t_vcs := ( (0 ns, '0'), (15 ns, '1'), (25 ns, '0') );
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

  UUT: gensig port map(start, s, clk, rst);

end architecture;
