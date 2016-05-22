#!/usr/bin/python

#
#	gensig.py: generate instruction scheduler ROM entries and signals for use in vhd files
#
#

# load the instruction set description

f = open("instruction-set.txt","r")

state = None
control_lines = []
instructions = []
instructions_control_lines = {}

control_rom_bits = 8

for line in f.readlines():
	
	txt = line.strip()

	if txt == "[control-lines]":
		state = "control_lines"
	elif txt == "[instructions]":
		state = "instructions"
	elif txt == "[comments]":
		state = "comments"
	else:
		if txt == "":
			pass
		elif state == "control_lines":
			parts = txt.split("\t")		
			control_lines.append(parts[0].strip());
		elif state == "instructions":
			parts = txt.split("\t")	
			instructions.append(parts[0]);	
			instructions_control_lines[parts[0]] = parts[1].split(",");

f.close()			

# generate instruction scheduler ROM

f = open("control-rom.txt","w")

for i in range(0, 256):
	instruction = None
	if i < len(instructions):
		instruction = instructions[i] 
		
	for j in range (0, 16):
		if instruction:
			lines = instructions_control_lines[instruction]
					
			line = None
			val  =	0		
			if j < len(lines):
				line = lines[j]
				try:
					val = control_lines.index(line)
				except Exception:
					print line
					val = 0

			if j == 15:
			     	if i == 255:
					f.write('x"%02x" -- %03x' % (val, i * 16))
				else:			
					f.write('x"%02x", -- %03x' % (val, i * 16))				
			else:
				f.write('x"%02x", ' % val)			


		else:
			if j == 15:
				if i == 255:
					f.write('x"00" -- %03x' % (i * 16))				
				else:
					f.write('x"00",-- %03x' % (i * 16))				
			else:
				f.write('x"00", ')			

	f.write("\n");

f.close()

# generate concurrent statements for vhd files

f = open("control-lines.txt","w")
f2 = open("control-signals.txt","w")

for i in range(0, len(control_lines)):

	line = control_lines[i]

	if line in ('AND','OR'):
		line = "n_%s" % line
	else:
		line = "n%s" % line	
	
	f.write("%s <= control_signals(%d);\n" % (line, i))
	f2.write("signal %s: std_logic;\n" % line)

f.close()
f2.close()
