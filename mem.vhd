--
--	Program memory
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity program_memory is

	port (
		data_in: in std_logic_vector (7 downto 0);
		data_out: out std_logic_vector (7 downto 0);
		address: in std_logic_vector (15 downto 0);
		nCLK1, nCLK2, nLIR, nLAL, nLAH, nLDL, nLDH, nSAL, nSAH, nSPL, nSPH : in std_logic
	);

end program_memory;

architecture rtl of program_memory is

	type RAM_ARRAY is array(0 to 255) of std_logic_vector(7 downto 0);

	-- Viktor Toths multiplication program
	--00:  F          CLF       ; Initialize
	--01:  5 0 0      AND 00    ; Load 0 to accumulator
	--04:  2 E F      STA FE    ; Set #FE to 0
	--07:  1 C F      LDA FC    ; Load first argument
	--0A:  5 F 0      AND 0F    ; Take low nybble
	--0D:  2 A F      STA FA    ; Store at working storage
	--10:  1 D F      LDA FD    ; Load second argument
	--13:  5 F 0      AND 0F    ; Take low nybble
	--16:  2 9 2      STA 29    ; Store as argument to ADD instruction
	--19:  1 A F      LDA FA    ; Load first argument
	--1C:  F          CLF       ;
	--1D:  E          ROR       ; Take one bit
	--1E:  2 A F      STA FA    ; Store the rest
	--21:  C E 2      JNC 2E    ; If not 1, no need to add
	--24:  1 E F      LDA FE    ; Load result
	--27:  F          CLF       ;
	--28:  7 0 0      ADD 00    ; Add second argument (stored here)
	--2B:  2 E F      STA FE    ; Store result
	--2E:  1 9 2      LDA 29    ; Load second argument
	--31:  F          CLF       ; Multiply by 2
	--32:  D          ROL       ;
	--33:  2 9 2      STA 29    ; Store
	--36:  1 A F      LDA FA    ; Reload first
	--39:  F          CLF       ;
	--3C:  7 0 0      ADD 00    ; Check for 0
	--3D:  9 D 1      JNZ 1D    ; Repeat loop if necessary
	--40:  0          HLT       ; Result obtained
	--41:  3 0 0      JMP 00    ; Restart

	--FA: 0 0                   ; Working storage
	--FC: 3 5                   ; Operands
	--FE: 0 0                   ; Result
	
	signal ram : RAM_ARRAY := (
		x"0f", x"05", x"00", x"00", x"02", x"fe", x"00", x"01",	-- 00
		x"fc", x"00", x"05", x"ff", x"00", x"02", x"fa", x"00", -- 08
		x"01", x"fd", x"00", x"05", x"ff", x"00", x"02", x"29", -- 10
		x"00", x"01", x"fa", x"00", x"0f", x"0e", x"02", x"fa", -- 18
		x"00", x"0c", x"2e", x"00", x"01", x"fe", x"00", x"0f", -- 20
		x"07", x"00", x"00", x"02", x"fe", x"00", x"01", x"29", -- 28
		x"00", x"0f", x"0d", x"02", x"29", x"00", x"01", x"fa", -- 30
		x"00", x"0f", x"07", x"00", x"00", x"09", x"1d", x"00", -- 38
		x"00", x"03", x"00", x"00", x"00", x"00", x"00", x"00", -- 40
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 48
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 50
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 58
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 60
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 68
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 70
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 78
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",-- 80
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 88
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",-- 90
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 98
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- a0
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- a8
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- b0
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- b8
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",-- c0
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- c8
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- d0
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- d8
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- e0
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- e8
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- f0
		x"00", x"00", x"00", x"00", x"ff", x"ff", x"FF", x"FF"  -- f8
	);

	signal result : std_logic_vector(15 downto 0);
	signal add_instruction_arg : std_logic_vector (15 downto 0);
	signal working : std_logic_vector (15 downto 0);

begin


stmem0: process (nCLK2, nSAL, nSAH, nSPL, nSPH, address)
	begin	
		if nCLK2'event and nCLK2 = '1' then
			if (nSAL and nSAH and nSPL and nSPH) = '0' then
				ram(to_integer(unsigned(address(7 downto 0)))) <= data_in;
			end if;
		end if;
	end process;

ldmem0: process (ram, nCLK1, nLIR, nLAL, nLAH, nLDL, nLDH, address)
	begin
		if nCLK1'event and nCLK1 = '1' then
			if (nLIR and nLAL and nLAH and nLDL and nLDH) = '0' then
				data_out <= ram(to_integer(unsigned(address(7 downto 0))));
			end if;
		end if;

	end process;

result(15 downto 8) <= ram(255);
result(7 downto 0) <= ram(254);
add_instruction_arg (15 downto 8) <= ram(16#2a#);
add_instruction_arg (7 downto 0) <= ram(16#29#);
working (15 downto 8) <= ram(16#FB#);
working (7 downto 0) <= ram(16#FA#);

end rtl;


