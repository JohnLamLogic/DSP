library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Program_Sequencer is
    port(
        Clk          : in  std_logic;
        Reset        : in  std_logic;
        Inst_in      : in  std_logic_vector(23 downto 0); -- From Program Memory
        
        -- ALU Flags (for the Status Register)
        flag_AZ      : in  std_logic;
        flag_AN      : in  std_logic;
        flag_AV      : in  std_logic;
        flag_AC      : in  std_logic;
        flag_AS      : in  std_logic;
        
        -- Counter Stack Control (from Data Memory / Decode)
        load_cntr    : in  std_logic;
        cntr_in      : in  std_logic_vector(13 downto 0);
        decrement    : in  std_logic;
        
        -- Outputs
        PMA_bus      : out std_logic_vector(13 downto 0); -- To Program Memory
        cntr_out     : out std_logic_vector(13 downto 0)  -- To Data Memory
    );
end Program_Sequencer;

architecture structural of Program_Sequencer is
	signal reset_n: std_logic;
    -- 1. Program Counter & Routing Wires
    signal current_pc_wire  : std_logic_vector(13 downto 0);
    signal inc_pc_wire      : std_logic_vector(13 downto 0);
    signal mux_out_wire     : std_logic_vector(13 downto 0);
    signal add_sel_wire     : std_logic_vector(1 downto 0);
    
    -- 2. Condition & Status Wires
    signal astat_out_wire   : std_logic_vector(6 downto 0);
    signal cond_wire        : std_logic;
    signal last_inst_wire   : std_logic;
    signal s_control_wire   : std_logic;
    signal ce_wire          : std_logic;
    
    -- 3. Loop Wires
    signal loop_cond_wire   : std_logic_vector(3 downto 0);
    signal loop_end_addr    : std_logic_vector(13 downto 0);
    
    -- 4. Stack Controller Wires (Index: 0=Counter, 1=PC, 2=Loop)
    signal push_wire        : std_logic_vector(2 downto 0);
    signal pop_wire         : std_logic_vector(2 downto 0);
    signal rs_wire          : std_logic_vector(2 downto 0);
    signal overflow_wire    : std_logic_vector(2 downto 0);
    signal underflow_wire   : std_logic_vector(2 downto 0);
    
    -- 5. PC Stack Wires
    signal pc_stack_out_wire: std_logic_vector(13 downto 0);

begin
	reset_n <= not Reset;
    -- ==========================================
    -- A. ROUTING & LOGIC BLOCKS
    -- ==========================================

    -- 1. Next Address Selector (The Brain)
    U_SELECTOR: entity work.next_address_Selector
    port map(
        Inst     => Inst_in,
        cond     => cond_wire,
        LastInst => last_inst_wire,
        rs       => Reset,
        Clk      => Clk,
        add_sel  => add_sel_wire
    );

    -- 2. Next Address MUX (The Switch)
    U_MUX: entity work.NextAddressMUX
    port map(
        sel          => add_sel_wire,
        inc_pc       => inc_pc_wire,
        jump_addr    => Inst_in(13 downto 0),
        pc_stack_out => pc_stack_out_wire,
        mux_out      => mux_out_wire
    );

    -- 3. Program Counter & Incrementer
    U_PC: entity work.Program_Counter
    port map(
        Clk   => Clk,
        Reset => Reset,
        D     => mux_out_wire,
        Q     => current_pc_wire
    );

    U_INC: entity work.PC_Incrementer
    port map(
        PC_in   => current_pc_wire,
        PC_plus => inc_pc_wire
    );

    -- ==========================================
    -- B. CONDITIONS & LOOP CONTROL
    -- ==========================================

    -- 4. Status Register (From our previous discussion)
    U_STATUS_REG: entity work.Status_Register
    port map(
        Clk       => Clk,
        rs        => Reset,
        flag_AZ   => flag_AZ,
        flag_AN   => flag_AN,
        flag_AV   => flag_AV,
        flag_AC   => flag_AC,
        flag_AS   => flag_AS,
        astat_out => astat_out_wire
    );

    -- 5. Condition Logic
    -- 's' is the inverse of last_inst. If we are at the end of a loop, check loop_cond instead!
    s_control_wire <= not last_inst_wire; 

    U_COND_LOGIC: entity work.Condition_Logic
    port map(
        cond_code => Inst_in(3 downto 0),
        loop_cond => loop_cond_wire,
        status    => astat_out_wire,
        CE        => ce_wire,
        s         => s_control_wire,
        cond      => cond_wire
    );

    -- 6. Loop Comparator
    U_LOOP_COMP: entity work.loop_comparator
    port map(
        stack_data_out => loop_end_addr,
        next_pc        => inc_pc_wire, -- Compares against current PC to trigger right away
        stack_empty    => underflow_wire(2),             -- Tied to 0 (assume stack is valid when running loops)
        lastinst       => last_inst_wire
    );

    -- ==========================================
    -- C. STACKS & STACK CONTROLLER
    -- ==========================================

    -- 7. Stack Controller
    U_STACK_CTRL: entity work.Stack_Controller
    port map(
        clk       => Clk,
        reset     => Reset,
        PMD       => Inst_in,
        CE        => ce_wire,
        cond      => cond_wire,
        add_sel   => add_sel_wire,
	LastInst => last_inst_wire,
        push      => push_wire,
        pop       => pop_wire,
        rs        => rs_wire,
        overflow  => overflow_wire,
        underflow => underflow_wire
    );

    -- 8. PC Stack (Index 1)
    U_PC_STACK: entity work.PC_Stack
    port map(
        Clk       => Clk,
        Reset     => reset_n,
        Data      => inc_pc_wire, -- Pushes current PC (Return address)
        Push      => push_wire(1),
        Pop       => pop_wire(1),
        Output    => pc_stack_out_wire,
        Overflow  => overflow_wire(1),
        Underflow => underflow_wire(1)
    );

    -- 9. Loop Stack (Index 2)
    U_LOOP_STACK: entity work.loop_stack
    port map(
        clk           => Clk,
        reset         => reset_n,
        push          => push_wire(2),
        pop           => pop_wire(2),
        rs            => rs_wire(2),
        data_in       => Inst_in(17 downto 0), -- Address and Cond from instruction
        loop_cond     => loop_cond_wire,
        loop_end_addr => loop_end_addr,
        overflow      => overflow_wire(2),
        underflow     => underflow_wire(2)
    );

    -- 10. Counter Stack (Index 0)
    U_COUNTER_STACK: entity work.counter_stack
    port map(
        clk       => Clk,
        reset     => reset_n,
        load_cntr => load_cntr,
        cntr_in   => cntr_in,
        decrement => decrement,
        cntr_out  => cntr_out,
        CE        => ce_wire,
        push      => push_wire(0),
        pop       => pop_wire(0),
        rs        => rs_wire(0),
        overflow  => overflow_wire(0),
        underflow => underflow_wire(0)
    );

    -- ==========================================
    -- D. FINAL OUTPUTS
    -- ==========================================
    PMA_bus <= current_pc_wire;

end structural;
