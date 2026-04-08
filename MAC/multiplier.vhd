library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is port(
	x: in std_logic_vector(15 downto 0);
	y: in std_logic_vector(15 downto 0);
	p: out std_logic_vector(31 downto 0));
end multiplier;

architecture behavioral of multiplier is
begin
	process(x,y)
	begin
		p <= std_logic_vector(signed(x) * signed(y));
	end process;
end behavioral;