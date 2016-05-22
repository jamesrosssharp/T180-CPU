--
--	Effective address unit
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity effective_address_unit is

	port (
		b_register: in std_logic_vector (15 downto 0);
		c_register: in std_logic_vector (15 downto 0);
		d_register: in std_logic_vector (15 downto 0);

		da_register: in std_logic_vector (15 downto 0);

		output: out std_logic_vector (15 downto 0);

		carry: in std_logic;

		clk1, clk2: in std_logic;
		
		control_signals : in std_logic_vector(255 downto 0)

	);

end effective_address_unit;

architecture rtl of effective_address_unit is

	#include "control-signals.txt"

	signal effective_address : std_logic_vector(15 downto 0);
	signal address_add_out	: std_logic_vector(15 downto 0);

begin

add0:   process (b_register, c_register, d_register, da_register, nLDABOPDA, nLDABOPDA2, 
			     nLDACOPDA, nLDACOPDA2, nLDADOPDA, nLDADOPDA2, carry)

		variable add1 : unsigned(15 downto 0);
		variable add2 : unsigned(15 downto 0);
		variable add3 : unsigned(15 downto 0);
		variable add_out : unsigned(15 downto 0);

	begin

	add1 := "0000000000000000";
	add2 := "0000000000000000";
	add3 := "0000000000000000";		

	if carry = '1' then
		add3 := "0000000000000001";
	else
		add3 := "0000000000000000";
	end if;

	add2 := unsigned(da_register);

	if (nLDABOPDA and nLDABOPDA2) = '0' then
		add1 := unsigned(b_register);
	elsif (nLDACOPDA and nLDACOPDA2) = '0' then
		add1 := unsigned(c_register);
	elsif (nLDADOPDA and nLDADOPDA2) = '0' then
		add1 := unsigned(d_register);
	end if;

	add_out := add1 + add2 + add3;
	
	address_add_out <= std_logic_vector(add_out);


	end process;

addr0:	process (clk1)
	begin
	if rising_edge(clk1) then 
		if (nLDABDA and nLDABDA2) = '0' then
			effective_address <= b_register;
		elsif (nLDACDA and nLDACDA2) = '0' then
			effective_address <= c_register;
		elsif (nLDACOPDA and nLDACOPDA2 and nLDABOPDA and nLDABOPDA2 and
			   nLDADOPDA and nLDADOPDA2) = '0' then
			effective_address <= address_add_out;
		end if;
	end if;
	end process;

output <= effective_address;

#include "control-lines.txt"

end rtl;
