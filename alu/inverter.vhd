library ieee;
use ieee.std_logic_1164.all;

entity inverter is
	port(
		input: in bit;
		output: out bit);
end entity inverter;

architecture arch_inverter of inverter is
begin
	output <= NOT input;
end architecture arch_inverter;

