library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity join is port(
	r0: in std_logic_vector(15 downto 0);
	r1: in std_logic_vector(15 downto 0);
	r2: in std_logic_vector(7 downto 0);
	output: out std_logic_vector(39 downto 0) );
end join;

architecture behavioral of join is
begin

    output <= r2 & r1 & r0;

end behavioral;
