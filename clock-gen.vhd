--
--	CPU clock generator
--

library ieee;
use 	ieee.std_logic_1164.all;

entity clock_gen is

	port (
			clk: in std_logic;
			clk1: out std_logic;
			clk2: out std_logic
		);

end clock_gen;

architecture rtl of clock_gen is

signal state : std_logic_vector (1 downto 0) := "00";

begin

process (clk)
	begin
	if clk'event and clk = '1' then
		if state = "00" then
			clk1 <= '0';
			clk2 <= '0';
			state <= "01";
		elsif state = "01" then
			clk1 <= '1';
			clk2 <= '0';
			state <= "10";
		elsif state = "10" then
			clk1 <= '0';
			clk2 <= '0';
			state <= "11";
		elsif state = "11" then
			clk1 <= '0';
			clk2 <= '1';
			state <= "00";
		end if;
	end if;

end process;	

end rtl;
