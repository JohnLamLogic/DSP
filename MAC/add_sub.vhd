library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is port(
	mr: in std_logic_vector(39 downto 0);
	p: in std_logic_vector(31 downto 0);
	amf: in std_logic_vector(4 downto 0);
	r0: out std_logic_vector(15 downto 0);
	r1: out std_logic_vector(15 downto 0);
	r2: out std_logic_vector(7 downto 0);
	mv: out std_logic );
end add_sub;

architecture behavioral of add_sub is
	signal result: std_logic_vector(40 downto 0);
begin
	process(amf,mr,p)
	begin
	case amf is
		when "00000" =>
			result <= (others => '0'); --Reset to 0
		when "00001" =>
			result <= std_logic_vector(resize(signed(p), 41)); 
		when "00010" =>
			result <= std_logic_vector(resize(signed(mr), 41) + resize(signed(p), 41));
		when "01100" =>
			result <= std_logic_vector(resize(signed(mr), 41) - resize(signed(p), 41));
		when others =>
			result <= (others => '0');
	end case;
end process;

r0 <= result(15 downto 0);
r1 <= result(31 downto 16);
r2 <= result(39 downto 32);
mv <= result(40);

end behavioral;
