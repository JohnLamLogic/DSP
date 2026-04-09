library ieee;
use ieee.std_logic_1164.all;

entity loop_stack is port(
	clk: in std_logic;
	reset: in std_logic;
	push: in std_logic;
	pop: in std_logic;
	rs: in std_logic;

	data_in: in std_logic_vector(17 downto 0);

	loop_cond: out std_logic_vector(3 downto 0);
	loop_end_addr: out std_logic_vector(13 downto 0);
	overflow: out std_logic;
	underflow: out std_logic
);
end loop_stack;

architecture structural of loop_stack is
	component stack is
		generic(
			width: integer := 14;
			height: integer := 4
		);
        	port(
       	 		clk       : in  std_logic;
        		reset     : in  std_logic;                            -- active low, async
        		push      : in  std_logic;
        		pop       : in  std_logic;
        		rs        : in  std_logic;                            -- synchronous stack clear
        		data_in   : in  std_logic_vector(width-1 downto 0);
        		data_out  : out std_logic_vector(width-1 downto 0);
        		overflow  : out std_logic;
        		underflow : out std_logic
    		);
	end component;

	signal internal_dout: std_logic_vector(17 downto 0);

begin
	u_gen_stack: stack
	generic map(width => 18, height => 4)
	port map(
		clk       => clk,
        	reset     => reset,
       		push      => push,
        	pop       => pop,
        	rs        => rs,
        	data_in   => data_in,
        	data_out  => internal_dout, 
        	overflow  => overflow,
        	underflow => underflow
    	);

 
    	loop_cond     <= internal_dout(17 downto 14);
    	loop_end_addr <= internal_dout(13 downto 0);

end structural;
