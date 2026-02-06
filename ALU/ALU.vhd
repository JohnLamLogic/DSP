--------------------------------------------------------------------------------
-- ALU - Top Level Entity for ECE455 Project 1
-- Updated with AF_out port for Dual-Display Hardware Debugging
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ALU is
    port(
        CLK     : in    std_logic;
        Load    : in    std_logic_vector(5 downto 0); -- AX0, AX1, AY0, AY1, AF, AR
        Sel     : in    std_logic_vector(5 downto 0); -- MUX Selects
        En      : in    std_logic_vector(3 downto 0); -- Tri-state Enables
        DMD     : inout std_logic_vector(15 downto 0);-- Data Memory Data Bus
        R       : inout std_logic_vector(15 downto 0);-- Result Bus
        PMD     : in    std_logic_vector(23 downto 0);-- Program Memory Data
        AMF     : in    std_logic_vector(4 downto 0); -- Opcode
        CI      : in    std_logic;                    -- Carry In
        AZ      : out   std_logic;                    -- Zero Flag
        AN      : out   std_logic;                    -- Negative Flag
        AC      : out   std_logic;                    -- Carry Flag
        AV      : out   std_logic;                    -- Overflow Flag
        AS      : out   std_logic;                    -- Sign Flag
        alu_out : inout std_logic_vector(15 downto 0);-- AR Output
        AF_out  : out   std_logic_vector(15 downto 0) -- NEW: Physical AF Output
    );
end ALU;

architecture struct of ALU is

    -- Component Declarations
    component ALURegister
        port( D_in : in std_logic_vector(15 downto 0); load, clk : in std_logic; D_out : out std_logic_vector(15 downto 0));
    end component;

    component Multiplexer
        port( M_in1, M_in2 : in std_logic_vector(15 downto 0); Sel : in std_logic; M_out : out std_logic_vector(15 downto 0));
    end component;

    component ALUKernel
        port( X, Y : in std_logic_vector(15 downto 0); AMF : in std_logic_vector(4 downto 0); CI : in std_logic;
              R : out std_logic_vector(15 downto 0); AZ, AN, AC, AV, AS : out std_logic);
    end component;

    component TriStateBuffer
        port( T_in : in std_logic_vector(15 downto 0); En : in std_logic; T_out : out std_logic_vector(15 downto 0));
    end component;

    -- Internal Signals
    signal AX0_out, AX1_out, AY0_out, AY1_out : std_logic_vector(15 downto 0);
    signal MUX1_out, MUX2_out, MUX3_out, MUX4_out, MUX5_out : std_logic_vector(15 downto 0);
    signal ALU_result, AR_out, internal_AF_out : std_logic_vector(15 downto 0);

begin

    ---------------------------------------------------------------------------
    -- X Path Logic
    ---------------------------------------------------------------------------
    AX0_REG: ALURegister port map(DMD, Load(0), CLK, AX0_out);
    AX1_REG: ALURegister port map(DMD, Load(1), CLK, AX1_out);

    MUX1: Multiplexer port map(AX0_out, AX1_out, Sel(1), MUX1_out);
    MUX2: Multiplexer port map(MUX1_out, AR_out, Sel(2), MUX2_out);

    ---------------------------------------------------------------------------
    -- Y Path Logic
    ---------------------------------------------------------------------------
    AY0_REG: ALURegister port map(DMD, Load(2), CLK, AY0_out);
    AY1_REG: ALURegister port map(DMD, Load(3), CLK, AY1_out);

    MUX3: Multiplexer port map(AY0_out, AY1_out, Sel(3), MUX3_out);
    
    -- AF Register captures ALU Result directly
    AF_REG: ALURegister port map(ALU_result, Load(4), CLK, internal_AF_out);
    AF_out <= internal_AF_out; -- Drive the new output port

    MUX4: Multiplexer port map(MUX3_out, internal_AF_out, Sel(4), MUX4_out);

    ---------------------------------------------------------------------------
    -- Core Calculation
    ---------------------------------------------------------------------------
    ALU_CORE: ALUKernel port map(
        X => MUX2_out, Y => MUX4_out, AMF => AMF, CI => CI,
        R => ALU_result, AZ => AZ, AN => AN, AC => AC, AV => AV, AS => AS
    );

    ---------------------------------------------------------------------------
    -- Output Path Logic
    ---------------------------------------------------------------------------
    MUX5: Multiplexer port map(ALU_result, internal_AF_out, Sel(5), MUX5_out);
    
    AR_REG: ALURegister port map(MUX5_out, Load(5), CLK, AR_out);
    alu_out <= AR_out;

    -- Tri-state outputs to buses
    TSB_R:   TriStateBuffer port map(AR_out, En(3), R);
    TSB_DMD: TriStateBuffer port map(AR_out, En(1), DMD);

end struct;