library ieee;
use ieee.std_logic_1164.all;

entity reg_16 is port(
	input: in std_logic_vector(15 downto 0);
	load: in std_logic;
	clear: in std_logic;
	clk: in std_logic;
	output: out std_logic_vector(15 downto 0));
end reg_16;

architecture behavioral of reg_16 is
begin
	process(clk, clear)
	begin
		if clear = '1' then
			output <= x"0000";
		elsif rising_edge(clk) then
			if load = '1' then
				output <= input;
			end if;
		end if;
	end process;
end behavioral;
