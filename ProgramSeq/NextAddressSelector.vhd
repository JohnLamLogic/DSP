library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity next_address_Selector is 
    port (
        Inst      : IN std_logic_vector(23 downto 0);
        cond      : IN std_logic;
        LastInst  : IN std_logic;
        rs        : IN std_logic;
        add_sel   : OUT std_logic_vector(1 downto 0);
        Clk       : IN std_logic -- (We leave the port here so it doesn't break your top-level wiring, but we just won't use it)
    );
end next_address_Selector;

architecture behav of next_address_Selector is 
begin
    process (rs, Inst, cond, LastInst)
begin
    if (rs = '1') then
        add_sel <= "00";
        
    elsif (LastInst = '1') then          -- << MOVED BEFORE opcode decode
        if (cond = '1') then
            add_sel <= "10";             -- Condition met: break loop, increment PC
        else
            add_sel <= "01";             -- Condition not met: loop back via PC Stack
        end if;
        
    elsif (Inst(23 downto 19) = "00011") then  -- Conditional Jump/Call (now safe)
        if (cond = '1') then
            add_sel <= "11";
        else
            add_sel <= "10";
        end if;
        
    else
        add_sel <= "10";
    end if;
end process;
end behav;
