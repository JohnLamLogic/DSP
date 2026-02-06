--------------------------------------------------------------------------------
-- ALU Kernel - Core computational unit for ECE455 Project 1
-- Performs 16 arithmetic and logic operations based on 5-bit AMF opcode
--
-- Operations (AMF encoding from spec page 6):
-- 10000: Y              (Clear when Y=0)
-- 10001: Y + 1          (PASS 1 when Y=0)
-- 10010: X + Y + C      (Add with carry)
-- 10011: X + Y          (X when Y=0)
-- 10100: NOT Y
-- 10101: -Y             (Negate Y)
-- 10110: X - Y + C - 1  (X + C - 1 when Y=0)
-- 10111: X - Y
-- 11000: Y - 1          (PASS -1 when Y=0)
-- 11001: Y - X          (-X when Y=0)
-- 11010: Y - X + C - 1  (-X + C - 1 when Y=0)
-- 11011: NOT X
-- 11100: X AND Y
-- 11101: X OR Y
-- 11110: X XOR Y
-- 11111: ABS X
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ALUKernel is
    port(
        X   : in  std_logic_vector(15 downto 0);  -- X operand input
        Y   : in  std_logic_vector(15 downto 0);  -- Y operand input
        CI  : in  std_logic;                      -- Carry in
        AMF : in  std_logic_vector(4 downto 0);   -- Operation code
        R   : out std_logic_vector(15 downto 0);  -- Result output
        AZ  : out std_logic;                      -- Zero flag
        AN  : out std_logic;                      -- Negative flag
        AC  : out std_logic;                      -- Carry flag
        AV  : out std_logic;                      -- Overflow flag
        AS  : out std_logic                       -- X sign flag
    );
end ALUKernel;

architecture behavioral of ALUKernel is
    signal result_int   : std_logic_vector(15 downto 0);
    signal carry_int    : std_logic;
    signal overflow_int : std_logic;
begin

    -- Combinational ALU operation process
    process(X, Y, CI, AMF)
        variable temp_result   : std_logic_vector(16 downto 0);  -- 17-bit for carry
        variable temp_carry    : std_logic;
        variable temp_overflow : std_logic;
        variable ci_ext        : std_logic_vector(16 downto 0);
    begin
        -- Default values
        temp_carry := '0';
        temp_overflow := '0';
        temp_result := (others => '0');

        -- Extend carry in for addition
        ci_ext := (others => '0');
        if CI = '1' then
            ci_ext(0) := '1';
        end if;

        case AMF is
            -- 10000: Y (Pass Y, Clear when Y=0)
            when "10000" =>
                temp_result := '0' & Y;
                -- No carry or overflow for pass-through

            -- 10001: Y + 1 (Increment Y)
            when "10001" =>
                temp_result := ('0' & Y) + 1;
                temp_carry := temp_result(16);
                -- Overflow if Y was max positive (0x7FFF) and became negative
                temp_overflow := (not Y(15)) and temp_result(15);

            -- 10010: X + Y + C (Add with carry)
            when "10010" =>
                temp_result := ('0' & X) + ('0' & Y) + ci_ext;
                temp_carry := temp_result(16);
                -- Overflow: same sign inputs, different sign result
                temp_overflow := (X(15) xnor Y(15)) and (X(15) xor temp_result(15));

            -- 10011: X + Y (Add)
            when "10011" =>
                temp_result := ('0' & X) + ('0' & Y);
                temp_carry := temp_result(16);
                -- Overflow: same sign inputs, different sign result
                temp_overflow := (X(15) xnor Y(15)) and (X(15) xor temp_result(15));

            -- 10100: NOT Y
            when "10100" =>
                temp_result := '0' & (not Y);
                -- No carry or overflow for logic operations

            -- 10101: -Y (Negate Y = NOT Y + 1)
            when "10101" =>
                temp_result := ('0' & (not Y)) + 1;
                temp_carry := temp_result(16);
                -- Overflow only if Y = 0x8000 (most negative number)
                if Y = X"8000" then
                    temp_overflow := '1';
                else
                    temp_overflow := '0';
                end if;

            -- 10110: X - Y + C - 1 (Subtract with borrow)
            -- Equivalent to X + NOT(Y) + C
            when "10110" =>
                temp_result := ('0' & X) + ('0' & (not Y)) + ci_ext;
                temp_carry := temp_result(16);
                -- Overflow for subtraction: different sign inputs, result sign differs from X
                temp_overflow := (X(15) xor Y(15)) and (X(15) xor temp_result(15));

            -- 10111: X - Y (Subtract)
            -- Equivalent to X + NOT(Y) + 1
            when "10111" =>
                temp_result := ('0' & X) + ('0' & (not Y)) + 1;
                temp_carry := temp_result(16);
                -- Overflow for subtraction
                temp_overflow := (X(15) xor Y(15)) and (X(15) xor temp_result(15));

            -- 11000: Y - 1 (Decrement Y)
            when "11000" =>
                temp_result := ('0' & Y) - 1;  -- Y - 1
                temp_carry := temp_result(16);
                -- Overflow if Y was min negative (0x8000) and became positive
                temp_overflow := Y(15) and (not temp_result(15));

            -- 11001: Y - X (Reverse subtract)
            -- Equivalent to Y + NOT(X) + 1
            when "11001" =>
                temp_result := ('0' & Y) + ('0' & (not X)) + 1;
                temp_carry := temp_result(16);
                -- Overflow for Y - X
                temp_overflow := (Y(15) xor X(15)) and (Y(15) xor temp_result(15));

            -- 11010: Y - X + C - 1 (Reverse subtract with borrow)
            -- Equivalent to Y + NOT(X) + C
            when "11010" =>
                temp_result := ('0' & Y) + ('0' & (not X)) + ci_ext;
                temp_carry := temp_result(16);
                -- Overflow for Y - X with borrow
                temp_overflow := (Y(15) xor X(15)) and (Y(15) xor temp_result(15));

            -- 11011: NOT X
            when "11011" =>
                temp_result := '0' & (not X);
                -- No carry or overflow for logic operations

            -- 11100: X AND Y
            when "11100" =>
                temp_result := '0' & (X and Y);
                -- No carry or overflow for logic operations

            -- 11101: X OR Y
            when "11101" =>
                temp_result := '0' & (X or Y);
                -- No carry or overflow for logic operations

            -- 11110: X XOR Y
            when "11110" =>
                temp_result := '0' & (X xor Y);
                -- No carry or overflow for logic operations

            -- 11111: ABS X (Absolute value of X)
            when "11111" =>
                if X(15) = '1' then
                    -- X is negative, negate it
                    temp_result := ('0' & (not X)) + 1;
                    -- Overflow if X = 0x8000
                    if X = X"8000" then
                        temp_overflow := '1';
                    end if;
                else
                    -- X is positive, pass through
                    temp_result := '0' & X;
                end if;

            -- Default case (invalid opcode)
            when others =>
                temp_result := (others => '0');
        end case;

        -- Assign to internal signals
        result_int <= temp_result(15 downto 0);
        carry_int <= temp_carry;
        overflow_int <= temp_overflow;
    end process;

    -- Output assignments (active high flags)
    R  <= result_int;
    AZ <= '1' when result_int = X"0000" else '0';  -- Zero flag
    AN <= result_int(15);                           -- Negative flag (MSB)
    AC <= carry_int;                                -- Carry flag
    AV <= overflow_int;                             -- Overflow flag
    AS <= X(15);                                    -- X sign flag (always reflects X input sign)

end behavioral;

