
library ieee;
use ieee.std_logic_1164.all;

entity tb_loop_stack is
-- Testbenches do not have ports
end tb_loop_stack;

architecture behavior of tb_loop_stack is

    -- 1. Declare the Loop Stack component
    component loop_stack
        port(
            clk           : in  std_logic;
            reset         : in  std_logic;
            push          : in  std_logic;
            pop           : in  std_logic;
            rs            : in  std_logic;
            data_in       : in  std_logic_vector(17 downto 0);
            
            loop_cond     : out std_logic_vector(3 downto 0);
            loop_end_addr : out std_logic_vector(13 downto 0);
            overflow      : out std_logic;
            underflow     : out std_logic
        );
    end component;

    -- 2. Internal signals for the testbench
    signal clk           : std_logic := '0';
    signal reset         : std_logic := '0';
    signal push          : std_logic := '0';
    signal pop           : std_logic := '0';
    signal rs            : std_logic := '0';
    signal data_in       : std_logic_vector(17 downto 0) := (others => '0');
    
    signal loop_cond     : std_logic_vector(3 downto 0);
    signal loop_end_addr : std_logic_vector(13 downto 0);
    signal overflow      : std_logic;
    signal underflow     : std_logic;

    -- Define the clock period
    constant clk_period : time := 10 ns;

begin

    -- 3. Instantiate the Unit Under Test (UUT)
    UUT: loop_stack port map (
        clk           => clk,
        reset         => reset,
        push          => push,
        pop           => pop,
        rs            => rs,
        data_in       => data_in,
        loop_cond     => loop_cond,
        loop_end_addr => loop_end_addr,
        overflow      => overflow,
        underflow     => underflow
    );

    -- 4. Clock Generation Process
    -- This toggles the clock up and down forever
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- 5. Stimulus Process (The actual test sequence)
    stim_proc: process
    begin
        -- =====================================================
        -- INITIALIZATION & RESET
        -- =====================================================
        reset <= '0'; -- Active low reset
        wait for clk_period * 2;
        reset <= '1'; -- Release reset
        wait for clk_period;

        -- =====================================================
        -- TEST CASE 1: Push First Loop 
        -- Condition: "1010" (Hex A) | Address: "00000000001111" (Hex 000F)
        -- =====================================================
        push    <= '1';
        data_in <= "1010" & "00000000001111"; -- '&' glues the bits together into 18 bits
        wait for clk_period;
        push    <= '0'; 
        wait for clk_period;

        -- =====================================================
        -- TEST CASE 2: Push Second (Inner) Loop
        -- Condition: "0011" (Hex 3) | Address: "11111111111111" (Hex 3FFF)
        -- =====================================================
        push    <= '1';
        data_in <= "0011" & "11111111111111"; 
        wait for clk_period;
        push    <= '0';
        wait for clk_period * 2;

        -- =====================================================
        -- TEST CASE 3: Pop the Inner Loop
        -- EXPECTED: The outputs should instantly drop back down to 
        -- showing Condition "1010" and Address "00000000001111"
        -- =====================================================
        pop <= '1';
        wait for clk_period;
        pop <= '0';
        wait for clk_period * 2;

        -- =====================================================
        -- TEST CASE 4: Synchronous Clear (rs)
        -- EXPECTED: Wipes the remaining loop, underflow should hit '1'
        -- =====================================================
        rs <= '1';
        wait for clk_period;
        rs <= '0';
        wait for clk_period * 2;

        -- End the simulation
        wait;
    end process;

end behavior;