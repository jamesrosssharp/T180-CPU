--
--	Stack pointer
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stack_pointer is 

	port (
			data_in : in std_logic_vector (7 downto 0);
			alu_output: in std_logic_vector (15 downto 0);
			data_out: out std_logic_vector (15 downto 0);
			address_out: out std_logic_vector (15 downto 0);
			nCLK1, nCLK2: in std_logic;
			control_signals : in std_logic_vector(255 downto 0)
		);



end stack_pointer;

architecture rtl of stack_pointer is

	signal sp_hi : std_logic_vector (7 downto 0);
	signal sp_lo : std_logic_vector (7 downto 0);
	
	#include "control-signals.txt"
	
begin

--nSSPBL, nSSPBH, nLBSPH, nLBSPL, nSSPCCL, nSSPCCH, nLCSPH, nLCSPL, nSSPDL, nSSPDH, nLDSPH, nLDSPL

ld_da0: process (data_in, alu_output, nCLK2, nLSPL, nLSPH, nSSPAL, nSSPAH, nDECSP, nLASPH, nSSPCL, nSSPCH, nLSPDH, nLSPDL,
		 nSSPBL, nSSPBH, nLBSPH, nLBSPL, nSSPCCL, nSSPCCH, nLCSPH, nLCSPL, nSSPDL, nSSPDH, nLDSPH, nLDSPL)
begin
	if nCLK2'event and nCLK2 = '1' then
		if nLSPL = '0' then
			sp_lo <= data_in;
		elsif nLSPH = '0' then
			sp_hi <= data_in;
		elsif (nSSPAL and nSSPAH and nDECSP and nLASPH and nSSPCL and nSSPCH and nLSPDH and 
			nSSPBL and nSSPBH and nLBSPH and nLBSPL and nSSPCCL and nSSPCCH and nLCSPH and 
			nLCSPL and nSSPDL and nSSPDH and nLDSPH and nLDSPL) = '0' then
			sp_lo <= alu_output(7 downto 0);
			sp_hi <= alu_output(15 downto 8);
		end if;
	end if;
end process; 

address_out <= sp_hi & sp_lo;
data_out    <= sp_hi & sp_lo;

#include "control-lines.txt"

end rtl;
