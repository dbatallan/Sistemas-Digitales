-- TP3
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_base is
    generic(
        N : natural := 16; -- cantidad de iteraciones que va a hacer el algoritmo
        CLOG2N : natural := 4 -- tamaño del punto fijo
    );
    port(
        num_iter : in unsigned(CLOG2N-1 downto 0);
        rot0_vec1: in std_logic;
        x_i : in std_logic_vector(N-1 downto 0);
        y_i : in std_logic_vector(N-1 downto 0);
        z_i : in std_logic_vector(N-1 downto 0);
        atan_2mi : in std_logic_vector(N-3 downto 0);
        x_ip1 : out std_logic_vector(N-1 downto 0);
        y_ip1 : out std_logic_vector(N-1 downto 0);
        z_ip1 : out std_logic_vector(N-1 downto 0)      
    );
end cordic_base;

architecture behavioral of cordic_base is

    signal x_aux,y_aux,z_aux : std_logic_vector(N-1 downto 0);
    signal x_shifted,y_shifted : std_logic_vector(N-1 downto 0);
    signal x_o,y_o,z_o : std_logic_vector(N-1 downto 0);
    signal di: std_logic;
    signal not_di: std_logic;
    signal sx_atan_2mi: std_logic_vector(N-1 downto 0);

begin

    x_aux <= x_i;
    y_aux <= y_i;
    z_aux <= z_i;

    x_shifted <= std_logic_vector(shift_right(signed(x_aux), to_integer(num_iter)));
    y_shifted <= std_logic_vector(shift_right(signed(y_aux), to_integer(num_iter)));

    di <= z_i(N-1) when rot0_vec1 = '0' else
          not(y_i(N-1));

    not_di <= not(di);

    sumador_x: entity work.add_sub(behavioral)
    generic map(N => N)
    port map(
        x => x_aux,
        y => y_shifted,
        z => x_o,
        add0_sub1 => not_di
    );

    sumador_y: entity work.add_sub(behavioral)
    generic map(N => N)
    port map(
        x => y_aux,
        y => x_shifted,
        z => y_o,
        add0_sub1 => di
    );

    sx_atan_2mi <= "00" & atan_2mi;
    
    sumador_z: entity work.add_sub(behavioral)
    generic map(N => N)
    port map(
        x => z_aux,
        y => sx_atan_2mi,
        z => z_o,
        add0_sub1 => not_di
    );
    
    x_ip1 <= x_o;
    y_ip1 <= y_o;
    z_ip1 <= z_o;

end behavioral; 