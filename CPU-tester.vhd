--
--	CPU test bench
--

library ieee;
use 	ieee.std_logic_1164.all;

entity cpu_tester is 
end cpu_tester;

architecture rtl of cpu_tester is 

	component cpu 
		port (

		cpu_clk: in std_logic;
		cpu_nRST: in std_logic;	
		cpu_nSTART: in std_logic;
		cpu_address_bus: out std_logic_vector(15 downto 0);
		cpu_data_bus: inout std_logic_vector(7 downto 0);
		cpu_nwrite: out std_logic;
		cpu_nread : out std_logic	

	);
	end component;

	component program_rom
		port (
			data: inout std_logic_vector (7 downto 0);
			address: in std_logic_vector (15 downto 0);
			n_read, n_write, n_cs : std_logic
		);
	end component;

	signal tb_clk, tb_reset, tb_start : std_logic;
	signal tb_address_bus: std_logic_vector(15 downto 0);
	signal tb_data_bus: std_logic_vector(7 downto 0);
	signal tb_nwrite, tb_nread : std_logic;

begin

cpu0: cpu port map (cpu_clk => tb_clk, cpu_nRST => tb_reset, cpu_nSTART => tb_start, cpu_address_bus => tb_address_bus, cpu_data_bus => tb_data_bus, cpu_nwrite => tb_nwrite, cpu_nread => tb_nread);

mem0: program_rom port map (data => tb_data_bus, address => tb_address_bus, n_cs => '0', n_read => tb_nread, n_write => tb_nwrite);

process
begin
	tb_reset <= '0';

	tb_start <= '0';

	tb_clk <= '0';	
	wait for 5 ns;
	tb_clk <= '1';
	wait for 5 ns;
	tb_clk <= '0';	
	wait for 5 ns;
	
	tb_reset <= '1';

	for i in 0 to 3 loop
		tb_clk <= '1';
		wait for 5 ns;
		tb_clk <= '0';	
		wait for 5 ns;
	end loop;

	tb_start <= '1';

	for i in 0 to 1023 loop
		tb_clk <= '1';	
		wait for 5 ns;
		tb_clk <= '0';
		wait for 5 ns;
	end loop;

	wait;

end process;

end rtl;
