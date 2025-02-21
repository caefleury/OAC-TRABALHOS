library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all;

entity XREGS is
    generic (
        -- 32 bits padrao
        WSIZE : natural := 32
    );
    port (
        -- dados de entrada e saida
        data : in std_logic_vector(WSIZE-1 downto 0);
        -- enderecos dos regs
        rd : in std_logic_vector(4 downto 0);  -- reg destino
        rs1, rs2 : in std_logic_vector(4 downto 0);    -- regs fonte
        -- ctrl
        wren : in std_logic;
        clk : in std_logic;
        rst : in std_logic;  -- Added reset signal
        -- saidas - ro = read output
        ro2, ro1 : out std_logic_vector(WSIZE-1 downto 0)
    );
end XREGS;

architecture behavioral of XREGS is
    -- array pros 32 regs
    type reg_array is array (0 to 31) of std_logic_vector(WSIZE-1 downto 0);
    -- zera td no inicio
    signal regs : reg_array := (others => (others => '0'));

    -- Function to convert std_logic_vector to hex string
    function to_hex_string(slv: std_logic_vector) return string is
        constant hex_table: string(1 to 16) := "0123456789ABCDEF";
        variable result: string(1 to 8);  -- 32 bits = 8 hex chars
        variable temp: std_logic_vector(31 downto 0);
    begin
        temp := slv;
        for i in 0 to 7 loop
            result(8-i) := hex_table(to_integer(unsigned(temp(3 downto 0))) + 1);
            temp := "0000" & temp(31 downto 4);  -- Shift right by 4
        end loop;
        return result;
    end function;

begin
    -- logica de leitura dos regs
    -- reg0 sempre retorna 0 msm     
    ro2 <= (others => '0') when rs2 = "00000" else
                regs(to_integer(unsigned(rs2)));
           
    ro1 <= (others => '0') when rs1 = "00000" else
                regs(to_integer(unsigned(rs1)));

    -- processo de escrita - so escreve na borda de subida e com wren=1
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset all registers to 0
            regs <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if wren = '1' then
                -- nunca escreve no reg0!!
                if rd /= "00000" then
                    regs(to_integer(unsigned(rd))) <= data;
                    -- Print register value after write
                    report "Register x" & integer'image(to_integer(unsigned(rd))) & 
                           " = 0x" & to_hex_string(data);
                end if;
            end if;
        end if;
    end process;
end behavioral;