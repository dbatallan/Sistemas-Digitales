-- TP 2
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity tb_fpmul is
end entity tb_fpmul;

architecture tb_arch of tb_fpmul is

    constant FILE_PATH  : string := "../../Archivos_de_Prueba/fmul_21_7.txt";
    constant TCK        : time := 20 ns; -- Ciclo de reloj
    constant F_SIZE     : natural := 21; -- Bits de la mantisa
    constant EXP_SIZE   : natural := 7;  -- Bits del exponente
    constant WORD_SIZE  : natural := EXP_SIZE + F_SIZE + 1; -- Total de bits (incluye bit de signo)

    signal clk      : std_logic := '0';
    signal x_file   : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal y_file   : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal z_file   : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal z_dut    : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');

    signal ciclos   : integer := 0;
    signal errores  : integer := 0;

    file datos : text open read_mode is FILE_PATH;
    
begin

    clk <= not(clk) after TCK/2; -- Generador de reloj

    Test_Sequence: process 
        variable l   : line;
        variable ch  : character := ' ';
        variable aux : integer;
    begin
        while not(endfile(datos)) loop
            wait until rising_edge(clk);
            -- Incremento de contador de ciclos (uso opcional para depuración)
            ciclos <= ciclos + 1;
            -- Lectura de una línea del archivo de pruebas
            readline(datos, l);
            -- Lectura del primer operando (X) desde la línea
            read(l, aux);
            x_file <= std_logic_vector(to_unsigned(aux, WORD_SIZE));
            -- Lectura del carácter separador
            read(l, ch);
            -- Lectura del segundo operando (Y)
            read(l, aux);
            y_file <= std_logic_vector(to_unsigned(aux, WORD_SIZE));
            -- Lectura del siguiente separador
            read(l, ch);
            -- Lectura del valor esperado de salida (Z)
            read(l, aux);
            z_file <= std_logic_vector(to_unsigned(aux, WORD_SIZE));
        end loop;

        file_close(datos); -- Cierre del archivo de entrada

        -- Finalización explícita de la simulación
        assert false report
            "Fin de la simulacion" severity failure;

    end process Test_Sequence;

    -- Instancia del módulo a probar (DUT)
    DUT: entity work.fp_mul(behavioral)
    generic map(
        N => WORD_SIZE,
        NE => EXP_SIZE
    )
    port map(
        X => x_file,
        Y => y_file,
        Z => z_dut
    );

    -- Proceso de verificación: compara la salida del DUT con la referencia
    verificacion: process(clk)
    begin
        if rising_edge(clk) then
            assert to_integer(unsigned(z_file)) = to_integer(unsigned(z_dut)) report
                "Error: Salida del DUT no coincide con referencia (salida del DUT = " &
                integer'image(to_integer(unsigned(z_dut))) &
                ", salida del archivo = " &
                integer'image(to_integer(unsigned(z_file))) & ")"
                severity warning;

            -- Contador de errores si hay discrepancia
            if to_integer(unsigned(z_file)) /= to_integer(unsigned(z_dut)) then
                errores <= errores + 1;
            end if;
        end if;
    end process;

end architecture tb_arch;
