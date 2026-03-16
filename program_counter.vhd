library ieee;
use ieee.std_logic_1164.all;
entity Program_Counter is
port(
Clk : in std_logic;
Reset : in std_logic;
D : in std_logic_vector(13 downto 0);
Q : out std_logic_vector(13 downto 0)
);
end entity;
architecture rtl of Program_Counter is
signal pc_r : std_logic_vector(13 downto 0) := (others => '0');
begin
process(Clk)
begin
if rising_edge(Clk) then
if Reset = '1' then
pc_r <= (others => '0');
else
pc_r <= D;
end if;
end if;
end process;
Q <= pc_r;
end architecture;