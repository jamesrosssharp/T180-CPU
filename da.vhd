--
--	Data address register
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_address_register is 

	port (
			data_in : in std_logic_vector (7 downto 0);
			alu_output: in std_logic_vector (15 downto 0);
			data_out: out std_logic_vector (15 downto 0);
			address_out: out std_logic_vector (15 downto 0);
			effective_address_in: in std_logic_vector (15 downto 0);
			nCLK1, nCLK2: in std_logic;
			control_signals : in std_logic_vector(255 downto 0)
		);

end data_address_register;

architecture rtl of data_address_register is

	signal da_hi : std_logic_vector (7 downto 0);
	signal da_lo : std_logic_vector (7 downto 0);

	#include "control-signals.txt"
	
begin

ld_da0: process (nCLK2)
begin
	if nCLK2'event and nCLK2 = '1' then
		if (nLDL and nLSPDL and nLDD2L) = '0' then
			da_lo <= data_in;
		elsif (nLDH and nLSPDH and nLDD2H) = '0' then
			da_hi <= data_in;
		elsif (nSAL and nSPL and nLAL and nLBL and nSBL and nLCL and nLDDL and nSCL and nSDL and nLD2DL) = '0' then
			da_lo <= alu_output(7 downto 0);
			da_hi <= alu_output(15 downto 8);
		elsif (nLDABDA and nLDABOPDA and nLDACDA and nLDACOPDA and nLDADDA and nLDADOPDA) = '0' then
			da_lo <= effective_address_in(7 downto 0);
			da_hi <= effective_address_in(15 downto 8);
		end if;
	end if;
end process; 

address_out <= da_hi & da_lo;
data_out    <= da_hi & da_lo;

#include "control-lines.txt"

end rtl;
