
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_tester is 
end counter_tester;

architecture rtl of counter_tester is

	component counter 
		generic (
			WIDTH: integer
			);

		port ( 	clk : in std_logic;
			output : out std_logic_vector (WIDTH - 1 downto 0);
			nreset : in std_logic );
 	end component;

	constant BITS : integer := 4;
	signal tb_clk, tb_reset : std_logic;
	signal tb_ctr_out : std_logic_vector (BITS - 1 downto 0); 

begin

ctr0:	counter generic map (WIDTH => BITS) port map (clk => tb_clk, nreset => tb_reset, output => tb_ctr_out);

process
begin
	tb_reset <= '0';

	tb_clk <= '0';	
	wait for 5 ns;
	tb_clk <= '1';
	wait for 5 ns;
	tb_clk <= '0';	
	wait for 5 ns;

	tb_reset <= '1';

	for i in 0 to 14 loop
		tb_clk <= '1';	
		wait for 5 ns;
		tb_clk <= '0';
		wait for 5 ns;
	end loop;
		
	wait;
end process;

end rtl;	
