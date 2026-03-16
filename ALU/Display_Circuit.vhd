--------------------------------------------------------------------------------
-- Display Circuit - 7-segment decoder for hexadecimal display
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity Display_Circuit is
    port(
        Input         : in  std_logic_vector(3 downto 0);   -- 4-bit input (0-F)
        segmentSeven  : out std_logic_vector(6 downto 0)    -- 7-segment output
    );
end Display_Circuit;

architecture behav_display of Display_Circuit is
begin
    process(Input)
    begin
        case Input is
            when "0000" => segmentSeven <= "1000000"; -- 0
            when "0001" => segmentSeven <= "1111001"; -- 1
            when "0010" => segmentSeven <= "0100100"; -- 2
            when "0011" => segmentSeven <= "0110000"; -- 3
            when "0100" => segmentSeven <= "0011001"; -- 4
            when "0101" => segmentSeven <= "0010010"; -- 5
            when "0110" => segmentSeven <= "0000010"; -- 6
            when "0111" => segmentSeven <= "1111000"; -- 7
            when "1000" => segmentSeven <= "0000000"; -- 8
            when "1001" => segmentSeven <= "0010000"; -- 9
            when "1010" => segmentSeven <= "0001000"; -- A
            when "1011" => segmentSeven <= "0000011"; -- b
            when "1100" => segmentSeven <= "0100001"; -- c
            when "1101" => segmentSeven <= "1000010"; -- d
            when "1110" => segmentSeven <= "0000110"; -- E
            when "1111" => segmentSeven <= "0001110"; -- F
            when others => segmentSeven <= "1111111"; -- blank
        end case;
    end process;
end behav_display;



