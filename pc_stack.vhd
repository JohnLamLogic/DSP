library ieee;
use ieee.std_logic_1164.all;

entity PC_Stack is
    port(
        Clk       : in  std_logic;
        Reset     : in  std_logic;
        Data      : in  std_logic_vector(13 downto 0);
        Push      : in  std_logic;
        Pop       : in  std_logic;
        Output    : out std_logic_vector(13 downto 0);
        Overflow  : out std_logic;
        Underflow : out std_logic
    );
end entity;

architecture rtl of PC_Stack is
begin

    U_PC_STACK : entity work.stack
    generic map(
        width  => 14,
        height => 16
    )
    port map(
        clk       => Clk,
        reset     => Reset,
        push      => Push,
        pop       => Pop,
        
        rs        => '0',       
        

        data_in   => Data,      
        data_out  => Output,   
        
        overflow  => Overflow,
        underflow => Underflow
    );
    
end architecture;