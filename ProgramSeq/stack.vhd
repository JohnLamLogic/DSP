library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- Generic parameterized stack.
-- Used by all four stacks in the Program Sequencer:
--   PC Stack:     generic map(14, 16)
--   Loop Stack:   generic map(18, 4)
--   Count Stack:  generic map(14, 4)
--   Status Stack: generic map(14, 4)  (or as needed)
entity stack is
    generic(
        width  : integer := 14;
        height : integer := 4
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
end stack;

architecture behavioral of stack is

    type stack_array is array(0 to height-1) of std_logic_vector(width-1 downto 0);

    signal mem : stack_array;
    signal sp  : integer range 0 to height := 0;  -- points to next empty slot

begin

    -- Combinational read: top of stack is mem(sp-1)
    data_out  <= mem(sp-1) when (sp > 0) else (others => '0');
    overflow  <= '1' when (sp = height) else '0';
    underflow <= '1' when (sp = 0)      else '0';

    process(clk, reset)
    begin
        if reset = '0' then
            sp  <= 0;
            mem <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if rs = '1' then
                sp  <= 0;
                mem <= (others => (others => '0'));
            elsif push = '1' and pop = '0' then
                if sp < height then
                    mem(sp) <= data_in;
                    sp      <= sp + 1;
                end if;
                -- if sp = height, overflow is already asserted; no write
            elsif pop = '1' and push = '0' then
                if sp > 0 then
                    sp <= sp - 1;
                end if;
                -- if sp = 0, underflow is already asserted; no change
            end if;
            -- simultaneous push and pop: treated as no-op
        end if;
    end process;

end behavioral;
