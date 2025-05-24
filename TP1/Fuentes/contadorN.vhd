-- TP 1
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Contador generico de N bits con señal del carga
entity counterN is
    generic(
        N : natural := 8
    );
    port(
        rst             : in std_logic;
        clk             : in std_logic;
        load            : in std_logic;
        val             : in std_logic_vector(N-1 downto 0);
        count           : out std_logic_vector(N-1 downto 0);
        seg_30_count    : out std_logic;
        seg_3_count     : out std_logic
    );
end counterN;

architecture behavioral of counterN is

    constant N30_SEG : natural := 1499999999;
    constant N3_SEG : natural := 149999999;
     
    signal  aux_count : unsigned(N-1 downto 0);
    
begin
    
    process(clk,rst)
    begin
        if rst = '1' then
            aux_count <= (others => '0');
        elsif clk = '1' and clk'event then
            if load = '1' then
                aux_count <= unsigned(val);
            else
                aux_count <= aux_count + 1;
            end if;
        end if;
    end process;
    
    count <= std_logic_vector(aux_count);
    
    seg_30_count <= '1' when (aux_count = N30_SEG) else '0';
    
    seg_3_count <= '1' when (aux_count = N3_SEG) else '0';
    

end behavioral;