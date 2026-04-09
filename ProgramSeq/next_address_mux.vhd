library ieee;
use ieee.std_logic_1164.all;

entity NextAddressMUX is
    port(
        sel          : in  std_logic_vector(1 downto 0); -- From next_address_Selector
        inc_pc       : in  std_logic_vector(13 downto 0);
        jump_addr    : in  std_logic_vector(13 downto 0);
        pc_stack_out : in  std_logic_vector(13 downto 0);
        mux_out      : out std_logic_vector(13 downto 0)
    );
end NextAddressMUX;

architecture behavioral of NextAddressMUX is
begin
    process(sel, inc_pc, jump_addr, pc_stack_out)
    begin
        case sel is
            when "00" | "10" => mux_out <= inc_pc;       -- Reset or standard Next instruction
            when "11"       => mux_out <= jump_addr;    -- Jump to address in Instruction 
            when "01"       => mux_out <= pc_stack_out; -- Loop back (pop PC Stack) 
            when others     => mux_out <= inc_pc;
        end case;
    end process;
end behavioral;
