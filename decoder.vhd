--
--	decoder (from web.ewu.edu/groups/technology/Claudio/ee36010/Lectures/VHDL_generics_Pedroni.pdf)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is

	generic ( WIDTH : integer );

	port (  input: in std_logic_vector (WIDTH - 1 downto 0);
		output: out std_logic_vector (2**WIDTH - 1 downto 0)
	);

end decoder;

architecture rtl of decoder is
begin

  process (input)
	variable temp1 : std_logic_vector (output'HIGH downto 0);
	variable temp2 : integer range 0 to output'HIGH;
  begin	
	temp1 := (others => '1');
	temp2 := 0;

	for i in input'range loop
		if (input(i) = '1') then
			temp2 := 2*temp2+1;
		else
			temp2 := 2*temp2;
		end if;
	end loop;
	
	temp1(temp2) := '0';

	output <= temp1;

   end process;

end rtl;

