--------------------------------------------------------------------------------
-- ALU Register - 16-bit D flip-flop register with load enable
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ALURegister is
    port(
        D_in  : in  std_logic_vector(15 downto 0);  -- Data input
        load  : in  std_logic;                      -- Load enable
        clk   : in  std_logic;                      -- Clock signal
        D_out : out std_logic_vector(15 downto 0)   -- Data output
    );
end ALURegister;

architecture behavioral of ALURegister is
    signal reg_data : std_logic_vector(15 downto 0) := (others => '0');
begin
    process(clk)
    begin
        -- MODIFIED: triggering on falling_edge to capture data 
        -- 10ns after the rising edge stimulus.
        if falling_edge(clk) then
            if load = '1' then
                reg_data <= D_in;
            end if;
        end if;
    end process;

    D_out <= reg_data;

end behavioral;


