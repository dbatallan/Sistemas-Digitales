-- TP 2
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity tb_fpsubadd is
end entity tb_fpsubadd;

architecture tb_arch of tb_fpsubadd is

    -- Ruta al archivo de prueba con los casos de test
    constant FILE_PATH  : string := "../../Archivos_de_Prueba/fsub_12_6.txt";

    -- Parámetros de reloj y formato flotante
    constant TCK        : time := 20 ns; -- Período del reloj
    constant F_SIZE     : natural := 12; -- Bits para la mantisa
    constant EXP_SIZE   : natural := 6;  -- Bits para el exponente
    constant WORD_SIZE  : natural := EXP_SIZE + F_SIZE + 1; -- Tamaño total de palabra (signo + exponente + mantisa)

    -- Señales internas
    signal clk      : std_logic := '0';
    signal ctrl_tb  : std_logic := '1'; -- Control para la operación ('1' = resta)

    -- Operandos y resultado esperados desde archivo
    signal x_file   : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal y_file   : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal z_file   : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');

    -- Resultado producido por el DUT
    signal z_dut    : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');

    -- Contadores de ciclos y errores
    signal ciclos   : integer := 0;
    signal errores  : integer := 0;

    -- Archivo de texto con los vectores de prueba
    file datos : text open read_mode is FILE_PATH;
    
begin

    -- Generador de reloj
    clk <= not(clk) after TCK / 2;

    -- Proceso de lectura y aplicación de vectores de prueba
    Test_Sequence: process 
        variable l   : line;
        variable ch  : character := ' ';
        variable aux : integer;
    begin
        while not(endfile(datos)) loop
            wait until rising_edge(clk);

            -- Incrementa el ciclo (útil para debugging)
            ciclos <= ciclos + 1;

            -- Lee una línea del archivo
            readline(datos, l);

            -- Lee los valores en el orden: X (entero), espacio, Y (entero), espacio, Z esperado (entero)
            read(l, aux);
            x_file <= std_logic_vector(to_unsigned(aux, WORD_SIZE));

            read(l, ch); -- Espacio

            read(l, aux);
            y_file <= std_logic_vector(to_unsigned(aux, WORD_SIZE));

            read(l, ch); -- Espacio

            read(l, aux);
            z_file <= std_logic_vector(to_unsigned(aux, WORD_SIZE));
        end loop;

        file_close(datos); -- Cierre del archivo al finalizar

        -- Finaliza la simulación cuando se termina el archivo
        assert false report
            "Fin de la simulación" severity failure;

    end process Test_Sequence;

    -- Instanciación del DUT (Device Under Test)
    DUT: entity work.fp_subadd(behavioral)
    generic map(
        N  => WORD_SIZE,
        NE => EXP_SIZE
    )
    port map(
        X    => x_file,
        Y    => y_file,
        ctrl => ctrl_tb,
        Z    => z_dut
    );

    -- Proceso de verificación automática
    verificacion: process(clk)
    begin
        if rising_edge(clk) then
            assert to_integer(unsigned(z_file)) = to_integer(unsigned(z_dut)) report
                "Error: la salida del DUT no coincide con el valor esperado. DUT = " &
                integer'image(to_integer(unsigned(z_dut))) &
                ", esperado = " &
                integer'image(to_integer(unsigned(z_file))) & "."
                severity warning;
            
            -- Acumula errores para evaluación posterior
            if to_integer(unsigned(z_file)) /= to_integer(unsigned(z_dut)) then
                errores <= errores + 1;
            end if;
        end if;
    end process;

end architecture tb_arch;
