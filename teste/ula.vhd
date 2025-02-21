library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all;

entity ula is
    generic (WORD_SIZE : natural := 32);
    	port (
            opcode : in std_logic_vector(3 downto 0);
            A, B   : in std_logic_vector(WORD_SIZE-1 downto 0);
            Z      : out std_logic_vector(WORD_SIZE-1 downto 0));
end ula;

architecture rtl of ula is
    signal b32 : std_logic_vector(31 downto 0);
begin
    process(A, B, opcode, b32) begin
        case opcode is
            when "0000" => b32 <= std_logic_vector(signed(A) + signed(B));
            when "0001" => b32 <= std_logic_vector(signed(A) - signed(B));
            when "0010" => b32 <= A and B;
            when "0011" => b32 <= A or B;
            when "0100" => b32 <= A xor B;
            when "0101" => b32 <= std_logic_vector(shift_left(signed(A), to_integer(unsigned(B))));
            when "0110" => b32 <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B))));
            when "0111" => b32 <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B))));
            when "1000" => if (signed(A) < signed(B)) then b32 <= X"00000001"; else b32 <= X"00000000"; end if;
            when "1001" => if (unsigned(A) < unsigned(B)) then b32 <= X"00000001"; else b32 <= X"00000000"; end if;
            when "1010" => if (signed(A) >= signed(B)) then b32 <= X"00000001"; else b32 <= X"00000000"; end if;
            when "1011" => if (unsigned(A) >= unsigned(B)) then b32 <= X"00000001"; else b32 <= X"00000000"; end if;
            when "1100" => if (signed(A) = signed(B)) then b32 <= X"00000001"; else b32 <= X"00000000"; end if;
            when "1101" => if (signed(A) /= signed(B)) then b32 <= X"00000001"; else b32 <= X"00000000"; end if;
            when others => b32 <= X"00000000";
        end case;
        Z <= b32;
    end process;
end rtl;
