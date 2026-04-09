library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_kernal is port(
	x: in std_logic_vector(15 downto 0);
	y: in std_logic_vector(15 downto 0);
	cin: in std_logic; --carry in
	amf: in std_logic_vector(4 downto 0); --opcode
	--clk: in std_logic;
	r: out std_logic_vector(15 downto 0);
	az: out std_logic; --zero flag
	an: out std_logic; --negative flag
	ac: out std_logic; --carry flag
	av: out std_logic; --overflow flag
	as: out std_logic ); --if X is negative
end ALU_kernal;

architecture behavioral of ALU_kernal is
signal temp: std_logic_vector(15 downto 0);
signal check_add: std_logic;
signal check_x: std_logic;
signal check_y: std_logic;
--signal cin_s: std_logic_vector(15 downto 0);
begin
	process(x,y,cin,amf)
	variable cin_s: signed(15 downto 0);
	begin
		check_add <= '0';
		check_x <= '0';
		check_y <= '0';

		if (cin = '1') then
			cin_s := (others => '0');
			cin_s(0) := '1';
		else
			cin_s := (others=> '0');
		end if;

		case amf is
			when "10000" =>
				temp <= y;
			when "10001" =>
				temp <= std_logic_vector(signed(y) + 1);
				check_add <= '1';
			when "10010" =>
				temp <= std_logic_vector(signed(x) + signed(y) + cin_s); --FAIL
				check_add <= '1';
			when "10011" =>
				temp <= std_logic_vector(signed(x) + signed(y));
				check_add <= '1';
			when "10100" =>
				temp <= not y;
			when "10101" =>
				temp <= std_logic_vector(-signed(y));
			when "10110" =>
				temp <= std_logic_vector(signed(x) - signed(y) + cin_s - 1); -- FAIL
				check_x <= '1';
			when "10111" =>
				temp <= std_logic_vector(signed(x)- signed(y));
			when "11000" =>
				temp <= std_logic_vector(signed(y) - 1);
				check_y <= '1';
			when "11001" =>
				temp <= std_logic_vector(signed(y) - signed(x));
				check_y <= '1';
			when "11010" =>
				temp <= std_logic_vector(signed(y) - signed(x) + cin_s - 1); --FAIL
				check_y <= '1';
			when "11011" =>
				temp <= not x;
			when "11100" =>
				temp <= x and y; --and
			when "11101" =>
				temp <= x or y; -- or
			when "11110" =>
				temp <= x xor y;
			when "11111" =>
				temp <= std_logic_vector(abs(signed(x)));
			when others =>
				temp <= (others => '0');

		end case;
	end process;
	
	process(temp,x,y,check_add, check_x, check_y)
	begin
		if (check_add = '1' and x(15) = y(15) and temp(15) /= x(15)) then
    			av <= '1';
		elsif (check_x = '1' and x(15) /= y(15) and temp(15) /= x(15)) then
    			av <= '1';
		elsif (check_y = '1' and x(15) /= y(15) and temp(15) /= y(15)) then
    			av <= '1';
		else
    			av <= '0';
		end if;


		if (temp = (15 downto 0 => '0')) then
			az <= '1';
		else
			az <= '0';
		end if;
	
		if (temp(15) = '1') then 
			an <= '1';
		else
			an <= '0';
		end if;

	

	ac <= '0';
	as <= x(15);
	end process;

	r <= temp;
		

--after check flags:

--if temp(15) = 1 then neg
--if temp >= 2^15 1 then overflow
-- if x(15) =1 then neg
-- idk about carry

end behavioral;