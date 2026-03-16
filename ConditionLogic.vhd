library ieee;
use ieee.std_logic_1164.all;

entity Condition_Logic is
port (	cond_code	: IN std_logic_vector(3 downto 0);	-- condition code from the instruction
	loop_cond	: IN std_logic_vector(3 downto 0);	-- condition for the DO Util loop
	status		: IN  std_logic_vector(6 downto 0);	-- data from register ASTAT
	CE		: IN std_logic;				-- CE condition for the DO Util Loop
	s       	: IN std_logic;	-- control signal to select which condition code to check
	cond		: OUT std_logic
	);

end Condition_Logic;

architecture behav of Condition_logic is 
begin 
	process (cond_code, loop_cond, status, s, CE)
	variable c : std_logic;
	begin
		if (s = '1') then
			case cond_code is		
				when "0000" => c := status(0);		-- EQ
				when "0001" => c := not status(0);	-- NE
				when "0010" => c := not ((status(1) XOR status(2)) OR status(0));-- GT			
				when "0011" => c := (status(1) XOR status(2)) OR status(0);	-- LE			
				when "0100" => c := status(1) XOR status(2);			-- LT			
				when "0101" => c := not (status(1) XOR status(2));		-- GE			
				when "0110" => c := status(2);		-- AV			
				when "0111" => c := not (status(2));	-- NOT AV			
				when "1000" => c := status(3);		-- AC			
				when "1001" => c := not (status(3));	-- NOT AC			
				when "1010" => c := status(4);		-- NEG			
				when "1011" => c := not (status(4));	-- POS			
				when "1100" => c := status(6);		-- MV			
				when "1101" => c := not (status(6));	-- NOT MV			
				when "1110" => c := not CE;		-- NOT CE			
				when "1111" => c := '1';		-- Always true		
				when others => c := '0';		
			end case;
		elsif (s = '0') then	
			case loop_cond is 		
				when "0000" => c := not status(0);	-- NE			
				when "0001" => c := status(0);		-- EQ			
				when "0010" => c := (status(1) XOR status(2)) OR status(0);	-- LE 			
				when "0011" => c := not ((status(1) XOR status(2)) OR status(0));-- GT			
				when "0100" => c := not (status(1) XOR status(2));		-- GE			
				when "0101" => c := status(1) XOR status(2);			-- LT			
				when "0110" => c := not (status(2));	-- NOT AV		
				when "0111" => c := status(2);		-- AV
				when "1000" => c := not (status(3));	-- NOT AC
				when "1001" => c := status(3);		-- AC
				when "1010" => c := not (status(4));	-- POS
				when "1011" => c := status(4);		-- NEG
				when "1100" => c := not (status(6));	-- NOT MV
				when "1101" => c := status(6);		-- MV
				when "1110" => c := CE;			-- CE
				when "1111" => c := '1';		-- Always true
				when others => c := '0';	

			end case;
		end if;
		cond <= c;
	end process;
end behav;



