library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- Counter & Count Stack functional block for the Program Sequencer.
--
-- Contains:
--   - CNTR: 14-bit unsigned down counter
--   - Count Stack: 14-bit x 4-location stack (instantiates generic stack)
--
-- Push condition: load_cntr = '1'  AND  current CNTR > 1  (old value saved)
-- Pop  condition: pop  = '1'  (issued by Stack_Controller when CE is seen)
-- CE   asserted : CNTR = 0
--
-- Connections to Stack_Controller:
--   push(0) => push      pop(0) => pop      rs(0) => rs
--   CE      <= CE        overflow(0) <= overflow   underflow(0) <= underflow
--
-- cntr_in comes from the lower 14 bits of the DMD bus.
-- load_cntr is asserted by instruction decode when a CNTR-load instruction executes.
-- decrement is asserted once per loop iteration by the sequencer.

entity counter_stack is
    port(
        clk        : in  std_logic;
        reset      : in  std_logic;                          -- active low, async
        load_cntr  : in  std_logic;                          -- load new value into CNTR
        cntr_in    : in  std_logic_vector(13 downto 0);      -- new CNTR value (from DMD bus)
        decrement  : in  std_logic;                          -- decrement CNTR each loop iter
        push       : in  std_logic;                          -- Stack_Controller push(0)
        pop        : in  std_logic;                          -- Stack_Controller pop(0)
        rs         : in  std_logic;                          -- Stack_Controller rs(0)
        CE         : out std_logic;                          -- counter expired (CNTR = 0)
        cntr_out   : out std_logic_vector(13 downto 0);      -- current CNTR value
        overflow   : out std_logic;
        underflow  : out std_logic
    );
end counter_stack;

architecture structural of counter_stack is

    -- Generic stack component (stack.vhd)
    component stack is
        generic(
            width  : integer := 14;
            height : integer := 4
        );
        port(
            clk       : in  std_logic;
            reset     : in  std_logic;
            push      : in  std_logic;
            pop       : in  std_logic;
            rs        : in  std_logic;
            data_in   : in  std_logic_vector(width-1 downto 0);
            data_out  : out std_logic_vector(width-1 downto 0);
            overflow  : out std_logic;
            underflow : out std_logic
        );
    end component;

    -- Internal CNTR register
    signal CNTR         : std_logic_vector(13 downto 0) := (others => '0');

    -- Stack interface signals
    signal stack_push   : std_logic := '0';
    signal stack_pop    : std_logic := '0';
    signal stack_din    : std_logic_vector(13 downto 0) := (others => '0');
    signal stack_dout   : std_logic_vector(13 downto 0);

    -- CE is asserted when CNTR = 0
    signal CE_internal  : std_logic;

begin

    -- Count Stack: 14 bits wide, 4 locations deep
    U_COUNT_STACK: stack
        generic map(
            width  => 14,
            height => 4
        )
        port map(
            clk       => clk,
            reset     => reset,
            push      => stack_push,
            pop       => stack_pop,
            rs        => rs,
            data_in   => stack_din,
            data_out  => stack_dout,
            overflow  => overflow,
            underflow => underflow
        );

    -- CE: counter has expired when CNTR = 0
    CE_internal <= '1' when CNTR = "00000000000000" else '0';
    CE          <= CE_internal;
    cntr_out    <= CNTR;

    -- Stack push: save old CNTR value only if old CNTR > 1 (spec requirement).
    --   Stack_Controller signals push when a CNTR-load instruction executes,
    --   but the "> 1" check must be done here since Stack_Controller cannot see CNTR.
    -- Stack pop:  restore old CNTR value when CE fires (issued by Stack_Controller)
    stack_push <= push when (CNTR > "00000000000001") else '0';
    stack_pop  <= pop;             -- Stack_Controller drives pop(0) per CE condition
    stack_din  <= CNTR;            -- the value being saved is the current (old) CNTR

    -- CNTR register process
    process(clk, reset)
    begin
        if reset = '0' then
            CNTR <= (others => '0');
        elsif rising_edge(clk) then
            if load_cntr = '1' then
                -- Load new counter value; old value was already pushed by Stack_Controller
                CNTR <= cntr_in;
            elsif pop = '1' then
                -- Stack_Controller popped the stack; restore saved CNTR value
                CNTR <= stack_dout;
            elsif decrement = '1' and CE_internal = '0' then
                -- Decrement once per loop iteration while not expired
                CNTR <= CNTR - 1;
            end if;
        end if;
    end process;

end structural;
