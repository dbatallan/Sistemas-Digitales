-- TP3
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pre_cordic is
    generic(
        N : natural := 16 -- cantidad de iteraciones que va a hacer el algoritmo
    );
    port(
        
        x_i        : in std_logic_vector(N-1 downto 0);
        y_i        : in std_logic_vector(N-1 downto 0);
        z_i        : in std_logic_vector(N-1 downto 0);
        rot0_vec1  : in std_logic;
        x_o        : out std_logic_vector(N-1 downto 0);
        y_o        : out std_logic_vector(N-1 downto 0);
        z_o        : out std_logic_vector(N-1 downto 0)
    );
    
end pre_cordic;

architecture behavioral of pre_cordic is

    -- 2**(N-1) --> 180
    -- 2**(N-2) --> 90
    -- 2**(N-3) --> 45
    constant ANG_180 : signed := to_signed(2**(N-1), N);
    constant ANG_90 : signed := to_signed(2**(N-2), N);
    constant ANG_45 : signed := to_signed(2**(N-3), N);
    signal   x_o_rot0, y_o_rot0, z_o_rot0 : std_logic_vector(N-1 downto 0);
    signal   x_o_vec1, y_o_vec1, z_o_vec1 : std_logic_vector(N-1 downto 0);

begin
    
    x_o_vec1 <= x_i;
    y_o_vec1 <= y_i;
    z_o_vec1 <= z_i;
    
        
    x_o_rot0 <= std_logic_vector(signed(not(x_i)) + 1) when std_logic_vector(abs(signed(z_i))) > std_logic_vector(abs(ANG_90)) else
                x_i;
    
    y_o_rot0 <= std_logic_vector(signed(not(y_i)) + 1) when std_logic_vector(abs(signed(z_i))) > std_logic_vector(abs(ANG_90)) else
                y_i;
           
    z_o_rot0 <= std_logic_vector( signed(z_i) - ANG_180 ) when signed(z_i) > ANG_90 else
                std_logic_vector( signed(z_i) + ANG_180 ) when signed(z_i) < -ANG_90 else
                z_i;
    
    
    x_o <= x_o_rot0 when rot0_vec1 = '0' else
           x_o_vec1;
           
    y_o <= y_o_rot0 when rot0_vec1 = '0' else
           y_o_vec1;
           
    z_o <= z_o_rot0 when rot0_vec1 = '0' else
           z_o_vec1;
    
end behavioral;