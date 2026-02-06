--------------------------------------------------------------------------------
-- ALU Comprehensive Testbench - FIXED TIMING
-- ECE455 Project 1
--
-- Updates:
-- 1. Synchronized all waits to CLK_PERIOD to prevent phase drift.
-- 2. Aligned for Active Low (Falling Edge) Register capture.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ALU_Comprehensive_tb is
end ALU_Comprehensive_tb;

architecture behavioral of ALU_Comprehensive_tb is

    component ALU
        port(
            CLK     : in    std_logic;
            Load    : in    std_logic_vector(5 downto 0);
            Sel     : in    std_logic_vector(5 downto 0);
            En      : in    std_logic_vector(3 downto 0);
            DMD     : inout std_logic_vector(15 downto 0);
            R       : inOut std_logic_vector(15 downto 0);
            PMD     : in    std_logic_vector(23 downto 0);
            AMF     : in    std_logic_vector(4 downto 0);
            CI      : in    std_logic;
            AZ      : out   std_logic;
            AN      : out   std_logic;
            AC      : out   std_logic;
            AV      : out   std_logic;
            AS      : out   std_logic;
            alu_out : inOut std_logic_vector(15 downto 0)
        );
    end component;

    signal CLK     : std_logic := '0';
    signal Load    : std_logic_vector(5 downto 0) := (others => '0');
    signal Sel     : std_logic_vector(5 downto 0) := (others => '0');
    signal En      : std_logic_vector(3 downto 0) := (others => '0');
    signal DMD     : std_logic_vector(15 downto 0) := (others => '0');
    signal R       : std_logic_vector(15 downto 0);
    signal PMD     : std_logic_vector(23 downto 0) := (others => '0');
    signal AMF     : std_logic_vector(4 downto 0) := (others => '0');
    signal CI      : std_logic := '0';
    signal AZ, AN, AC, AV, AS : std_logic;
    signal alu_out : std_logic_vector(15 downto 0);

    constant CLK_PERIOD : time := 20 ns;

