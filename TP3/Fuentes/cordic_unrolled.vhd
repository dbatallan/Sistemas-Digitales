-- TP3
-- Materia: Sistemas Digitales
-- Alumno: David Leonardo Batallan
-- Padrón: 97529

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cordic_unrolled is
    generic(
        N : natural := 16 
    );
    port(
        clk: in std_logic;
        rst: in std_logic;
        req: in std_logic;
        ack: out std_logic;
        rot0_vec1: in std_logic;  -- Señal para seleccionar modo rotación o vectorial
        x_0 : in std_logic_vector(N-1 downto 0);
        y_0 : in std_logic_vector(N-1 downto 0);
        z_0 : in std_logic_vector(N-1 downto 0);
        x_nm1 : out std_logic_vector(N-1 downto 0);
        y_nm1 : out std_logic_vector(N-1 downto 0);
        z_nm1 : out std_logic_vector(N-1 downto 0)       
    );
end cordic_unrolled;

architecture behavioral of cordic_unrolled is

    type matrix_type is array (natural range <>) of std_logic_vector(N-1 downto 0);

    constant CLOG2N : natural := natural(ceil(log2(real(N))));  -- Cantidad de bits necesarios para contar hasta N

    signal count : unsigned(CLOG2N-1 downto 0) := (others => '0');
    signal x_vect, y_vect, z_vect : matrix_type(N downto 0);
    signal x_reg, y_reg, z_reg : matrix_type(N-1 downto 0);
    signal ack_aux : std_logic;
    signal atan_2mi : std_logic_vector(N-3 downto 0);
    

begin

    -- Se intentó calcular arctangentes en tiempo de ejecución, pero Vivado no permite usar funciones de punto flotante no constantes.
    -- Por lo tanto, se utiliza una ROM para almacenar los valores precomputados de atan(2^{-i})

    ROM: entity work.atan_rom(behavioral)
        generic map(
            ADD_W  => CLOG2N,
            DATA_W => N-2
        )
        port map(
            addr_i => std_logic_vector(count),
            data_o => atan_2mi
        );
    
    -- Generación de N etapas de la arquitectura CORDIC desenrollada
    CORDIC_UNR: for i in 0 to N-1 generate
        
        CORDIC_BASE: entity work.cordic_base(behavioral)
        generic map(
            N => N, 
            CLOG2N => CLOG2N
        )
        port map(
            num_iter => count,
            rot0_vec1 => rot0_vec1,
            x_i => x_vect(i),
            y_i => y_vect(i),
            z_i => z_vect(i),
            atan_2mi => atan_2mi,
            x_ip1 => x_reg(i),
            y_ip1 => y_reg(i),
            z_ip1 => z_reg(i)  
        );
                
    end generate CORDIC_UNR;
    
    -- Registro intermedio para señal x
    REGISTER_X: for i in 0 to N-1 generate
        REG_X: entity work.reg(behavioral)
        generic map(
            N => N
        )
        port map(
            d   => x_reg(i),
            rst => rst,
            clk => clk,
            q   => x_vect(i+1)
        );
    end generate REGISTER_X;
    
    -- Registro intermedio para señal y
    REGISTER_Y: for i in 0 to N-1 generate
        REG_Y: entity work.reg(behavioral)
        generic map(
            N => N
        )
        port map(
            d   => y_reg(i),
            rst => rst,
            clk => clk,
            q   => y_vect(i+1)
        );
    end generate REGISTER_Y;
    
    -- Registro intermedio para señal z
    REGISTER_Z: for i in 0 to N-1 generate
        REG_Z: entity work.reg(behavioral)
        generic map(
            N => N
        )
        port map(
            d   => z_reg(i),
            rst => rst,
            clk => clk,
            q   => z_vect(i+1)
        );
    end generate REGISTER_Z;

    -- Asignación de entradas iniciales
    x_vect(0) <= x_0; 
    y_vect(0) <= y_0; 
    z_vect(0) <= z_0;

    -- Asignación de salidas finales luego de N iteraciones
    x_nm1 <= x_reg(N-1); 
    y_nm1 <= y_reg(N-1); 
    z_nm1 <= z_reg(N-1);

    -- Lógica de control para contador de etapas e inicio del proceso
    process(clk,rst)
    begin
        if rst = '1' then
            count <= (others => '0');
        elsif clk'event and clk = '1' then
            if req = '1' then 
                count <= (others => '0');
            elsif count /= N-1 then
                count <= count + 1;
            end if;
        end if;
    end process;
    
    -- Señal de finalización de la operación
    ack_aux <= '1' when count = N-1 else '0';
    ack <= ack_aux;   

end behavioral;
