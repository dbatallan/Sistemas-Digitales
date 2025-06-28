-- TP3
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cordic is
    generic(
        N : natural := 16
    );
    port(
        clk             : in std_logic;
        rst             : in std_logic;
        req             : in std_logic;
        rot0_vec1       : in std_logic;
        x_i, y_i, z_i   : in std_logic_vector(N-1 downto 0);
        ack             : out std_logic;
        x_o, y_o, z_o   : out std_logic_vector(N-1 downto 0)
    );
end cordic;


architecture behavioral_iter of cordic is

    -- Entradas y salidas de Pre - Cordic
    signal x_i_precordic, y_i_precordic, z_i_precordic : std_logic_vector(N-1 downto 0);
    signal x_o_precordic, y_o_precordic, z_o_precordic : std_logic_vector(N-1 downto 0);
    
    -- Entradas y salidas de Cordic_iterativo
    signal x_i_cordic, y_i_cordic, z_i_cordic : std_logic_vector(N-1 downto 0);
    signal ack_aux : std_logic;
       

begin
    
    x_i_precordic <= x_i;
    y_i_precordic <= y_i;
    z_i_precordic <= z_i;
    ack <= ack_aux;
        
    PRE_CORDIC: entity work.pre_cordic(behavioral)
    generic map(N => N)
    port map(
        x_i => x_i_precordic,
        y_i => y_i_precordic,
        z_i => z_i_precordic,
        rot0_vec1 => rot0_vec1,
        x_o => x_o_precordic,
        y_o => y_o_precordic,
        z_o => z_o_precordic
    );
    
    CORDIC_I: entity work.cordic_iter(behavioral)
    generic map(N => N)
    port map(
        clk       => clk,
        rst       => rst,
        req       => req,
        ack       => ack_aux,
        rot0_vec1 => rot0_vec1,
        x_0       => x_o_precordic,
        y_0       => y_o_precordic,
        z_0       => z_o_precordic,
        x_nm1     => x_o,
        y_nm1     => y_o,
        z_nm1     => z_o
    );
    
end behavioral_iter;


architecture behavioral_unrolled of cordic is

    -- Entradas y salidas de Pre - Cordic
    signal x_i_precordic, y_i_precordic, z_i_precordic : std_logic_vector(N-1 downto 0);
    signal x_o_precordic, y_o_precordic, z_o_precordic : std_logic_vector(N-1 downto 0);
    
    -- Entradas y salidas de Cordic_iterativo
    signal x_i_cordic, y_i_cordic, z_i_cordic : std_logic_vector(N-1 downto 0);
    signal ack_aux : std_logic;
    
    

begin

    x_i_precordic <= x_i;
    y_i_precordic <= y_i;
    z_i_precordic <= z_i;
    ack <= ack_aux;
    
       
    PRE_CORDIC: entity work.pre_cordic(behavioral)
    generic map(N => N)
    port map(
        x_i       => x_i_precordic,
        y_i       => y_i_precordic,
        z_i       => z_i_precordic,
        rot0_vec1 => rot0_vec1,
        x_o       => x_o_precordic,
        y_o       => y_o_precordic,
        z_o       => z_o_precordic
    );
    
    CORDIC_UP: entity work.cordic_unrolled(behavioral)
    generic map(
        N => N
    )
    port map(
        clk => clk,
        rst => rst,
        req => req,
        ack => ack_aux,
        rot0_vec1 => rot0_vec1,
        x_0 => x_o_precordic,
        y_0 => y_o_precordic,
        z_0 => z_o_precordic,
        x_nm1 => x_o,
        y_nm1 => y_o,
        z_nm1 => z_o
    );
    
end behavioral_unrolled;