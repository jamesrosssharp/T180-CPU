--
--	Data address register
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_address_register_2 is 

	port (
			data_in : in std_logic_vector (7 downto 0);
			alu_output: in std_logic_vector (15 downto 0);
			data_out: out std_logic_vector (15 downto 0);
			address_out: out std_logic_vector (15 downto 0);
			effective_address_in: in std_logic_vector (15 downto 0);
			nCLK1, nCLK2: in std_logic;
			control_signals : in std_logic_vector(255 downto 0)
		);

end data_address_register_2;

architecture rtl of data_address_register_2 is

	signal da2_hi : std_logic_vector (7 downto 0);
	signal da2_lo : std_logic_vector (7 downto 0);

	#include "control-signals.txt"
	
begin

ld_da0: process (nCLK2)
begin
	if nCLK2'event and nCLK2 = '1' then
		if (nLD2L and nLD2DL) = '0' then
			da2_lo <= data_in;
		elsif (nLD2H and nLD2DH) = '0' then
			da2_hi <= data_in;
		elsif (nLDD2L and nLDD2H) = '0' then
			da2_lo <= alu_output(7 downto 0);
			da2_hi <= alu_output(15 downto 8);
		elsif (nLDABDA2 and nLDABOPDA2 and nLDACDA2 and nLDACOPDA2 and nLDADDA2 and nLDADOPDA2) = '0' then
			da2_lo <= effective_address_in(7 downto 0);
			da2_hi <= effective_address_in(15 downto 8);
		end if;
	end if;
end process; 

address_out <= da2_hi & da2_lo;
data_out    <= da2_hi & da2_lo;

#include "control-lines.txt"

end rtl;
