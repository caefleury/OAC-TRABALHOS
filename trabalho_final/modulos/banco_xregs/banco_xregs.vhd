library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

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
        -- saidas - ro = read output
        ro2, ro1 : out std_logic_vector(WSIZE-1 downto 0)
    );
end XREGS;

architecture behavioral of XREGS is
    -- array pros 32 regs
    type reg_array is array (0 to 31) of std_logic_vector(WSIZE-1 downto 0);
    -- zera td no inicio
    signal regs : reg_array := (others => (others => '0'));

begin
    -- logica de leitura dos regs
    -- reg0 sempre retorna 0 msm     
    ro2 <= (others => '0') when rs2 = "00000" else
                regs(to_integer(unsigned(rs2)));
           
    ro1 <= (others => '0') when rs1 = "00000" else
                regs(to_integer(unsigned(rs1)));

    -- processo de escrita - so escreve na borda de subida e com wren=1
    process(clk)begin
        if rising_edge(clk) then
            if wren = '1' then
                -- nunca escreve no reg0!!
                if rd /= "00000" then
                    regs(to_integer(unsigned(rd))) <= data;
                end if;
            end if;
        end if;
    end process;

end behavioral;