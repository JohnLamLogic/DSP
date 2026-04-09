library ieee;
use ieee.std_logic_1164.all;

entity Status_Register is
    port(
        Clk       : in  std_logic;
        rs        : in  std_logic;
        
        -- The 5 specific flags from your ALU
        flag_AZ   : in  std_logic; -- Zero
        flag_AN   : in  std_logic; -- Negative
        flag_AV   : in  std_logic; -- Overflow
        flag_AC   : in  std_logic; -- Carry
        flag_AS   : in  std_logic; -- Sign
        
        -- The 7-bit padded output going to your Condition Logic
        astat_out : out std_logic_vector(6 downto 0) 
    );
end Status_Register;

architecture behavioral of Status_Register is
begin
    process(Clk, rs)
    begin
        if rs = '1' then
            astat_out <= (others => '0');
        elsif rising_edge(Clk) then
            -- Map the 5 active flags exactly where Condition Logic expects them
            astat_out(0) <= flag_AZ;
            astat_out(1) <= flag_AN;
            astat_out(2) <= flag_AV;
            astat_out(3) <= flag_AC;
            astat_out(4) <= flag_AS;
            
            -- Hardwire the missing/unused bits to 0
            astat_out(5) <= '0'; 
            astat_out(6) <= '0'; -- Missing MAC Overflow (MV)
        end if;
    end process;
end behavioral;
