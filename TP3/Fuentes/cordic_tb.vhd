-- TP3
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

entity cordic_testbench is 
end entity cordic_testbench;

architecture cordic_testbench_arq of cordic_testbench is

    constant N : natural := 16;
    constant FILE_PATH  : string := "..\Datos.txt";
    
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal req : std_logic := '0';
    signal ack : std_logic;
    signal rot0_vec1 : std_logic := '0';
    signal x_in,y_in,z_in : std_logic_vector(N-1 downto 0);
    signal x_out,y_out,z_out : std_logic_vector(N-1 downto 0);

    file datos: text open read_mode is FILE_PATH;


begin

    clk <= not clk after 10 us;
    rst <= '0' after 2 us;

    Test_Sequence: process
    
        variable l   : line;
        variable ch  : character := ' ';
        variable aux : integer;
        variable z_file: integer;
        variable ANG_RAD: real;
        variable ANG_Z : integer;
        
    begin
    
        while not(endfile(datos)) loop
            wait until rising_edge(clk);
            -- Se lee una linea del archivo de valores de prueba
            readline(datos, l);
            -- Se extrae un entero de la linea
            read(l, aux);
            -- Se carga el valor de la coordenada X (en fondo de escala)
            x_in <= std_logic_vector(to_unsigned(aux, N));
            -- Se lee un caracter (el espacio)
            read(l, ch);
            -- Se lee otro entero de la linea
            read(l, aux);
            -- Se carga el valor de la coordenada Y (en fondo de escala)
            y_in <= std_logic_vector(to_signed(aux, N));
            -- Se lee otro caracter (el espacio)
            read(l, ch);
            -- Se lee otro entero
            read(l, aux);
            -- Se carga el valor del angulo a rotar (en grados)
            z_file := aux;
            
            -- Opero con el angulo a rotar.
            ANG_RAD := (real(z_file)*MATH_PI)/real(180); -- Lo paso a radianes
            ANG_Z := integer( round( (ANG_RAD/arctan(real(1))) * real(2**(N-3)) ) ); -- Lo escalo
            
            -- Se carga el valor correspondiente del angulo a rotar
            z_in <= std_logic_vector(to_signed(ANG_Z,N));
            
            req <= '1';
            wait until rising_edge(clk);
            req <= '0';
            wait until ack = '1';
            wait until rising_edge(clk);
        end loop;
    
        file_close(datos); -- Se cierra el archivo

        -- Se aborta la simulacion (fin del archivo)
        assert false report
            "Fin de la simulacion" severity failure;

    end process Test_Sequence;

    DUT: entity work.cordic(behavioral_unrolled)
    generic map(
        N => N 
    )
    port map(
        clk => clk,
        rst => rst,
        req => req,
        rot0_vec1 => rot0_vec1,
        x_i => x_in,
        y_i => y_in,
        z_i => z_in,
        ack => ack,
        x_o => x_out,
        y_o => y_out,
        z_o => z_out
        
    );

end architecture cordic_testbench_arq;