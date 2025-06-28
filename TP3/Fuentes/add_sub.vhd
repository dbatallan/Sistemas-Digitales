-- TP3
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity add_sub is
    generic(N : natural := 5);
    port(
        x         : in std_logic_vector(N-1 downto 0);
        y         : in std_logic_vector(N-1 downto 0);
        add0_sub1 : in std_logic;
        z : out std_logic_vector(N-1 downto 0)
    );
end add_sub;

architecture behavioral of add_sub is

begin
    z <= std_logic_vector(signed(x) + signed(y)) when add0_sub1 = '0' else
         std_logic_vector(signed(x) - signed(y));
         
end behavioral;
