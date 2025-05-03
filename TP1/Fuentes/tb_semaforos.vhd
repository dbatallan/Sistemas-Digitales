-- Trabajo Practico Nº1: Implementación de un Sistema Secuencial en VHDL
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_semaforos is
end tb_semaforos;

architecture behavioral of tb_semaforos is
    
    constant SIM_TIME : time := 200000 ms;
    constant N_TB : natural := 31;

    signal tb_rst           : std_logic;
    signal tb_clk           : std_logic := '0';
    signal tb_rojo_1        : std_logic;
    signal tb_amarillo_1    : std_logic;
    signal tb_verde_1       : std_logic;
    signal tb_rojo_2        : std_logic;
    signal tb_amarillo_2    : std_logic;
    signal tb_verde_2       : std_logic;
    
begin

    tb_rst <= '0', '1' after 1 ns, '0' after 20 ns;
    tb_clk <= not tb_clk after 500 ms; -- Clock con freq : 50 MHz
    
    
    
    I1: entity work.semaforos(behavioral)
    port map(
        rst         => tb_rst,
        clk         => tb_clk,
        rojo_1      => tb_rojo_1,
        amarillo_1  => tb_amarillo_1,
        verde_1     => tb_verde_1,
        rojo_2      => tb_rojo_2,
        amarillo_2  => tb_amarillo_2,
        verde_2     => tb_verde_2
    );
    
end behavioral;    