library ieee;
use ieee.std_logic_1164.all;

entity tristate_16 is port(
	input: in std_logic_vector(15 downto 0);
	enable: in std_logic;
	output: out std_logic_vector(15 downto 0));
end tristate_16;

architecture behavioral of tristate_16 is
begin
	process(input,enable)
	begin
		if(enable = '1') then
			output <= input;
		else
			output <= "ZZZZZZZZZZZZZZZZ";
		end if;
	end process;
end behavioral;
