library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity extender is port(
	input: in std_logic_vector(7 downto 0);
	output: out std_logic_vector(15 downto 0));
end extender;

architecture behavioral of extender is
begin

    output <= std_logic_vector(
        resize(signed(input), 16)
    );

end behavioral;
