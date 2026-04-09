library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity loop_comparator is port(
	stack_data_out: in std_logic_vector(13 downto 0);
	next_pc: in std_logic_vector(13 downto 0);
	stack_empty: in std_logic;
	lastinst: out std_logic
);
end loop_comparator;

architecture behavioral of loop_comparator is

begin
	
	process(stack_data_out, next_pc, stack_empty)
	begin
		if(stack_empty = '0') and (stack_data_out = next_pc) then
			lastinst <= '1';
		else
			lastinst <= '0';
		end if;
	end process;
end behavioral;


