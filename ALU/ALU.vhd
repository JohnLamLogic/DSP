library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ALU is port(
	--buses
	dmd,r: inout std_logic_vector(15 downto 0);
	pmd: in std_logic_vector(23 downto 0);

	--control signals
	load: in std_logic_vector(5 downto 0);
	sel: in std_logic_vector(5 downto 0);
	en: in std_logic_vector(3 downto 0);
	reset: in std_logic;
	
	--other input
	opc: in std_logic_vector(4 downto 0);
	ci: in std_logic;
	clk: in std_logic;
	
	--flags
	az, an, ac, av, as: out std_logic ) ;
end ALU;

architecture structural of ALU is

signal ax0_out, ax1_out, mux1_out, mux2_out, mux0_out, ay0_out, ay1_out, mux3_out, af_out, mux4_out, alu_out, mux5_out, ar_out: std_logic_vector(15 downto 0);

component mux16_2_1 is port(
	sel: in std_logic;
	in0: in std_logic_vector(15 downto 0);
	in1: in std_logic_vector(15 downto 0);
	output: out std_logic_vector(15 downto 0)
	);
end component;
	
component register_16 is port(
	input: in std_logic_vector(15 downto 0);
	load: in std_logic;
	clear: in std_logic;
	clk: in std_logic;
	output: out std_logic_vector(15 downto 0) );
end component;

component tristate_buffer16 is port(
	input: in std_logic_vector(15 downto 0);
	enable: in std_logic;
	output: out std_logic_vector(15 downto 0) );
end component;

component alu_kernal is port(
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
end component;

begin
	
	axo : register_16 port map(
		input => dmd,
		load => load(0),
		clear => reset,
		clk => clk,
		output => ax0_out
	);

	ax1: register_16 port map(
		input => dmd,
		load => load(1),
		clear => reset,
		clk => clk,
		output => ax1_out
	);

	mux0: mux16_2_1 port map(
		sel => sel(0),
		in0 => dmd,
		in1 => pmd(23 downto 8), --check this
		output => mux0_out
	);
	
	mux1: mux16_2_1 port map(
		sel => sel(1),
		in0 => ax0_out,
		in1 => ax1_out,
		output => mux1_out
	);

	ay0: register_16 port map(
		input => mux0_out,
		load => load(2),
		clear => reset,
		clk => clk,
		output => ay0_out
	);

	ay1: register_16 port map(
		input => mux0_out,
		load => load(3),
		clear => reset,
		clk => clk,
		output => ay1_out
	);

	mux2: mux16_2_1 port map(
		sel => sel(2),
		in0 => r,
		in1 => mux1_out,
		output => mux2_out
	);
	
	mux3: mux16_2_1 port map(
		sel => sel(3),
		in0 => ay0_out,
		in1 => ay1_out,
		output => mux3_out
	);
	
	mux4: mux16_2_1 port map(
		sel => sel(4),
		in0 => mux3_out,
		in1 => af_out,
		output => mux4_out
	);
	
	alu_block: alu_kernal port map(
		x => mux2_out,
		y => mux4_out,
		cin => ci,
		amf => opc,
		r => alu_out,
		az => az,
		an => an,
		ac => ac,
		av => av,
		as => as
	);

	af: register_16 port map(
		input => alu_out,
		load => load(4),
		clear => reset,
		clk => clk,
		output => af_out
	);

	mux5: mux16_2_1 port map(
		sel => sel(5),
		in0 => alu_out,
		in1 => dmd,
		output => mux5_out
	);

	ar: register_16 port map(
		input => mux5_out,
		load => load(5),
		clear => reset,
		clk => clk,
		output => ar_out
	);

	tri0: tristate_buffer16 port map(
		input => mux1_out,
		enable => en(0),
		output => dmd
	);
	tri1: tristate_buffer16 port map(
		input => mux3_out,
		enable => en(1),
		output => dmd
	);	
	tri2: tristate_buffer16 port map(
		input => ar_out,
		enable => en(2),
		output => dmd
	);	
	tri3: tristate_buffer16 port map(
		input => ar_out,
		enable => en(3),
		output => r
	);		
	
		


end structural;