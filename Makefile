all:	display-vectors

CPU.o:	CPU.vhd control-lines.txt control-signals.txt
	vpp	./CPU.vhd CPU.preprocessed
	ghdl	-a CPU.preprocessed

clock-gen.o:	clock-gen.vhd
	ghdl	-a clock-gen.vhd

CPU-tester.o: CPU-tester.vhd
	ghdl	-a CPU-tester.vhd


counter.o:	counter.vhd
	ghdl	-a counter.vhd

counter-tester.o: counter-tester.vhd
	ghdl	-a counter-tester.vhd

counter_tester:	counter-tester.o counter.o
	ghdl	-e counter_tester

counter.vcd:	counter_tester
	ghdl -r counter_tester --vcd=counter.vcd

decoder.o:	decoder.vhd
	ghdl	-a decoder.vhd

decoder-tester.o: decoder-tester.vhd
	ghdl	-a decoder-tester.vhd

decoder_tester:	decoder-tester.o decoder.o counter.o
	ghdl	-e decoder_tester

decoder.vcd:	decoder_tester
	ghdl -r decoder_tester --vcd=decoder.vcd

instruction-sequencer.o:	instruction-sequencer.vhd control-rom.txt
	vpp ./instruction-sequencer.vhd instruction-sequencer.preprocessed
	ghdl	-a instruction-sequencer.preprocessed

instruction-sequencer-tester.o: instruction-sequencer-tester.vhd
	ghdl	-a instruction-sequencer-tester.vhd

instruction_sequencer_tester:	instruction-sequencer-tester.o instruction-sequencer.o clock-gen.o decoder.o counter.o
	ghdl	-e instruction_sequencer_tester

instruction.vcd:	instruction_sequencer_tester
	ghdl -r instruction_sequencer_tester --vcd=instruction.vcd

alu.o:	alu.vhd control-lines.txt control-signals.txt
	vpp ./alu.vhd alu.preprocessed
	ghdl	-a alu.preprocessed

alu-tester.o: alu-tester.vhd
	ghdl	-a alu-tester.vhd

alu_tester:	alu-tester.o alu.o
	ghdl	-e alu_tester

alu.vcd:	alu_tester
	ghdl -r alu_tester --vcd=alu.vcd

acc.o:	acc.vhd control-lines.txt control-signals.txt
	vpp	./acc.vhd	acc.preprocessed
	ghdl	-a acc.preprocessed

da.o:	da.vhd control-lines.txt control-signals.txt
	vpp	./da.vhd da.preprocessed
	ghdl	-a da.preprocessed

da2.o:	da2.vhd control-lines.txt control-signals.txt
	vpp	./da2.vhd da2.preprocessed
	ghdl	-a da2.preprocessed

pc.o:	pc.vhd control-lines.txt control-signals.txt
	vpp	./pc.vhd pc.preprocessed
	ghdl	-a pc.preprocessed

effective-address.o:	effective-address.vhd control-lines.txt control-signals.txt
	vpp	./effective-address.vhd effective-address.preprocessed
	ghdl	-a effective-address.preprocessed


register.o: register.vhd
	ghdl	-a register.vhd

stack-pointer.o: stack-pointer.vhd control-lines.txt control-signals.txt
	vpp	./stack-pointer.vhd stack-pointer.preprocessed
	ghdl	-a stack-pointer.preprocessed

mem.o:	mem.vhd
	ghdl	-a mem.vhd

program_rom.o:	program_rom.vhd
	ghdl 	-a program_rom.vhd

cpu_tester:	counter.o decoder.o CPU-tester.o CPU.o clock-gen.o alu.o instruction-sequencer.o acc.o da.o da2.o pc.o program_rom.o stack-pointer.o register.o effective-address.o
	ghdl	-e cpu_tester

cpu.vcd:	cpu_tester
	ghdl -r cpu_tester --vcd=cpu.vcd

display-vectors: instruction.vcd
	gtkwave instruction.vcd -S instruction-sequencer-tester.tcl

#display-vectors: counter.vcd
#	gtkwave counter.vcd

display-vectors: cpu.vcd
	gtkwave cpu.vcd -S cpu-tester.tcl

clean: 
	rm *.o work-obj93.cf *.preprocessed cpu_tester instruction_sequencer_tester