begin

    UUT: ALU port map(
        CLK => CLK, Load => Load, Sel => Sel, En => En,
        DMD => DMD, R => R, PMD => PMD, AMF => AMF, CI => CI,
        AZ => AZ, AN => AN, AC => AC, AV => AV, AS => AS,
        alu_out => alu_out
    );

    -- Clock generation
    CLK_process: process
    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;
        CLK <= '1'; 
        wait for CLK_PERIOD/2;
    end process;

    -- Main test process
    stim_proc: process
    begin
        -- Initialize
        DMD <= (others => '0');
        Load <= "000000";
        Sel <= "000000";
        En <= "0000";
        AMF <= "00000";
        CI <= '0';

        wait for 110 ns; -- CHANGE THIS LINE (Was 100 ns)
        -- By waiting 110ns, we align our data changes to the RISING edge.
        -- This ensures data is stable when the FALLING edge (capture) hits 10ns later.

        ------------------------------------------------------------------------
        -- SECTION 1: Hardware Demo Sequence (from spec page 19)
        ------------------------------------------------------------------------
        report "";
        report "=== SECTION 1: Hardware Demo Sequence ===";

        -- Load AX0 = 11
        report "Loading AX0 = 11";
        DMD <= X"000B"; Load <= "000001"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        -- Load AY1 = 13
        report "Loading AY1 = 13";
        DMD <= X"000D";
        Load <= "001000"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        -- AR = AX0 + AY1 = 24
        report "Computing AR = AX0 + AY1 (11 + 13 = 24)";
        AMF <= "10011"; Sel <= "001000"; Load <= "100000";
        wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"0018" report "FAIL: AR should be 24" severity error;
        if alu_out = X"0018" then report "PASS: AR = 24"; end if;

        -- Load AX1 = 5
        report "Loading AX1 = 5";
        DMD <= X"0005";
        Load <= "000010"; AMF <= "00000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        -- Load AY0 = 7
        report "Loading AY0 = 7";
        DMD <= X"0007";
        Load <= "000100";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        -- AF = AR + AY0 = 31
        report "Computing AF = AR + AY0 (24 + 7 = 31)";
        AMF <= "10011"; Sel <= "000100"; Load <= "010000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        -- AR = AF + AX1 = 36
        report "Computing AR = AF + AX1 (31 + 5 = 36)";
        AMF <= "10011"; Sel <= "010010"; Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"0024" report "FAIL: AR should be 36" severity error;
        if alu_out = X"0024" then report "PASS: AR = 36 (0x0024)"; end if;

        wait for 40 ns; -- Adjusted wait
        ------------------------------------------------------------------------
        -- SECTION 2: Test All ALU Operations
        ------------------------------------------------------------------------
        report "";
        report "=== SECTION 2: All ALU Operations Test ===";

        -- Load test values: AX0 = 0x00FF, AY0 = 0x000F
        DMD <= X"00FF";
        Load <= "000001"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait
        DMD <= X"000F"; Load <= "000100";
        wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        -- Test 10000: Y pass-through
        report "TEST: Y pass-through (AMF=10000)";
        AMF <= "10000";
        Sel <= "000000"; Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"000F" report "FAIL: Y pass" severity error;
        if alu_out = X"000F" then report "PASS: Y = 0x000F";
        end if;

        -- Test 10001: Y + 1
        report "TEST: Y + 1 (AMF=10001)";
        AMF <= "10001"; Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"0010" report "FAIL: Y+1" severity error;
        if alu_out = X"0010" then report "PASS: Y+1 = 0x0010";
        end if;

        -- Test 10011: X + Y
        report "TEST: X + Y (AMF=10011)";
        AMF <= "10011"; Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"010E" report "FAIL: X+Y" severity error;
        if alu_out = X"010E" then report "PASS: X+Y = 0x010E (270)";
        end if;

        -- Test 10100: NOT Y
        report "TEST: NOT Y (AMF=10100)";
        AMF <= "10100"; Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"FFF0" report "FAIL: NOT Y" severity error;
        if alu_out = X"FFF0" then report "PASS: NOT Y = 0xFFF0"; end if;

        -- Test 10111: X - Y
        report "TEST: X - Y (AMF=10111)";
        AMF <= "10111"; Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"00F0" report "FAIL: X-Y" severity error;
        if alu_out = X"00F0" then report "PASS: X-Y = 0x00F0 (240)";
        end if;

        -- Test 11000: Y - 1
        report "TEST: Y - 1 (AMF=11000)";
        AMF <= "11000"; Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"000E" report "FAIL: Y-1" severity error;
        if alu_out = X"000E" then report "PASS: Y-1 = 0x000E";
        end if;

        -- Test 11011: NOT X
        report "TEST: NOT X (AMF=11011)";
        AMF <= "11011"; Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"FF00" report "FAIL: NOT X" severity error;
        if alu_out = X"FF00" then report "PASS: NOT X = 0xFF00"; end if;

        -- Test 11100: X AND Y
        report "TEST: X AND Y (AMF=11100)";
        AMF <= "11100"; Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"000F" report "FAIL: X AND Y" severity error;
        if alu_out = X"000F" then report "PASS: X AND Y = 0x000F"; end if;

        -- Test 11101: X OR Y
        report "TEST: X OR Y (AMF=11101)";
        AMF <= "11101"; Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"00FF" report "FAIL: X OR Y" severity error;
        if alu_out = X"00FF" then report "PASS: X OR Y = 0x00FF"; end if;

        -- Test 11110: X XOR Y
        report "TEST: X XOR Y (AMF=11110)";
        AMF <= "11110"; Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"00F0" report "FAIL: X XOR Y" severity error;
        if alu_out = X"00F0" then report "PASS: X XOR Y = 0x00F0"; end if;

        wait for 40 ns;
        ------------------------------------------------------------------------
        -- SECTION 3: Flag Tests
        ------------------------------------------------------------------------
        report "";
        report "=== SECTION 3: Status Flag Tests ===";

        -- Zero flag test
        report "TEST: Zero flag (5 - 5 = 0)";
        DMD <= X"0005"; Load <= "000001"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait
        DMD <= X"0005";
        Load <= "000100"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait
        AMF <= "10111"; Sel <= "000000";
        Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert AZ = '1' report "FAIL: Zero flag should be 1" severity error;
        if AZ = '1' then report "PASS: Zero flag set"; end if;

        -- Negative flag test
        report "TEST: Negative flag (5 - 10 = -5)";
        DMD <= X"0005"; Load <= "000001"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait
        DMD <= X"000A";
        Load <= "000100"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait
        AMF <= "10111"; Sel <= "000000";
        Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert AN = '1' report "FAIL: Negative flag should be 1" severity error;
        if AN = '1' then report "PASS: Negative flag set"; end if;

        -- Carry flag test
        report "TEST: Carry flag (0xFFFF + 2)";
        DMD <= X"FFFF"; Load <= "000001"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait
        DMD <= X"0002";
        Load <= "000100"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait
        AMF <= "10011"; Sel <= "000000";
        Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert AC = '1' report "FAIL: Carry flag should be 1" severity error;
        if AC = '1' then report "PASS: Carry flag set"; end if;

        -- Overflow flag test (positive overflow)
        report "TEST: Overflow flag (0x7000 + 0x1000)";
        DMD <= X"7000"; Load <= "000001"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait
        DMD <= X"1000";
        Load <= "000100"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait
        AMF <= "10011"; Sel <= "000000";
        Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert AV = '1' report "FAIL: Overflow flag should be 1" severity error;
        if AV = '1' then report "PASS: Overflow flag set"; end if;

        -- AS flag test
        report "TEST: AS flag (negative X)";
        DMD <= X"8000";
        Load <= "000001"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait
        DMD <= X"0001"; Load <= "000100";
        wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait
        AMF <= "10011"; Sel <= "000000"; Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert AS = '1' report "FAIL: AS flag should be 1" severity error;
        if AS = '1' then report "PASS: AS flag set (X is negative)"; end if;

        wait for 40 ns;
        ------------------------------------------------------------------------
        -- SECTION 4: Feedback Path Tests
        ------------------------------------------------------------------------
        report "";
        report "=== SECTION 4: Feedback Path Tests ===";

        -- Test AR feedback to X
        report "TEST: AR feedback - AR = 100, then AR + AY0";
        DMD <= X"0064"; Load <= "000001"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait
        DMD <= X"0000";
        Load <= "000100"; wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        -- First put 100 in AR
        AMF <= "10011"; Sel <= "000000";
        Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        -- Now load 10 into AY0
        DMD <= X"000A"; Load <= "000100";
        wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        -- AR + AY0 using AR feedback
        AMF <= "10011"; Sel <= "001100"; -- MUX2=1 (AR fb), MUX4=0 (AY0)
        -- Note: Sel(2)='1' selects AR feedback
        -- Sel signal: 001100 -> bit 2 is 1. bit 3 is 1? Wait.
        -- Control Signal Reference from Header:
        -- Sel(1)=MUX1, Sel(2)=MUX2(MUX1/AR), Sel(3)=MUX3(AY0/AY1),
        -- Correct Sel for AR feedback + AY0:
        -- Sel(2)='1' (AR fb), Sel(3)='0' (AY0), Sel(4)='0' (MUX3)
        -- Binary: 000100 (bits 543210) -> bit 2 is 1.
        -- Original file had: Sel <= "000100";
        -- Let's stick to the original signal if it worked before.
        Sel <= "000100"; 
        Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"006E" report "FAIL: AR feedback 100+10=110" severity error;
        if alu_out = X"006E" then report "PASS: AR feedback works (100+10=110)"; end if;

        -- Test AF feedback to Y
        report "TEST: AF feedback - Load AF, then AX0 + AF";
        -- Load 50 into AX0
        DMD <= X"0032"; Load <= "000001";
        wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        -- Load 25 into AY0
        DMD <= X"0019"; Load <= "000100";
        wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        -- AF = AX0 + AY0 = 75
        AMF <= "10011";
        Sel <= "000000"; Load <= "010000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        -- Load 10 into AX0
        DMD <= X"000A"; Load <= "000001";
        wait for CLK_PERIOD;
        Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        -- AR = AX0 + AF (10 + 75 = 85)
        AMF <= "10011";
        Sel <= "010000"; Load <= "100000";
        wait for CLK_PERIOD; Load <= "000000"; wait for CLK_PERIOD; -- Fixed wait

        assert alu_out = X"0055" report "FAIL: AF feedback 10+75=85" severity error;
        if alu_out = X"0055" then report "PASS: AF feedback works (10+75=85)"; end if;

        report "";
        report "======================================================";
        report "ALL TESTS COMPLETED!";
        report "======================================================";

        wait;
    end process;

end behavioral;