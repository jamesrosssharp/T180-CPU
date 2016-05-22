library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_sequencer_tester is
end instruction_sequencer_tester;

architecture rtl of instruction_sequencer_tester is

 component instruction_sequencer 
	port (
			clk1: in std_logic;
			clk2: in std_logic;	
			input: in std_logic_vector(7 downto 0);
			nRST: in std_logic;
			nSTART: in std_logic;
			control_signals: out std_logic_vector(255 downto 0)
		);
  end component;

  component clock_gen
	port (
			clk: in std_logic;
			clk1: out std_logic;
			clk2: out std_logic
		);
  end component;
	
  signal tb_clk, tb_clk1, tb_clk2, tb_nrst, tb_nstart : std_logic := '1';
  signal instruction_reg_in : std_logic_vector (7 downto 0);
  signal tb_control_signals: std_logic_vector(255 downto 0);

begin

cg0:	clock_gen port map (clk=>tb_clk, clk1 => tb_clk1, clk2 => tb_clk2);
is0:	instruction_sequencer port map (clk1 => tb_clk1, clk2 => tb_clk2, input => instruction_reg_in, control_signals => tb_control_signals, nRST => tb_nrst, nSTART => tb_nstart);

process
begin

	tb_clk <= '1';	
	wait for 5 ns;
	tb_clk <= '0';
	wait for 5 ns;

	tb_nrst <= '0';
	tb_nstart <= '1';
	instruction_reg_in <= x"0F";

	for i in 0 to 3 loop
		tb_clk <= '1';	
		wait for 5 ns;
		tb_clk <= '0';
		wait for 5 ns;
	end loop;
	
	tb_nrst <= '1';
	tb_nstart <= '0';

	for i in 0 to 3 loop
		tb_clk <= '1';	
		wait for 5 ns;
		tb_clk <= '0';
		wait for 5 ns;
	end loop;

	tb_nstart <= '1';

	for i in 0 to 7 loop
		tb_clk <= '1';	
		wait for 5 ns;
		tb_clk <= '0';
		wait for 5 ns;
	end loop;

	instruction_reg_in <= x"07";

	for i in 0 to 15 loop
		tb_clk <= '1';	
		wait for 5 ns;
		tb_clk <= '0';
		wait for 5 ns;
	end loop;

	instruction_reg_in <= x"02";

	for i in 0 to 19 loop
		tb_clk <= '1';	
		wait for 5 ns;
		tb_clk <= '0';
		wait for 5 ns;
	end loop;
		
	wait;
end process;


end rtl;
