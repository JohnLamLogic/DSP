--------------------------------------------------------------------------------
-- Tri-State Buffer - 16-bit buffer with high-impedance control
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity TriStateBuffer is
    port(
        T_in  : in  std_logic_vector(15 downto 0);  -- Data input
        En    : in  std_logic;                      -- Enable signal
        T_out : out std_logic_vector(15 downto 0)   -- Data output (or Hi-Z)
    );
end TriStateBuffer;

architecture behavioral of TriStateBuffer is
begin
    T_out <= T_in when En = '1' else (others => 'Z');
end behavioral;



