--
--	Data address register
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_register is 

	port (
			data_in : in std_logic_vector (7 downto 0);
			data_out: out std_logic_vector (7 downto 0);
			register_out: out std_logic_vector (15 downto 0);
			accumulator_out: in std_logic_vector (15 downto 0);
			address_out: out std_logic_vector (15 downto 0);
			alu_out: in std_logic_vector (15 downto 0);
			nCLK1, nCLK2: in std_logic;
			nLD_LOW, nLD_HI, nLD_ACC, nST_LOW, nST_HI, nLD_ALU: in std_logic
		);

end generic_register;

architecture rtl of generic_register is

	signal reg_hi : std_logic_vector (7 downto 0);
	signal reg_lo : std_logic_vector (7 downto 0);
	
begin

ld_reg0: process (data_in, nCLK2, nLD_LOW, nLD_HI, nLD_ACC)
begin
	if nCLK2'event and nCLK2 = '1' then
		if (nLD_LOW) = '0' then
			reg_lo <= data_in;
		elsif (nLD_HI) = '0' then
			reg_hi <= data_in;
		elsif (nLD_ACC) = '0' then
			reg_lo <= accumulator_out(7 downto 0);
			reg_hi <= accumulator_out(15 downto 8);
		elsif (nLD_ALU) = '0' then
			reg_lo <= alu_out(7 downto 0);
			reg_hi <= alu_out(15 downto 8);			
		end if;
	end if;
end process; 

st_reg0: process (nST_LOW, nST_HI)
begin	
	if (nST_LOW) = '0' then
		data_out <= reg_lo;
	elsif (nST_HI) = '0' then
		data_out <= reg_hi;
	end if;
end process;

address_out <= reg_hi & reg_lo;
register_out    <= reg_hi & reg_lo;

end rtl;
