library ieee;
use ieee.std_logic_1164.all;

entity gensig is
  port(
        start: in std_logic;
        s: out std_logic;
        clk: in std_logic;
        rst: in std_logic
);
end entity;

architecture RTL of gensig is
  type t_state is ( E0, E1 );
  signal state: t_state;
begin
  process(rst, clk)
    variable k: integer range -128 to 127;
  begin
    if ( rst='1' ) then
      state <= E0;
      s <= '0';
    elsif rising_edge(clk) then 
      case state is
      when E0 =>
        if ( start='1' ) then
          k := 0;
          s <= '1';
          state <= E1;
        end if;
      when E1 =>
        if ( k<4 ) then
          k := k+1;
        elsif  ( k=4 ) then
          s <= '0';
          state <= E0;
        end if;
    end case;
    end if;
  end process;
end architecture;
