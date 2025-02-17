library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoria is
    generic (
        WSIZE : natural := 32;  -- Word size in bits
        ADDR_SIZE : natural := 14  -- Address size in bits (14 for data, 12 for instruction)
    );
    port (
        -- Control signals
        clk     : in  std_logic;
        wren    : in  std_logic;  -- Write enable
        en      : in  std_logic;  -- Chip enable
        
        -- Byte enable signals for SW/SB/LW/LB operations
        byte_en : in  std_logic_vector(3 downto 0);
        
        -- Data and address ports
        addr    : in  std_logic_vector(ADDR_SIZE-1 downto 0);
        datain  : in  std_logic_vector(WSIZE-1 downto 0);
        dataout : out std_logic_vector(WSIZE-1 downto 0)
    );
end memoria;

architecture behavioral of memoria is
    -- Memory array type
    type mem_array is array (0 to (2**ADDR_SIZE)-1) of std_logic_vector(7 downto 0);
    signal mem : mem_array := (others => (others => '0'));
    
    -- Helper signals
    signal word_addr : integer;
    
begin
    word_addr <= to_integer(unsigned(addr));
    
    -- Read process
    process(clk, en, word_addr)
    begin
        if en = '1' then
            -- Word-aligned read
            dataout <= mem(word_addr+3) & mem(word_addr+2) & 
                      mem(word_addr+1) & mem(word_addr);
        else
            dataout <= (others => '0');
        end if;
    end process;
    
    -- Write process
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' and wren = '1' then
                -- Byte-wise write based on byte_en
                if byte_en(0) = '1' then
                    mem(word_addr) <= datain(7 downto 0);
                end if;
                if byte_en(1) = '1' then
                    mem(word_addr+1) <= datain(15 downto 8);
                end if;
                if byte_en(2) = '1' then
                    mem(word_addr+2) <= datain(23 downto 16);
                end if;
                if byte_en(3) = '1' then
                    mem(word_addr+3) <= datain(31 downto 24);
                end if;
            end if;
        end if;
    end process;
    
end behavioral;