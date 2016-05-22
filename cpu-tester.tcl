
set signals [list]

lappend signals "cpu_clk1"
lappend signals "cpu_clk2"
lappend signals "instruction_lo"
lappend signals "instruction_high"
lappend signals "instruction"
lappend signals "da_lo"
lappend signals "da_hi"
lappend signals "input1"
lappend signals "input2"
lappend signals "accu_lo"
lappend signals "accu_hi"
lappend signals "pc"
lappend signals "cpu_C"
lappend signals "cpu_Z"
lappend signals "cpu_nSTART"
lappend signals "sp_lo"
lappend signals "sp_hi"
lappend signals "da2_lo"
lappend signals "da2_hi"
lappend signals "cpu_b_register_out"
lappend signals "cpu_c_register_out"
lappend signals "cpu_d_register_out"

gtkwave::addSignalsFromList $signals 
gtkwave::setZoomRangeTimes [gtkwave::getMinTime] [gtkwave::getMaxTime]
