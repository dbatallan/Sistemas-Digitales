ghdl -a ../Fuentes/sumador_restador.vhd ../Fuentes/tb_sumador_restador.vhd
ghdl -s ../Fuentes/sumador_restador.vhd ../Fuentes/tb_sumador_restador.vhd
ghdl -e tb_fpsubadd
ghdl -r tb_fpsubadd --vcd=tb_fpsubadd.vcd --stop-time=100us
gtkwave tb_fpsubadd.vcd
