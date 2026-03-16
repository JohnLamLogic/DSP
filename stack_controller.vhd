library ieee;
use ieee.std_logic_1164.all;

entity Stack_Controller is
port(  clk,reset: IN std_logic;
       PMD: IN std_logic_vector(23 downto 0);
       CE, cond: IN std_logic;         
       add_sel: IN std_logic_vector(1 downto 0); 
       LastInst: IN std_logic;
       push, pop: OUT std_logic_vector(2 downto 0); 
       rs: OUT std_logic_vector(2 downto 0); 
       overflow: IN std_logic_vector(2 downto 0);
       underflow: IN std_logic_vector(2 downto 0)
   );
end Stack_Controller;

architecture behav of Stack_Controller is
begin
    process (clk, reset, PMD, CE, cond, add_sel, overflow, underflow, LastInst)
    begin
        push <= "000";
        pop  <= "000";
        rs   <= "000";

        if (reset = '1') then
            rs <= "111";

        elsif (PMD(23 downto 18) = "000101")
              and (overflow(2) /= '1') and (overflow(1) /= '1') then
            -- DO UNTIL: push Loop Stack and PC Stack simultaneously
            push(2) <= '1';
            push(1) <= '1';

        elsif (PMD(3 downto 0) = "1110") and (overflow(0) /= '1') then
            -- Counter-based loop setup: push Counter Stack
            push(0) <= '1';

        elsif ((PMD(23 downto 18) = "000111")
               or ((PMD(23 downto 8) = "0000101100000000")
                   and (PMD(5 downto 4) = "01")))
              and (cond = '1') then
            -- Conditional subroutine call: push PC Stack
            push(2) <= '1';

        elsif (PMD(23 downto 16) = "00001010") then
            -- Forced full stack clear (e.g. JUMP INDIRECT or RTI variant)
            pop(2) <= '1';
            pop(1) <= '1';
            pop(0) <= '1';

        elsif (PMD(23 downto 18) = "001010")
              and (underflow(2) /= '1') and (underflow(1) /= '1') then
            -- Explicit loop-stack / PC-stack return instruction
            pop(2) <= '1';
            pop(1) <= '1';

        elsif (LastInst = '1') then
            -- -------------------------------------------------------
            -- END-OF-LOOP handling.
            --
            -- BUG FIX: These two sub-conditions are now INDEPENDENT
            -- nested `if` statements, NOT `elsif` branches.
            -- Previously, if CE='1' the first branch fired and the
            -- cond branch was skipped entirely, leaving the Loop Stack
            -- and PC Stack permanently loaded when both flags were
            -- high at the same time as loop termination.
            -- -------------------------------------------------------

            -- Pop the Counter Stack when the counter has expired (CE).
            if (CE = '1') then
                pop(0) <= '1';
            end if;

            -- Pop the Loop Stack and PC Stack when the termination
            -- condition is met.  This is independent of CE so that
            -- both can fire in the same cycle if necessary.
            if (cond = '1') then
                pop(2) <= '1';
                pop(1) <= '1';
            end if;

        end if;
    end process;
end behav;
