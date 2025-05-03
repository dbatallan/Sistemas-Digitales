-- TP 1
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity semaforos is
    port(
        rst         : in std_logic;
        clk         : in std_logic;
        rojo_1      : out std_logic;
        amarillo_1  : out std_logic;
        verde_1     : out std_logic;
        rojo_2      : out std_logic;
        amarillo_2  : out std_logic;
        verde_2     : out std_logic
    );
end semaforos;

architecture behavioral of semaforos is

    -- Definicion de constantes
    constant N_counter : natural := 31;
    constant DIEZ: unsigned(3 downto 0):= to_unsigned(8, 4);

    -- Definicion del tipo de dato "t_state"
    type t_state is (R1_V2, R1A1_V2, V1_A2, V1_R2, A1_R2A2);
    
    -- Definicion de señales a usar

    constant val     : std_logic_vector(N_counter-1 downto 0) := (others => '0');
    signal state     : t_state;
    signal mux_out   : std_logic;
    signal sel_mux   : std_logic;
    signal seg_30    : std_logic;
    signal seg_3     : std_logic;
    signal count: unsigned(3 downto 0);
begin
    
    -- Componentes
    mux: entity work.mux
    port map(
        x0 => seg_30,
        x1 => seg_3,
        s  => sel_mux,
        y  => mux_out
    );
    
    contador: entity work.counterN
    generic map(N => N_counter)
    port map(
        rst => rst,
        clk => clk,
        load => mux_out,
        val  => val,
        count => open,
        seg_30_count => seg_30,
        seg_3_count => seg_3
    );
    
    fsm: process(clk, rst) -- Maquina de estados
    begin
        if rst = '1' then
            state <= R1_V2;
            count <= (others => '0');
            
        elsif clk = '1' and clk'event then
            case state is
            
                when R1_V2 =>
                    if seg_3 = '1' then
                        count <= count + 1;
                        if count = DIEZ then
                            state <= R1A1_V2;
                            count <= (others => '0');
                        end if;
                    end if;
           
                when R1A1_V2 =>
                    if seg_3 = '1' then
                        state <= V1_A2;
                    end if;
                
                when V1_A2 =>
                    if seg_3 = '1' then
                        state <= V1_R2;
                    end if;
                
                when V1_R2 =>
                    if seg_3 = '1' then
                        count <= count + 1;
                        if count = DIEZ then
                            state <= A1_R2A2;
                            count <= (others => '0');
                        end if;
                    end if; 
                
                when A1_R2A2 =>
                    if seg_3 = '1' then
                        state <= R1_V2;
                    end if;

            end case;
        end if;
    end process;
    
    -- Selector del mux:
    sel_mux <=
                '1' when ((state = R1_V2) or (state = R1A1_V2) or (state = V1_A2) or (state = V1_R2) or (state = A1_R2A2)) else
                '0';
                
    -- Salidas:    
    rojo_1 <=
            '1' when ((state = R1_V2) or (state = R1A1_V2)) else
            '0';
            
    amarillo_1 <=
                '1' when ((state = R1A1_V2) or (state = A1_R2A2)) else
                '0';
                
    verde_1 <=
             '1' when ((state = V1_A2) or (state = V1_R2)) else
             '0';
             
    rojo_2 <=
            '1' when ((state = V1_R2) or (state = A1_R2A2)) else
            '0';
            
    amarillo_2 <=
                '1' when ((state = V1_A2) or (state = A1_R2A2)) else
                '0';
                
    verde_2 <=
             '1' when ((state = R1_V2) or (state = R1A1_V2)) else
             '0';

end behavioral;          