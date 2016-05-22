--
--	Program counter
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is 
	port (
			alu_output: in std_logic_vector (15 downto 0);
			pc_out: out std_logic_vector (15 downto 0);
			address_out: out std_logic_vector (15 downto 0);
			data_out: out std_logic_vector (7 downto 0);
			nRST, nCLK2, nCLK1: in std_logic;
			control_signals : in std_logic_vector(255 downto 0);
			C, Z, D: in std_logic
		);
end program_counter;

architecture rtl of program_counter is 

	signal pc : std_logic_vector (15 downto 0);

	#include "control-signals.txt"

begin

load_pc0:	process (alu_output, nRST, nCLK2, nPCC, C, nPCD, D, nPCZ, Z, 
			 nLPC, nLIR, nLDL, nLDH, nLSPL, nLSPH, nLAIL, nLAIH, nLD2L, nLD2H, 
			 nLBIL, nLBIH, nLCIL, nLCIH, nLDIL, nLDIH)
	begin
		if nRST = '0' then
			pc <= x"0000";
		elsif nCLK2'event and nCLK2 = '1' then
			if (((not nPCC) and (not C)) or ((not nPCD) and (not D)) or ((not nPCZ)  and (not Z)) or (not nLPC) or 
				(not (nLIR and nLDL and nLDH and nLSPL and nLSPH and nLAIL and nLAIH and nLD2L and nLD2H and nLBIL and nLBIH and
				      nLCIL and nLCIH and nLDIL and nLDIH))) = '1' then
				pc <= alu_output;
			end if;
		end if;
	end process;

load_pcout0:	process (pc, nCLK1, nSPL, nSPH, nSSPCL, nSSPCH)
	begin
		if nCLK1'event and nCLK1 = '1' then
			if (nSPL and nSSPCL) = '0' then
				data_out <= pc(7 downto 0);
			elsif (nSPH and nSSPCH) = '0' then
				data_out <= pc(15 downto 8);
			end if;
		end if;
	end process;

pc_out <= pc;
address_out <= pc;

#include "control-lines.txt"

end rtl;
