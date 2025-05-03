ghdl -a ../Fuentes/mux.vhd ../Fuentes/contadorN.vhd ../Fuentes/semaforos.vhd ../Fuentes/tb_semaforos.vhd
ghdl -s ../Fuentes/mux.vhd ../Fuentes/contadorN.vhd ../Fuentes/semaforos.vhd ../Fuentes/tb_semaforos.vhd
ghdl -e tb_semaforos
ghdl -r tb_semaforos --vcd=tb_semaforos.vcd --stop-time=200000ms
gtkwave tb_semaforos.vcd
