-- TP 1
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux is
    port(
        x0  : in std_logic; -- Entrada 0 mux
        x1  : in std_logic; -- Entrada 1 mux
        s   : in std_logic; -- Selectro mux
        y   : out std_logic -- Salida
    );
end mux;

architecture behavioral of mux is
begin
    process(x0,x1,s)
    begin
        case s is
            when '0' =>
                y <= x0;
            
            when others =>
                y <= x1;
        end case;
    end process;
end behavioral;
