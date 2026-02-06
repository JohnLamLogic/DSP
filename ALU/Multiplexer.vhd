--------------------------------------------------------------------------------
-- Multiplexer - 2:1 MUX for 16-bit data
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Multiplexer is
    port(
        M_in1 : in  std_logic_vector(15 downto 0);  -- Input 0
        M_in2 : in  std_logic_vector(15 downto 0);  -- Input 1
        Sel   : in  std_logic;                      -- Select signal
        M_out : out std_logic_vector(15 downto 0)   -- Output
    );
end Multiplexer;

architecture behavioral of Multiplexer is
begin
    M_out <= M_in1 when Sel = '0' else M_in2;
end behavioral;



