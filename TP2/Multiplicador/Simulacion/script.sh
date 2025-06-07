ghdl -a ../Fuentes/multiplicador.vhd ../Fuentes/tb_multiplicador.vhd
ghdl -s ../Fuentes/multiplicador.vhd ../Fuentes/tb_multiplicador.vhd
ghdl -e tb_fpmul
ghdl -r tb_fpmul --vcd=tb_fpmul.vcd --stop-time=100us
gtkwave tb_fpmul.vcd
