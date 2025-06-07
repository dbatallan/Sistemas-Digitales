-- TP 2
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_subadd is
    generic(N : natural := 20;
            NE : natural := 6
    );
    port (
        X         : in std_logic_vector(N-1 downto 0); -- Operando de entrada 1 (formato flotante)
        Y         : in std_logic_vector(N-1 downto 0); -- Operando de entrada 2 (formato flotante)
        ctrl      : in std_logic; -- Control de operación: '0' para suma, '1' para resta
        Z         : out std_logic_vector(N-1 downto 0) -- Resultado de la operación (formato flotante)
    );
end fp_subadd;

architecture behavioral of fp_subadd is

    -- Constantes relacionadas al formato
    constant EXC    : natural := 2**(NE-1)-1; -- Valor del sesgo (bias) para el exponente
    constant NF     : natural := N-NE-1; -- Ancho de la mantisa
    constant EXCESO : signed(NE-1 downto 0) := to_signed(EXC, NE);
    constant E_MAX  : signed(NE downto 0) := to_signed(2**(NE)-2, NE+1); -- Máximo valor permitido del exponente
    constant E_MIN  : signed(NE downto 0) := to_signed(0, NE+1);         -- Mínimo valor permitido del exponente

    -- Señales auxiliares
    signal Y_aux    : std_logic_vector(N-1 downto 0) := (others => '0');

    -- Campos de exponente extendidos a NE+1 bits para manejar signos en la resta
    signal ex_aux   : unsigned(NE downto 0) := (others => '0');
    signal ey_aux   : unsigned(NE downto 0) := (others => '0');
    signal resta_E  : unsigned(NE downto 0) := (others => '0'); -- Diferencia entre exponentes

    -- Operandos alineados para la operación
    signal X_p      : unsigned(N-1 downto 0) := (others => '0');
    signal Y_p      : unsigned(N-1 downto 0) := (others => '0');

    -- Campos descompuestos de los operandos
    signal sx_p     : std_logic; -- Bit de signo de X_p
    signal sy_p     : std_logic; -- Bit de signo de Y_p
    signal ex_p     : unsigned(NE-1 downto 0) := (others => '0'); -- Exponente de X_p
    signal ey_p     : unsigned(NE-1 downto 0) := (others => '0'); -- Exponente de Y_p
    signal fx_p     : unsigned(NF-1 downto 0) := (others => '0'); -- Mantisa de X_p
    signal fy_p     : unsigned(NF-1 downto 0) := (others => '0'); -- Mantisa de Y_p
    signal mx_p     : unsigned(NF downto 0) := (others => '0'); -- Significando (mantisa normalizada) de X_p
    signal my_p     : unsigned(NF downto 0) := (others => '0'); -- Significando (mantisa normalizada) de Y_p

    -- Preparación para el alineamiento y suma de los significandos
    -- Se reserva espacio suficiente para manejar el peor caso de desplazamiento entre exponentes
    signal mx_2p    : unsigned(NF+2**(NE)-1 downto 0) := (others => '0');
    signal my_2p    : unsigned(NF+2**(NE)-1 downto 0) := (others => '0');
    signal mx_3p    : unsigned(NF+2**(NE)+1 downto 0) := (others => '0');
    signal my_3p    : unsigned(NF+2**(NE)+1 downto 0) := (others => '0');
    signal mx_4p    : unsigned(NF+2**(NE)+1 downto 0) := (others => '0');
    signal my_4p    : unsigned(NF+2**(NE)+1 downto 0) := (others => '0');

    signal suma     : unsigned(NF+2**(NE)+1 downto 0) := (others => '0'); -- Resultado crudo
    signal suma_p   : unsigned(NF+2**(NE)+1 downto 0) := (others => '0'); -- Resultado positivo (complementado si fue negativo)

    signal fz_aux   : unsigned(NF+2**(NE)+1 downto 0) := (others => '0');
    signal fz_aux_p : unsigned(NF-1 downto 0) := (others => '0');
    signal fz       : unsigned(NF-1 downto 0) := (others => '0');
    signal ez_aux   : signed(NE downto 0) := (others => '0');
    signal ez       : signed(NE-1 downto 0) := (others => '0');
    signal sz       : std_logic := '0'; -- Bit de signo del resultado final
    
    -- Indicadores de si es necesario complementar los operandos
    signal comp_x   : std_logic := '0';
    signal comp_y   : std_logic := '0';
    
    -- Función que retorna la posición del primer '1' más significativo
    function find_one (x0: std_logic_vector) return integer is
        variable found  : boolean;
        variable index  : integer;
    begin
        found := False;

        for i in x0'length-1 downto 0 loop
            if x0(i) = '1' and not found then
                found := True;
                index := i;
            end if;
        end loop;
        
        if index < 0 then
            index := 0;
        end if;

        return index;
    end function;

