library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_Program_Sequencer is
-- Testbenches have no ports!
end tb_Program_Sequencer;

architecture behavior of tb_Program_Sequencer is

    -- 1. Signals to connect to the Top-Level UUT
    signal Clk          : std_logic := '0';
    signal Reset        : std_logic := '1';
    signal Inst_in      : std_logic_vector(23 downto 0) := (others => '0');
    
    signal flag_AZ      : std_logic := '0';
    signal flag_AN      : std_logic := '0';
    signal flag_AV      : std_logic := '0';
    signal flag_AC      : std_logic := '0';
    signal flag_AS      : std_logic := '0';
    
    signal load_cntr    : std_logic := '0';
    signal cntr_in      : std_logic_vector(13 downto 0) := (others => '0');
    signal decrement    : std_logic := '0';
    
    signal PMA_bus      : std_logic_vector(13 downto 0);
    signal cntr_out     : std_logic_vector(13 downto 0);

    -- Clock period definition
    constant CLK_PERIOD : time := 20 ns;

begin

    -- 2. Instantiate the Top-Level Design
    UUT: entity work.Program_Sequencer
    port map(
        Clk          => Clk,
        Reset        => Reset,
        Inst_in      => Inst_in,
        
        flag_AZ      => flag_AZ,
        flag_AN      => flag_AN,
        flag_AV      => flag_AV,
        flag_AC      => flag_AC,
        flag_AS      => flag_AS,
        
        load_cntr    => load_cntr,
        cntr_in      => cntr_in,
        decrement    => decrement,
        
        PMA_bus      => PMA_bus,
        cntr_out     => cntr_out
    );

    -- 3. Clock Generation Process
    clk_process : process
    begin
        Clk <= '0';
        wait for CLK_PERIOD/2;
        Clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- 4. Simulated Program Memory (ROM) Process
    rom_process : process(PMA_bus)
    begin
        case PMA_bus is
            when "00000000000000" => Inst_in <= "010000000000000000100000"; -- PC=0
            when "00000000000001" => Inst_in <= "010000000000000000110101"; -- PC=1
            when "00000000000010" => Inst_in <= "010000000000000001000010"; -- PC=2
            when "00000000000011" => Inst_in <= "010000000000000000100111"; -- PC=3
            when "00000000000100" => Inst_in <= "001001100010100000001111"; -- PC=4
            when "00000000000101" => Inst_in <= "001010100110100010100000"; -- PC=5
            when "00000000000110" => Inst_in <= "001010000010100010110000"; -- PC=6
            
            when "00000000000111" => 
                -- PC = 7: DO UNTIL Instruction
                -- Opcode (000101) & Cond EQ (0001) & Address 11 (00000000001011)
                Inst_in <= "000101000100000000001011"; 
                
            -- LOOP BODY (PC 8 through 11)
            when "00000000001000" => Inst_in <= "001001100011000000001111"; -- PC=8
            when "00000000001001" => Inst_in <= "001001100011000000001111"; -- PC=9
            when "00000000001010" => Inst_in <= "001001100011000000001111"; -- PC=10
            when "00000000001011" => Inst_in <= "001001100011000000001111"; -- PC=11: End of Loop
                
            when "00000000001100" =>
                -- PC = 12: Instruction AFTER the loop
                Inst_in <= "010000000000000000100000"; 
                
            when others =>
                Inst_in <= (others => '0'); -- Default to NOP
        end case;
    end process;

    -- 5. Main Test Stimulus Process
    stim_proc: process
    begin		
        -- Step A: Hold reset high to clear the PC and Stacks
        Reset <= '1';
        flag_AZ <= '0';
        flag_AN <= '0';
        flag_AV <= '0';
        flag_AC <= '0';
        flag_AS <= '0';
        wait for 45 ns;	
        
        -- Step B: Release reset. PC will start counting from 0.
        Reset <= '0';
        
        -- Step C: Wait dynamically! The testbench will freeze here and 
        -- monitor the PMA_bus until it exactly matches Address 7.
        -- Step C: Wait for the DO UNTIL to execute
wait until PMA_bus = "00000000000111"; -- PC=7 (DO UNTIL)
wait for CLK_PERIOD;

-- Let 2 full iterations pass with AZ=0 (condition NOT met ? loop back)
wait until PMA_bus = "00000000001010"; -- FIXED: first time at PC=10 (LastInst fires here)
wait for CLK_PERIOD;
wait until PMA_bus = "00000000001010"; -- FIXED: second time at PC=10
wait for CLK_PERIOD;

-- Now assert AZ=1 so the THIRD pass triggers the exit
flag_AZ <= '1';

wait;
    end process;

end behavior;
