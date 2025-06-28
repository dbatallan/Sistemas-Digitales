-- TP3
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library ieee;
use ieee.std_logic_1164.all;

entity reg is
    generic(
        N : natural := 16
    );
    port(
        d   : in std_logic_vector(N-1 downto 0);
        rst : in std_logic;
        clk : in std_logic;
        q   : out std_logic_vector(N-1 downto 0)
    );
    
end reg;

architecture behavioral of reg is

begin

    process(clk,rst)
    begin
        if rst = '1' then
            q <= (others => '0');
        
        elsif clk = '1' and clk'event then
            q <= d;
            
        end if;
    end process;
    
end behavioral;