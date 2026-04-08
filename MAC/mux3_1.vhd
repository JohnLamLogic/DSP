library ieee;
use ieee.std_logic_1164.all;

entity mux3_1 is port(
	sel: in std_logic_vector(1 downto 0);
	in0: in std_logic_vector(15 downto 0);
	in1: in std_logic_vector(15 downto 0);
	in2: in std_logic_vector(15 downto 0);
	output: out std_logic_vector(15 downto 0));
end mux3_1;

architecture behavioral of mux3_1 is
begin
	with sel select
	output <= in0 when "00",
		  in1 when "01",
		  in2 when "10",
		  (others => '0') when others;
end behavioral;

