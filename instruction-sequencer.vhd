--
--	Instruction sequencer 
--

library ieee;
use 	ieee.std_logic_1164.all;
use 	ieee.numeric_std.all;

entity instruction_sequencer is 

	port (
			clk1: in std_logic;
			clk2: in std_logic;	
			input: in std_logic_vector(7 downto 0);
			nRST: in std_logic;
			nSTART: in std_logic;
			control_signals: out std_logic_vector(255 downto 0)
		);
end instruction_sequencer;

architecture rtl of instruction_sequencer is

	type ROM_ARRAY is array(0 to 4095) of std_logic_vector(7 downto 0);

	constant microcode_rom : ROM_ARRAY := (
		#include "control-rom.txt"
	);

	component counter 

		generic ( WIDTH : integer );
					
		port ( 	clk : in std_logic;
			output : out std_logic_vector (WIDTH - 1 downto 0);
			nreset : in std_logic );
	end component;

	component decoder

		generic ( WIDTH : integer );

		port (  input: in std_logic_vector (WIDTH - 1 downto 0);
			output: out std_logic_vector (2**WIDTH - 1 downto 0)
			);

	end component;

	signal	instruction_lo : std_logic_vector (3 downto 0) := "0000";
	signal  instruction_high : std_logic_vector (7 downto 0) := "00000000";
	signal	control_lines : std_logic_vector (255 downto 0) ;
	
	signal	instruction : std_logic_vector (7 downto 0) := "00000000";	
	
	signal 	nLIR, nHALT, ctr_clk, ctr_reset, nLIR_latch : std_logic := '0';

begin

ctr0:	counter generic map (WIDTH => 4) port map (clk => ctr_clk, nreset => ctr_reset, output => instruction_lo);

dec0:	decoder generic map (WIDTH => 8) port map (input => instruction, output => control_lines);

-- instruction decode

inst0:  process (instruction_lo, instruction_high)
		variable address : std_logic_vector(11 downto 0);
	begin
	address := instruction_high & instruction_lo;
	instruction <= microcode_rom(to_integer(unsigned(address)));

	end process;
-- latch nLIR

nlir0: process (clk1)
	begin
	   if clk1'event and clk1 = '1' then
		nLIR_latch <= nLIR;
	   end if;
	end process;

-- load instruction register

rstinst0: process (nRST, nLIR_latch, clk2)
	begin
	  if nRST = '0' then
		instruction_high <= (others => '0');
	  elsif clk2'event and clk2 = '0' and nLIR_latch = '0' then
		instruction_high <= input;
	  end if;
	end process;

-- ctr clk
ctr_clk0: process (clk2, nSTART, nHALT)
	begin
		if clk2'event then
			ctr_clk <= (not clk2) and (not nSTART or nHALT);
		end if;
	end process;

-- concurrent statements
control_signals <= control_lines (255 downto 0);

nLIR <= control_lines (1);
nHALT <= control_lines (0);

ctr_reset <= nLIR_latch or (not nRST);


--instruction_high <= (others => '0') when nRST = '0';

end rtl;

