--
-- Accumulator
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator is 

	port (
			nRST: in std_logic;
			data_in: in std_logic_vector (7 downto 0);
			data_out: out std_logic_vector (7 downto 0);
			alu_output: in std_logic_vector (15 downto 0);
			accumulator_output: out std_logic_vector (15 downto 0);
			register_in: in std_logic_vector (15 downto 0);
			nCLK1, nCLK2: std_logic;
			control_signals : in std_logic_vector(255 downto 0)
		);

end accumulator;

architecture rtl of accumulator is

	signal	accu_hi: std_logic_vector (7 downto 0);
	signal	accu_lo: std_logic_vector (7 downto 0);

	#include "control-signals.txt"
	
begin

-- load accumulator

ld_accu0: process (data_in, alu_output, nLAL, nLAH, nCLK2, n_AND, n_OR, nSUB, nADD, nROR, nROL, nLASPH, nLASPL, nINCA, nDECA, nXOR, nLAIL, nLAIH,
		   nADC, nSBB, nMOVBA, nMOVCA, nMOVDA)
begin
	if nRST = '0' then
		accu_lo <= "00000000";
		accu_hi <= "00000000";
	elsif nCLK2'event and nCLK2 = '1' then
	
		if (nLAL and nLASPL and nLAIL) = '0' then
			accu_lo <= data_in;
		elsif (nLAH and nLASPH and nLAIH) = '0' then	
			accu_hi <= data_in;
		elsif (n_AND and nSUB and n_OR and nADD and nROR and nROL and nINCA and nDECA and nXOR and nADC and nSBB) = '0' then
			accu_hi <= alu_output(15 downto 8);
			accu_lo <= alu_output(7 downto 0);
		elsif (nMOVBA and nMOVCA and nMOVDA) = '0' then
			accu_hi <= register_in(15 downto 8);
			accu_lo <= register_in(7 downto 0);
		end if; 

	end if;

end process;
	
-- output to alu
-- we don't gate this as in Viktor T Toth's design (no need)
accumulator_output(15 downto 8) <= accu_hi;
accumulator_output(7 downto 0) <= accu_lo;

-- store accu

st0:	process (accu_hi, accu_lo, nCLK1, nSAL, nSAH, nSSPAL, nSSPAH)
	begin

		if nCLK1'event and nCLK1 = '1' then
			if nSAL = '0' or nSSPAL = '0' then	-- if storing the accumulator low byte to memory or to stack,
				data_out <= accu_lo;		-- place it on the data out port
			elsif nSAH = '0' or nSSPAH = '0' then
				data_out <= accu_hi;
			end if;
		end if;

	end process;

#include "control-lines.txt"


end rtl;
