
set signals [list]

lappend signals "instruction_lo"
lappend signals "instruction_high"
lappend signals "instruction"
lappend signals "nrst"
lappend signals "nstart"
lappend signals "ctr_clk"
lappend signals "ctr_reset"

gtkwave::addSignalsFromList $signals 
gtkwave::setZoomRangeTimes [gtkwave::getMinTime] [gtkwave::getMaxTime]
