library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ALU_Board_Top is
    port(
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(3 downto 0); 
        SW       : in  std_logic_vector(9 downto 0); 
        HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(6 downto 0);
        LEDR     : out std_logic_vector(9 downto 0)
    );
end ALU_Board_Top;

architecture structural of ALU_Board_Top is

    signal ALU_CLK  : std_logic;
    signal Load, Sel : std_logic_vector(5 downto 0);
    signal En       : std_logic_vector(3 downto 0);
    signal AMF      : std_logic_vector(4 downto 0);
    signal DMD_out, DMD_in, alu_out : std_logic_vector(15 downto 0);
    signal af_val   : std_logic_vector(15 downto 0); 
    signal AZ, AN, AC, AV, AS : std_logic;
    
    type state_type is (
        S_INIT, S_LOAD_AX0, S_WAIT1, S_LOAD_AY1, S_WAIT2, S_CALC_AR, S_WAIT3,
        S_LOAD_AX1, S_WAIT4, S_LOAD_AY0, S_WAIT5, S_CALC_AF, S_WAIT6, S_CALC_FINAL, S_DONE
    );
    signal current_state : state_type := S_INIT;

    component ALU
        port( CLK, CI : in std_logic; Load, Sel : in std_logic_vector(5 downto 0);
              En : in std_logic_vector(3 downto 0); PMD : in std_logic_vector(23 downto 0);
              AMF : in std_logic_vector(4 downto 0); DMD, R : inout std_logic_vector(15 downto 0);
              AZ, AN, AC, AV, AS : out std_logic; alu_out : inout std_logic_vector(15 downto 0);
              AF_out : out std_logic_vector(15 downto 0)); 
    end component;

    component Display_Circuit
        port(Input : in std_logic_vector(3 downto 0); segmentSeven : out std_logic_vector(6 downto 0));
    end component;

begin
    ALU_CLK <= KEY(0); 

    U_ALU: ALU port map(
        CLK => ALU_CLK, CI => '0', PMD => (others => '0'), R => open,
        Load => Load, Sel => Sel, En => En, AMF => AMF,
        DMD => DMD_out, AZ => AZ, AN => AN, AC => AC, AV => AV, AS => AS, 
        alu_out => alu_out, AF_out => af_val
    );
    
    DMD_out <= DMD_in when (En(0) = '0') else (others => 'Z');

    -- State Machine (Hardware Demo Sequence)
    process(ALU_CLK, KEY(1))
    begin
        if KEY(1) = '0' then current_state <= S_INIT;
        elsif rising_edge(ALU_CLK) then
            case current_state is
                when S_INIT => current_state <= S_LOAD_AX0;
                when S_LOAD_AX0 => current_state <= S_WAIT1;
                when S_WAIT1 => current_state <= S_LOAD_AY1;
                when S_LOAD_AY1 => current_state <= S_WAIT2;
                when S_WAIT2 => current_state <= S_CALC_AR;
                when S_CALC_AR => current_state <= S_WAIT3;
                when S_WAIT3 => current_state <= S_LOAD_AX1;
                when S_LOAD_AX1 => current_state <= S_WAIT4;
                when S_WAIT4 => current_state <= S_LOAD_AY0;
                when S_LOAD_AY0 => current_state <= S_WAIT5;
                when S_WAIT5 => current_state <= S_CALC_AF;
                when S_CALC_AF => current_state <= S_WAIT6;
                when S_WAIT6 => current_state <= S_CALC_FINAL;
                when S_CALC_FINAL => current_state <= S_DONE;
                when others => current_state <= S_DONE;
            end case;
        end if;
    end process;

    process(current_state)
    begin
        Load <= "000000"; Sel <= "000000"; En <= "0000"; AMF <= "00000"; DMD_in <= (others => '0');
        case current_state is
            when S_LOAD_AX0 => DMD_in <= X"000B"; Load <= "000001";
            when S_LOAD_AY1 => DMD_in <= X"000D"; Load <= "001000";
            when S_CALC_AR  => AMF <= "10011"; Sel <= "001000"; Load <= "100000";
            when S_LOAD_AX1 => DMD_in <= X"0005"; Load <= "000010";
            when S_LOAD_AY0 => DMD_in <= X"0007"; Load <= "000100";
            when S_CALC_AF  => AMF <= "10011"; Sel <= "000100"; Load <= "010000";
            when S_CALC_FINAL => AMF <= "10011"; Sel <= "010010"; Load <= "100000";
            when others => null;
        end case;
    end process;

    ---------------------------------------------------------------------------
    -- DUAL DISPLAY LOGIC
    ---------------------------------------------------------------------------
    -- HEX 3 & 2: Show AF (Feedback) lower 8 bits
    HEX_3_inst: Display_Circuit port map(af_val(7 downto 4), HEX3);
    HEX_2_inst: Display_Circuit port map(af_val(3 downto 0), HEX2);

    -- HEX 1 & 0: Show AR (Result/alu_out) lower 8 bits
    HEX_1_inst: Display_Circuit port map(alu_out(7 downto 4), HEX1);
    HEX_0_inst: Display_Circuit port map(alu_out(3 downto 0), HEX0);

    LEDR(0) <= AZ; LEDR(1) <= AN; LEDR(2) <= AC; LEDR(3) <= AV; LEDR(4) <= AS;
    LEDR(9 downto 5) <= (others => '0');
end structural;