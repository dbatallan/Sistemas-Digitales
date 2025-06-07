-- TP 2
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_mul is
    generic(N : natural := 20;
            NE : natural := 6
    );
    port (
        X   : in std_logic_vector(N-1 downto 0); -- Primer operando
        Y   : in std_logic_vector(N-1 downto 0); -- Segundo operando
        Z   : out std_logic_vector(N-1 downto 0) -- Resultado       
    );
end fp_mul;

architecture behavioral of fp_mul is

    -- Constantes auxiliares para manejo de exponentes y formatos
    constant EXC        : natural := 2**(NE-1)-1; -- Valor base del exponente en exceso
    constant NF         : natural := N-NE-1;      -- Cantidad de bits de la mantisa
    constant EXCESO     : unsigned(NE+1 downto 0) := to_unsigned(EXC, NE+2); -- Exceso extendido
    constant E_MIN      : unsigned(NE-1 downto 0) := to_unsigned(0, NE);     -- Exponente mínimo
    constant E_MAX      : unsigned(NE-1 downto 0) := to_unsigned(2**(NE)-2, NE); -- Exponente máximo permitido
    constant E_CEROS    : unsigned(NE+1 downto 0) := to_unsigned(0, NE+2); -- Verificación de exponente nulo
    constant F_CEROS    : unsigned(NF-1 downto 0) := to_unsigned(0, NF);   -- Verificación de mantisa nula
    constant RES_CERO   : unsigned(N-2 downto 0) := to_unsigned(0, N-1);   -- Parte no signo de un resultado cero

    -- Señales internas: separación de campos
    signal sx       : std_logic; -- Bit de signo de X
    signal sy       : std_logic; -- Bit de signo de Y

    signal ex       : unsigned(NE+1 downto 0) := (others => '0'); -- Exponente de X extendido para control de overflow/underflow
    signal ey       : unsigned(NE+1 downto 0) := (others => '0'); -- Exponente de Y extendido
    signal cero_op  : std_logic := '0';                           -- Indicador de si alguno de los operandos es cero

    signal fx       : unsigned(NF-1 downto 0) := (others => '0'); -- Mantisa de X
    signal fy       : unsigned(NF-1 downto 0) := (others => '0'); -- Mantisa de Y

    signal mx       : unsigned(NF downto 0) := (others => '0');   -- Significand de X (1.F)
    signal my       : unsigned(NF downto 0) := (others => '0');   -- Significand de Y (1.F)

    signal sz           : std_logic;                                    -- Signo del resultado
    signal ez           : unsigned(NE-1 downto 0) := (others => '0');   -- Exponente final en exceso
    signal ez_aux       : unsigned(NE+1 downto 0) := (others => '0');   -- Exponente auxiliar intermedio
    signal ez_aux_p     : unsigned(NE+1 downto 0) := (others => '0');   -- Exponente auxiliar ajustado
    signal mz           : unsigned(2*NF+1 downto 0) := (others => '0'); -- Producto de los significands
    signal fz           : unsigned(NF-1 downto 0) := (others => '0');   -- Mantisa resultante
    signal fz_aux       : unsigned(NF-1 downto 0) := (others => '0');   -- Mantisa ajustada (previa al redondeo final)

begin

    -- Separación de campos: signo, exponente y mantisa
    sx <= X(NE+NF);
    sy <= Y(NE+NF);
    ex <= '0' & '0' & unsigned(X(NF+NE-1 downto NF)); -- Agrega ceros al frente para prevenir overflow/underflow
    ey <= '0' & '0' & unsigned(Y(NF+NE-1 downto NF));
    fx <= unsigned(X(NF-1 downto 0));
    fy <= unsigned(Y(NF-1 downto 0));

    -- Detección de operando cero
    cero_op <= '1' when ( (ex = E_CEROS) and (fx = F_CEROS) ) else
               '1' when ( (ey = E_CEROS) and (fy = F_CEROS) ) else
               '0';

    -- Cálculo del signo del resultado
    sz <= sx xor sy;

    -- Construcción de los significands (1.F)
    mx <= '1' & fx;
    my <= '1' & fy;

    -- Producto de los significands
    mz <= mx * my;

    -- Cálculo del nuevo exponente en exceso
    ez_aux <= ex + ey - EXCESO;

    -- Ajuste y redondeo de la mantisa
    fz_aux <=
        mz(2*NF downto NF+1) when mz(2*NF+1) = '1' else
        mz(2*NF-1 downto NF);

    ez_aux_p <= 
        (ez_aux + 1) when mz(2*NF+1) = '1' else ez_aux;

    -- Lógica de saturación del exponente y asignación de mantisa
    ez <= E_MAX when ( (ez_aux_p(NE+1) = '0') and (ez_aux_p(NE) = '1') ) else
          E_MIN when ( (ez_aux_p(NE+1) = '1') and (ez_aux_p(NE) = '1') ) else
          ez_aux_p(NE-1 downto 0);

    fz <= (others => '1') when ( (ez_aux_p(NE+1) = '0') and (ez_aux_p(NE) = '1') ) else
          (others => '0') when ( (ez_aux_p(NE+1) = '1') and (ez_aux_p(NE) = '1') ) else
          fz_aux;

    -- Resultado final: cero si corresponde, o número normalizado
    Z <= std_logic_vector(sz & RES_CERO) when (cero_op = '1') else 
         std_logic_vector(sz & ez & fz);

end architecture behavioral;
