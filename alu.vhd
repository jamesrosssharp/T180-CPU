--
--	ALU
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	port (
			input1 : in std_logic_vector (15 downto 0);
			input2 : in std_logic_vector (15 downto 0);
			output : out std_logic_vector (15 downto 0);
			control_signals : in std_logic_vector(255 downto 0);
			nCLK1, nCLK2: in std_logic;
			C, Z, D: out std_logic
		);
end alu;

architecture rtl of alu is
	signal	neg_input_2: std_logic_vector (15 downto 0);
	signal	alu_add_input_1: std_logic_vector (15 downto 0);
	signal  alu_add_out: std_logic_vector (15 downto 0);
	signal  alu_and_out: std_logic_vector (15 downto 0);
	signal  alu_or_out: std_logic_vector (15 downto 0);
	signal  alu_rol_out: std_logic_vector (15 downto 0);
	signal  alu_ror_out: std_logic_vector (15 downto 0);
	signal  alu_xor_out: std_logic_vector (15 downto 0);

	signal	alu_out: std_logic_vector (15 downto 0);
		
	signal  c_out_adder: std_logic;
	signal  c_out_rol: std_logic;
	signal  c_out_ror: std_logic;
	signal  carry : std_logic;
	
	signal  zero : std_logic;	
	
	signal	sig1 : std_logic;
	signal	sig2 : std_logic;

	#include "control-signals.txt"

begin


