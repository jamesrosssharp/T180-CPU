--
--	Testbench for ALU
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tester is
end alu_tester;

architecture rtl of alu_tester is

	component alu 
		
		port (
			input1 : in std_logic_vector (15 downto 0);
			input2 : in std_logic_vector (15 downto 0);
			output : out std_logic_vector (15 downto 0);
			nCMP, nSUB, nADD, nSAL, nSPL, nLIR, nLAL, nLAH, nLDL, nLDH, nLPC, nPCC, nPCD, nPCZ, nCLK2, nCLF, n_AND, n_OR, nROL, nROR, nJND, nDATA : in std_logic;
			C, Z, D: out std_logic
		);

	end component;

	signal tb_input1, tb_input2, tb_output : std_logic_vector (15 downto 0);
	signal tb_nCMP, tb_nSUB, tb_nADD, tb_nSAL, tb_nSPL, tb_nLIR, tb_nLAL, tb_nLAH, tb_nLDL, tb_nLDH, tb_nLPC, tb_nPCC, tb_nPCD, tb_nPCZ, tb_nCLK2, tb_nCLF, tb_n_AND, tb_n_OR, tb_nROL, tb_nROR, tb_nJND, tb_nDATA : std_logic;
	signal tb_C, tb_Z, tb_D: std_logic;
begin

alu0: alu port map (input1 => tb_input1, input2 => tb_input2, output => tb_output, nCMP => tb_nCMP, nSUB => tb_nSUB, nADD => tb_nADD, nSAL => tb_nSAL, nSPL => tb_nSPL, nLIR => tb_nLIR, nLAL => tb_nLAL, 
			nLAH => tb_nLAH, nLDL => tb_nLDL, nLDH => tb_nLDH, nLPC => tb_nLPC, nPCC => tb_nPCC, nPCD => tb_nPCD, nPCZ => tb_nPCZ, nCLK2 => tb_nCLK2, nCLF => tb_nCLF, n_AND => tb_n_AND, n_OR => tb_n_OR, nROL => tb_nROL, nROR => tb_nROR, nJND => tb_nJND, nDATA => tb_nDATA, C => tb_C, Z => tb_Z, D => tb_D);

process
begin
	tb_input1 <= "1111111111111111";
	tb_input2 <= "0000000000000001";

	tb_nCMP <= '1';
	tb_nSUB <= '1'; 
	tb_nADD <= '1';
	tb_nSAL <= '1';
	tb_nSPL <= '1';
	tb_nLIR <= '1';
	tb_nLAL <= '1';
	tb_nLAH <= '1';
	tb_nLDL <= '1';
	tb_nLDH <= '1';
	tb_nLPC <= '1';
	tb_nPCC <= '1'; 
	tb_nPCD <= '1';
	tb_nPCZ <= '1';
	tb_nCLK2 <= '1'; 
	tb_nCLF <= '1';
	tb_n_AND <= '1';
	tb_n_OR <= '1';
	tb_nROL <= '1';
	tb_nROR <= '1';
	tb_nJND <= '1';
	tb_nDATA <= '1';

	wait for 1 ns;
	
	-- clf
	tb_nCLF <= '0';

	tb_nCLK2 <= '0';
	wait for 1 ns;
	tb_nCLK2 <= '1';
	wait for 5 ns;
	
	-- add instruction
	tb_nADD <= '0';
	tb_nCLF <= '1';	

	tb_nCLK2 <= '0';
	wait for 1 ns;
	tb_nCLK2 <= '1';
	wait for 5 ns;

	-- sub instruction
	tb_nSUB <= '0';
	tb_nADD <= '1';
	
	tb_nCLK2 <= '0';
	wait for 1 ns;
	tb_nCLK2 <= '1';
	wait for 5 ns;

	-- load instruction register
	tb_nSUB <= '1';
	tb_nLIR <= '0';

	tb_nCLK2 <= '0';
	wait for 1 ns;
	tb_nCLK2 <= '1';
	wait for 5 ns;
	
	wait;
end process;


end rtl;
