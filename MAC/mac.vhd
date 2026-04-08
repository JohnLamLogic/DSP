library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity MAC is port(
	--buses
	dmd: inout std_logic_vector(15 downto 0);
	pmd: in std_logic_vector(23 downto 0);
	r: inout std_logic_vector(15 downto 0);
	
	load: in std_logic_vector(7 downto 0);
	sel: in std_logic_vector(11 downto 0);
	en: in std_logic_vector(5 downto 0);
	amf: in std_logic_vector(4 downto 0);

	clk: in std_logic;
	mv: out std_logic;
	reset: in std_logic );
end MAC;

architecture structural of MAC is

signal mx0_out, mx1_out, my0_out, my1_out, mf_out, mr2_extended, mr1_out, mr0_out, mux0_out, mux1_out, mux2_out,
mux4_out, mux5_out, mux6_out, mux3_out, mux8_out, mux9_out, mux10_out, r1_out, r0_out: std_logic_vector(15 downto 0);

signal mr2_out, r2_out, mux7_out: std_logic_vector(7 downto 0);

signal mult_out: std_logic_vector(31 downto 0);

signal mr_combined: std_logic_vector(39 downto 0);

component reg_16 is port(
	input: in std_logic_vector(15 downto 0);
	load: in std_logic;
	clear: in std_logic;
	clk: in std_logic;
	output: out std_logic_vector(15 downto 0));
end component;

component mux2_1 is port(
	sel: in std_logic;
	in0: in std_logic_vector(15 downto 0);
	in1: in std_logic_vector(15 downto 0);
	output: out std_logic_vector(15 downto 0));
end component;

component multiplier is port(
	x: in std_logic_vector(15 downto 0);
	y: in std_logic_vector(15 downto 0);
	p: out std_logic_vector(31 downto 0));
end component;

component add_sub is port(
	mr: in std_logic_vector(39 downto 0);
	p: in std_logic_vector(31 downto 0);
	amf: in std_logic_vector(4 downto 0);
	r0: out std_logic_vector(15 downto 0);
	r1: out std_logic_vector(15 downto 0);
	r2: out std_logic_vector(7 downto 0);
	mv: out std_logic );
end component;

component mux3_1 is port(
	sel: in std_logic_vector(1 downto 0);
	in0: in std_logic_vector(15 downto 0);
	in1: in std_logic_vector(15 downto 0);
	in2: in std_logic_vector(15 downto 0);
	output: out std_logic_vector(15 downto 0));
end component;

component extender is port(
	input: in std_logic_vector(7 downto 0);
	output: out std_logic_vector(15 downto 0));
end component;

component tristate_16 is port(
	input: in std_logic_vector(15 downto 0);
	enable: in std_logic;
	output: out std_logic_vector(15 downto 0));
end component;

component reg_8 is port(
	input: in std_logic_vector(7 downto 0);
	load: in std_logic;
	clear: in std_logic;
	clk: in std_logic;
	output: out std_logic_vector(7 downto 0));
end component;

component mux2_1_8 is port(
	sel: in std_logic;
	in0: in std_logic_vector(7 downto 0);
	in1: in std_logic_vector(7 downto 0);
	output: out std_logic_vector(7 downto 0));
end component;

component join is port(
	r0: in std_logic_vector(15 downto 0);
	r1: in std_logic_vector(15 downto 0);
	r2: in std_logic_vector(7 downto 0);
	output: out std_logic_vector(39 downto 0) );
end component;

begin
	mux0: mux2_1 port map(
		sel => sel(0),
		in0 => dmd,
		in1 => pmd(23 downto 8),
		output => mux0_out
	);

	mx0: reg_16 port map(
		input => dmd,
		load => load(0),
		clear => reset,
		clk => clk,
		output => mx0_out
	);

	mx1: reg_16 port map(
		input => dmd,
		load => load(1),
		clear => reset,
		clk => clk,
		output => mx1_out
	);

	my0: reg_16 port map(
		input => mux0_out,
		load => load(2),
		clear => reset,
		clk => clk,
		output => my0_out
	);

	my1: reg_16 port map(
		input => mux0_out,
		load => load(3),
		clear => reset,
		clk => clk,
		output => my1_out
	);

	mux1: mux2_1 port map(
		sel => sel(1),
		in0 => mx0_out,
		in1 => mx1_out,
		output => mux1_out
	);

	mux2: mux2_1 port map(
		sel => sel(2),
		in0 => mx0_out,
		in1 => mx1_out,
		output => mux2_out
	);

	mux3: mux2_1 port map(
		sel => sel(3),
		in0 => my0_out,
		in1 => my1_out,
		output => mux3_out
	);

	mux4: mux2_1 port map(
		sel => sel(4),
		in0 => my0_out,
		in1 => my1_out,
		output => mux4_out
	);

	mux5: mux2_1 port map(
		sel => sel(5),
		in0 => r,
		in1 => mux2_out,
		output => mux5_out
	);
	
	mux6: mux2_1 port map(
		sel => sel(6),
		in0 => mux3_out,
		in1 => mf_out,
		output => mux6_out
	);

	mult: multiplier port map(
		x => mux5_out,
		y => mux6_out,
		p => mult_out
	);

	mf: reg_16 port map(
		input => r1_out,
		load => load(4),
		clear => reset,
		clk => clk,
		output => mf_out
	);

	--mr_combined <= mr2_out & mr1_out & mr0_out;
	comb: join port map(
		r0 => mr0_out,
		r1 => mr1_out,
		r2 => mr2_out,
		output => mr_combined
	);

	as: add_sub port map(
		mr => mr_combined,
		p => mult_out,
		amf => amf,
		r0 => r0_out,
		r1 => r1_out,
		r2 => r2_out,
		mv => mv
	);

	mux7: mux2_1_8 port map(
		sel => sel(7),
		in0 => r2_out,
		in1 => dmd(7 downto 0),
		output => mux7_out
	);

	mux8: mux2_1 port map(
		sel => sel(8),
		in0 => r1_out,
		in1 => dmd,
		output => mux8_out
	);

	mux9: mux2_1 port map(
		sel => sel(9),
		in0 => r0_out,
		in1 => dmd,
		output => mux9_out
	);

	mr2: reg_8 port map(
		input => mux7_out,
		load => load(5),
		clear => reset,
		clk => clk,
		output => mr2_out
	);

	mr1: reg_16 port map(
		input => mux8_out,
		load => load(6),
		clear => reset,
		clk => clk,
		output => mr1_out
	);

	mr0: reg_16 port map(
		input => mux9_out,
		load => load(7),
		clear => reset,
		clk => clk,
		output => mr0_out
	);

	ext: extender port map(
		input => mr2_out,
		output => mr2_extended
	);

	mux10: mux3_1 port map(
		sel => sel(11 downto 10),
		in0 => mr0_out,
		in1 => mr1_out,
		in2 => mr2_extended,
		output => mux10_out
	);
	
	tri0: tristate_16 port map(
		input => mux1_out,
		enable => en(0),
		output => dmd
	);

	tri1: tristate_16 port map(
		input => mux4_out,
		enable => en(1),
		output => dmd
	);

	tri2: tristate_16 port map(
		input => mux10_out,
		enable => en(2),
		output => dmd
	);
	
	tri3: tristate_16 port map(
		input => mr2_extended,
		enable => en(3),
		output => r
	);
	
	tri4: tristate_16 port map(
		input => mr1_out,
		enable => en(4),
		output => r
	);

	tri5: tristate_16 port map(
		input => mr0_out,
		enable => en(5),
		output => r
	);

end structural;