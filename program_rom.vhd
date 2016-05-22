--
--	Program memory
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity program_rom is

	port (
		data: inout std_logic_vector (7 downto 0);
		address: in std_logic_vector (15 downto 0);
		n_read, n_write, n_cs : std_logic
	);

end program_rom;

architecture rtl of program_rom is

	type RAM_ARRAY is array(0 to 255) of std_logic_vector(7 downto 0);

	
	
	signal ram : RAM_ARRAY := (
	
		-- test program
		--	LDSP	#$00f0		load the stack pointer
		--	LDA	$00fe		load the accumulator from address 0x00fe
		--	PUSHA			push the accumulator onto the stack
		--	LDA	$00fc		load the accumulator from address 0x00fc
		--	POPA			pop the accumulator from the stack
		--	CALL	$0010		call 0x0010
		--	HALT
		--	HALT
		-- 0x0010:
		--	INCA
		--	DECA
		--	XORI	#$ffff		XOR 0xffff with accumulator
		--	LDA	#$ddaa		load accumulator with immediate 0xaaaa
		--	AND	$00f8		and with memory at address 0x00f8
		--	ADD	#$ff66
		--	ADC	$00f8
		--	LDB	$00fe
		--	MOV	b,a
		--	STB	$00f0		overwrites return address
		--	LDB	#$ffff
		--	LDC	$00fc
		--	MOV	c,a
		--	MOV	a,b
		--	STC	$00f0
		--	LDC	#$aaaa
		-- 	MOV	a,c
		--	LDB	#$beef
		--      PUSHB
		-- 	POPC
		--	LDD	#$dead
		-- 	PUSHD
		--	POPB
		--      INCB
		--      INCC
		--      DECD
		--	LDB	#$00fe
		--	LDA	b
		--	DECB
		--	DECB
		--	XOR	b
		--	CLRF
		--	XOR	b,$0002
		--	LDB	#$00e8
		--	XOR	[b,$0006]		
		--	RET	

		x"10", x"F0", x"00", x"01", x"fe", x"00", x"11", x"01",	-- 00
		x"fc", x"00", x"12", x"13", x"10", x"00", x"AA", x"FF", -- 08
		x"15", x"16", x"17", x"FF", x"FF", x"18", x"AA", x"DD", -- 10
		x"1b", x"f8", x"00", x"07", x"66", x"ff", x"1e", x"f8", -- 18
		x"00", x"23", x"fe", x"00", x"25", x"26", x"f0", x"00", -- 20
		x"27", x"ff", x"ff", x"28", x"fc", x"00", x"2a", x"24", -- 28
		x"2b", x"f0", x"00", x"2c", x"aa", x"aa", x"29", x"27", -- 30
		x"ef", x"be", x"32", x"37", x"31", x"ad", x"de", x"3a", -- 38
		x"33", x"34", x"38", x"3d", x"27", x"fe", x"00", x"3e", -- 40
		x"35", x"35", x"47", x"0f", x"51", x"02", x"00", x"27", -- 48
		x"e8", x"00", x"5b", x"06", x"00", x"14", x"00", x"00", -- 50
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 58
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 60
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 68
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 70
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 78
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",-- 80
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 88
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",-- 90
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 98
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- a0
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- a8
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- b0
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- b8
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",-- c0
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- c8
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- d0
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- d8
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- e0
		x"00", x"00", x"00", x"00", x"00", x"00", x"fe", x"00", -- e8
		x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- f0
		x"ff", x"00", x"00", x"00", x"BA", x"DD", x"EC", x"AF"  -- f8
	);

	signal result : std_logic_vector(15 downto 0);
	signal add_instruction_arg : std_logic_vector (15 downto 0);
	signal working : std_logic_vector (15 downto 0);
	signal stack0: std_logic_vector (7 downto 0);
	signal stack1: std_logic_vector (7 downto 0);
	signal stack2: std_logic_vector (7 downto 0);
	signal stack3: std_logic_vector (7 downto 0);
	signal stack4: std_logic_vector (7 downto 0);
	signal stack5: std_logic_vector (7 downto 0);
	signal stack6: std_logic_vector (7 downto 0);
	signal stack7: std_logic_vector (7 downto 0);
	

begin


mem0:	process (n_read, n_write, n_cs, data, address)
	begin

	if n_cs = '0' then

		if rising_edge(n_write) then
			ram(to_integer(unsigned(address(7 downto 0)))) <= data;
		elsif n_read = '0' then
			data <= ram(to_integer(unsigned(address(7 downto 0))));
		else
			data <= (others => 'Z');
		end if;

	end if;	
	
	end process;

result(15 downto 8) <= ram(255);
result(7 downto 0) <= ram(254);
add_instruction_arg (15 downto 8) <= ram(16#2a#);
add_instruction_arg (7 downto 0) <= ram(16#29#);
working (15 downto 8) <= ram(16#FB#);
working (7 downto 0) <= ram(16#FA#);

stack0 <= ram(16#F0#);
stack1 <= ram(16#F1#);
stack2 <= ram(16#F2#);
stack3 <= ram(16#F3#);
stack4 <= ram(16#F4#);
stack5 <= ram(16#F5#);
stack6 <= ram(16#F6#);
stack7 <= ram(16#F7#);

end rtl;


