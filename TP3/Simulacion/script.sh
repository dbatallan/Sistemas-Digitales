ghdl -a ../Fuentes/add_sub.vhd
ghdl -a ../Fuentes/atan_rom.vhd
ghdl -a ../Fuentes/register.vhd
ghdl -a ../Fuentes/pre_cordic.vhd
ghdl -a ../Fuentes/cordic_base.vhd
ghdl -a ../Fuentes/cordic_iter.vhd
ghdl -a ../Fuentes/cordic_unrolled.vhd
ghdl -a ../Fuentes/cordic.vhd
ghdl -a ../Fuentes/cordic_tb.vhd
ghdl -e cordic_testbench
ghdl -r cordic_testbench --vcd=cordic_testbench.vcd --stop-time=5000us
gtkwave cordic_testbench.vcd
