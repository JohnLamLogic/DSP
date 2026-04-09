library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity PC_Incrementer is
 port(
 PC_in : in std_logic_vector(13 downto 0);
 PC_plus : out std_logic_vector(13 downto 0)
 );
end entity;
architecture rtl of PC_Incrementer is
begin
 PC_plus <= std_logic_vector(unsigned(PC_in) + 1);
end architecture;
