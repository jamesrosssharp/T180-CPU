
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is 

	generic (
		WIDTH: integer
		);

	port ( 	clk : in std_logic;
		output : out std_logic_vector (WIDTH - 1 downto 0);
		nreset : in std_logic );

end counter;

architecture rtl of counter is

	signal reg : unsigned (WIDTH - 1 downto 0) := (others => '0');

begin

	process (clk)
	begin
		if (clk'event and clk = '1') then

		if nreset = '0' then
			reg <= (others => '0');
		else		
			reg <= reg + 1;
		end if;
		end if;
	end process;

	output <= std_logic_vector(reg);

end rtl;
