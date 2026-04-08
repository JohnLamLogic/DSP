library ieee;
use ieee.std_logic_1164.all;

entity mux2_1_8 is port(
	sel: in std_logic;
	in0: in std_logic_vector(7 downto 0);
	in1: in std_logic_vector(7 downto 0);
	output: out std_logic_vector(7 downto 0));
end mux2_1_8;

architecture behavioral of mux2_1_8 is
begin
	with sel select
	output <= in0 when '0',
		  in1 when '1',
		  (others => '0') when others;
end behavioral;

