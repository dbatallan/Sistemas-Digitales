-- TP3
-- Materia: Sistemas digitales
-- Alumno: Batallan David Leonardo
-- Padron: 97529

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity atan_rom is
	generic(
		ADD_W  : natural:= 10;
		DATA_W : natural:= 9
    );
	port(
		addr_i : in std_logic_vector(ADD_W-1 downto 0);
		data_o : out std_logic_vector(DATA_W-1 downto 0)
    );
end entity atan_rom;


architecture behavioral of atan_rom is

	type rom_type is array (natural range <>) of std_logic_vector(DATA_W-1 downto 0);

	function atan (constant i : natural) return std_logic_vector is
    
    begin
        return std_logic_vector(to_unsigned(integer(round( (arctan(real(2)**real(-1*i)) / arctan(real(1))) * real(2**(DATA_W-1)) )), DATA_W));
	end;

	signal rom : rom_type(0 to 2**ADD_W-1);


begin
	Load_ROM : for i in 0 to DATA_W-1 generate
		rom(i) <= atan(i);
	end generate Load_ROM;
    
    data_o <= (others => '0') when unsigned(addr_i) > to_unsigned(DATA_W-1,ADD_W)  else
              rom(to_integer(unsigned(addr_i)));
    
end behavioral;