neg_input_2_0: process (input2)
		variable neg : unsigned (input2'range);	
	begin
	neg := unsigned(not input2) + 1;
	neg_input_2 <= std_logic_vector(neg);

	end process;


-- main adder

add0: process (input1, input2, neg_input_2, nCMP, nSUB, nADD, sig1, carry, nDECSP, nLASPH, nLSPDH, nINCA, nDECA, nADC, nSBB, 
		nLBSPH, nLCSPH, nLDSPH, nDECB, nDECC, nDECD)
		variable add1: unsigned (16 downto 0);
		variable add2: unsigned (16 downto 0);
		variable add3: unsigned (16 downto 0);
		variable addout : unsigned (16 downto 0);
	begin
	
	add1 := "00000000000000000";
	add2 := "00000000000000000";
	add3 := "00000000000000000";

	if (nCMP and nSUB and nSBB) = '0' then
		add1 := '0' & unsigned(neg_input_2);
	elsif (nADD and sig1 and nDECSP and nLASPH and nLSPDH and nADC and nDECB and nDECC and nDECD) = '0' then
		add1 := '0' & unsigned(input2);
	elsif (nINCA) = '0' then
		add1 := "00000000000000001";
	elsif (nDECA) = '0' then
		add1 := "11111111111111111";
	end if;

	if (nCMP and nSUB and nADD and nINCA and nDECA and nADC and nSBB) = '0' then
		add2 := '0' & unsigned(input1);
	elsif sig1 = '0' then			-- increment input 2 operation
		add2 := "00000000000000001";
	elsif (nDECSP and nLASPH and nLSPDH and nLBSPH and nLCSPH and nLDSPH and nDECB and nDECC and nDECD) = '0' then	-- decrement input 2 operation
		add2 := "11111111111111111";
	end if;

	-- carry in
	if nADC = '0' then
		add3 := x"0000" & carry;
	end if;

	if nSBB = '0' then
		if carry = '1' then
			add3 := "11111111111111111";
		end if;
	end if;

	addout := add1 + add2 + add3;

	alu_add_out <= std_logic_vector(addout(15 downto 0));
	c_out_adder <= std_logic(addout(16));

	end process;	

-- and

and0: process (input1, input2)
	begin
	   alu_and_out <= input1 and input2;	
	end process;

-- or

or0: process (input1, input2)
	begin
	   alu_or_out <= input1 or input2;	
	end process;

-- xor

xor0: process (input1, input2)
	begin
	   alu_xor_out <= input1 xor input2;
	end process;

-- rol

rol0: process (input1,  carry)
	begin
	   alu_rol_out <=  input1(14 downto 0) & carry;
	   c_out_rol <= input1(15);
	end process;

-- ror

ror0: process (input1, carry)
	begin
	   c_out_ror <= input1(0);
	   alu_ror_out <= carry & input1(15 downto 1);	
	end process;

-- mux

mux0:	process (input2, nCMP, nSUB, nADD, nDECSP, nLASPH, nLSPDH, nINCA, nDECA,
		sig1, n_OR, n_AND, nROL, nROR, nXOR, sig2, nADC, nSBB, nINCB, nINCC,
		nINCD, nDECB, nDECC, nDECD, alu_add_out, alu_and_out, alu_or_out, alu_rol_out, alu_ror_out)
	begin
		if (sig1 and nCMP and nSUB and nADD and 
		    nDECSP and nLASPH and nLSPDH and nINCA and nDECA and
		    nADC and nSBB and nINCB and nDECB and nINCC and nDECC and
		    nINCD and nDECD) = '0' then
			alu_out <= alu_add_out;
		elsif sig2 = '0' then
			alu_out <= input2;
		elsif n_AND = '0' then
			alu_out <= alu_and_out;
		elsif n_OR = '0' then
			alu_out <= alu_or_out; 
		elsif nROL = '0' then
			alu_out <= alu_rol_out;
		elsif nROR = '0' then
			alu_out <= alu_ror_out;
		elsif nXOR = '0' then
			alu_out <= alu_xor_out;
		end if;

	end process;


-- carry flag

carry0:	process (c_out_adder, c_out_rol, c_out_ror, nROL, nROR, nSUB, nADD, nCMP, nCLK2, nCLF)
	begin
	
	    if nCLK2'event and nCLK2 = '1' then
		if nCLF = '0' then
			carry <= '0';
		elsif (nSUB and nADD and nCMP) = '0' then
			carry <= c_out_adder;
		elsif nROL = '0' then
			carry <= c_out_rol;
		elsif nROR = '0' then
			carry <= c_out_ror;
		end if;
	    end if;

	end process;

-- zero flag

zero0:  process (alu_out, nROL, nROR, nSUB, nADD, n_AND, n_OR, nCMP, nCLK2, nCLF)
	begin	 

	   if nCLK2'event and nCLK2 = '1' then
		if nCLF = '0' then
			zero <= '0';
		elsif (nROL and nROR and nSUB and nADD and n_AND and n_OR and nCMP) = '0' then
			if (alu_out(0) = '0') and (alu_out(1) = '0') and (alu_out(2) = '0') and
			   (alu_out(3) = '0') and (alu_out(4) = '0') and (alu_out(5) = '0') and
			   (alu_out(6) = '0') and (alu_out(7) = '0') and 
			   (alu_out(8) = '0') and (alu_out(9) = '0') and (alu_out(10) = '0') and
			   (alu_out(11) = '0') and (alu_out(12) = '0') and (alu_out(13) = '0') and
			   (alu_out(14) = '0') and (alu_out(15) = '0') 
			   then
				zero <= '1';
			else
				zero <= '0';			
			end if;
		end if;	
	   end if;

	end process;

-- concurrent statements

sig1 <= nSAL and nSPL and nLIR and nLAL and nLAH and nLDL and nLDH and -- determines if we are incrementing input 2
	nLSPL and nLSPH and nSSPAL and nSSPAH and nSSPCL and nSSPCH and 
	nLAIL and nLAIH and nLD2L and nLD2H and nLDD2L and nLDD2H and
	nLBL and nLBH and nSBL and nSBH and nLBIL and nLBIH and 
	nLCL and nLCH and nLDDL and nLDDH and nSCL and nSCH and 
	nSDL and nSDH and nLCIL and nLCIH and nLDIL and nLDIH and 
	nSSPBL and nSSPBH and nSSPCCL and nSSPCCH and nSSPDL and nSSPDH and nINCB and nINCC and nINCD and nLD2DL;



sig2 <= nLPC and nPCC and nPCD and nPCZ;

#include "control-lines.txt"

C <= carry;
Z <= zero;

output <= alu_out;

end rtl; 