begin

    -- Negación condicional del operando Y si se desea realizar una resta
    Y_aux <= not(Y(N-1)) & Y(N-2 downto 0) when ctrl = '1' else Y;

    -- Cálculo de exponentes con bit adicional para comparación
    ex_aux <= '0' & unsigned(X(NF+NE-1 downto NF));
    ey_aux <= '0' & unsigned(Y_aux(NF+NE-1 downto NF));
    
    resta_E <= ex_aux - ey_aux;

    -- Determinación del operando con mayor exponente. Se reordenan si es necesario.
    X_p <= unsigned(Y_aux) when resta_E(NE) = '1' else unsigned(X);
    Y_p <= unsigned(X)     when resta_E(NE) = '1' else unsigned(Y_aux);

    -- Extracción de campos
    sx_p <= X_p(NE+NF);
    sy_p <= Y_p(NE+NF);
    ex_p <= X_p(NF+NE-1 downto NF);
    ey_p <= Y_p(NF+NE-1 downto NF);
    fx_p <= X_p(NF-1 downto 0);
    fy_p <= Y_p(NF-1 downto 0);
    mx_p <= '1' & fx_p;
    my_p <= '1' & fy_p;

    -- Determinación de si se requiere complemento a 2
    comp_x <= '1' when sx_p = '1' else '0';
    comp_y <= '1' when sy_p = '1' else '0';

    -- Preparación de significandos para el desplazamiento
    mx_2p(NF downto 0) <= mx_p;
    my_2p(NF downto 0) <= my_p;

    -- Alineación de los significandos de acuerdo a los exponentes
    mx_3p <= '0' & '0' & (mx_2p sll to_integer(ex_p));
    my_3p <= '0' & '0' & (my_2p sll to_integer(ey_p));

    -- Aplicación de complemento si es necesario
    mx_4p <= (not(mx_3p) + 1) when comp_x = '1' else mx_3p;
    my_4p <= (not(my_3p) + 1) when comp_y = '1' else my_3p;

    -- Suma efectiva de los significandos
    suma <= mx_4p + my_4p;

    -- Determinación del signo del resultado final
    sz <= suma(NF+2**(NE)+1);

    -- Aplicación de complemento si el resultado fue negativo
    suma_p <= suma when sz = '0' else (not(suma) + 1);

    -- Normalización del resultado
    fz_aux   <= suma_p sll (suma_p'length - find_one(std_logic_vector(suma_p)));
    fz_aux_p <= fz_aux(fz_aux'length-1 downto fz_aux'length-NF);

    -- Cálculo del nuevo exponente
    ez_aux <= to_signed(find_one(std_logic_vector(suma_p)) - NF, NE+1);

    -- Saturación del exponente y ajuste de la mantisa
    ez <= E_MAX(NE-1 downto 0) when to_integer(ez_aux) > to_integer(E_MAX) else
          E_MIN(NE-1 downto 0) when to_integer(ez_aux) < to_integer(E_MIN) else
          ez_aux(NE-1 downto 0);

    fz <= (others => '1') when to_integer(ez_aux) > to_integer(E_MAX) else
          (others => '0') when to_integer(ez_aux) < to_integer(E_MIN) else
          fz_aux_p;

    -- Construcción del resultado final
    Z <= sz & std_logic_vector(ez) & std_logic_vector(fz);

end architecture behavioral;
