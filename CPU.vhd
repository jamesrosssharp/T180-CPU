--
--	CPU top level
--

library ieee;
use ieee.std_logic_1164.all;


entity cpu is

	port (

		cpu_clk: in std_logic;
		cpu_nRST: in std_logic;	
		cpu_nSTART: in std_logic;
		cpu_address_bus: out std_logic_vector(15 downto 0);
		cpu_data_bus: inout std_logic_vector(7 downto 0);
		cpu_nwrite: out std_logic;
		cpu_nread : out std_logic

	);

end cpu;

architecture rtl of cpu is

	component clock_gen 
		port (
			clk: in std_logic;
			clk1: out std_logic;
			clk2: out std_logic
		);
	end component;

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

	component alu
		port (
			input1 : in std_logic_vector (15 downto 0);
			input2 : in std_logic_vector (15 downto 0);
			output : out std_logic_vector (15 downto 0);
			control_signals : in std_logic_vector(255 downto 0);
			nCLK1, nCLK2: in std_logic;
			C, Z, D: out std_logic
		);
	end component;

	component accumulator
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
	end component;

	component program_counter
		port (
			alu_output: in std_logic_vector (15 downto 0);
			pc_out: out std_logic_vector (15 downto 0);
			address_out: out std_logic_vector (15 downto 0);
			data_out: out std_logic_vector (7 downto 0);
			nRST, nCLK2, nCLK1: in std_logic;
			control_signals : in std_logic_vector(255 downto 0);
			C, Z, D: in std_logic
		);
	end component;

	component data_address_register
		port (
			data_in : in std_logic_vector (7 downto 0);
			alu_output: in std_logic_vector (15 downto 0);
			data_out: out std_logic_vector (15 downto 0);
			address_out: out std_logic_vector (15 downto 0);
			effective_address_in: in std_logic_vector (15 downto 0);
			nCLK1, nCLK2: in std_logic;
			control_signals : in std_logic_vector(255 downto 0)
		);
	end component;

	component data_address_register_2
		port (
			data_in : in std_logic_vector (7 downto 0);
			alu_output: in std_logic_vector (15 downto 0);
			data_out: out std_logic_vector (15 downto 0);
			address_out: out std_logic_vector (15 downto 0);
			effective_address_in: in std_logic_vector (15 downto 0);
			nCLK1, nCLK2: in std_logic;
			control_signals : in std_logic_vector(255 downto 0)
		);
	end component;

	component stack_pointer
		port (
			data_in : in std_logic_vector (7 downto 0);
			alu_output: in std_logic_vector (15 downto 0);
			data_out: out std_logic_vector (15 downto 0);
			address_out: out std_logic_vector (15 downto 0);
			nCLK1, nCLK2: in std_logic;
			control_signals : in std_logic_vector(255 downto 0)
		);
	end component;

	component generic_register
		port (
			data_in : in std_logic_vector (7 downto 0);
			data_out: out std_logic_vector (7 downto 0);
			register_out: out std_logic_vector (15 downto 0);
			accumulator_out: in std_logic_vector (15 downto 0);
			address_out: out std_logic_vector (15 downto 0);
			alu_out: in std_logic_vector (15 downto 0);
			nCLK1, nCLK2: in std_logic;
			nLD_LOW, nLD_HI, nLD_ACC, nST_LOW, nST_HI, nLD_ALU: in std_logic
		);
	end component;

	component effective_address_unit
		port (
			b_register: in std_logic_vector (15 downto 0);
			c_register: in std_logic_vector (15 downto 0);
			d_register: in std_logic_vector (15 downto 0);

			da_register: in std_logic_vector (15 downto 0);

			output: out std_logic_vector (15 downto 0);

			carry: in std_logic;

			clk1, clk2: in std_logic;
		
			control_signals : in std_logic_vector(255 downto 0)
		);
	end component;

	signal cpu_clk1: std_logic;
	signal cpu_clk2: std_logic;
	signal control_signals: std_logic_vector(255 downto 0);
	signal cpu_memory_out: std_logic_vector(7 downto 0);
	signal cpu_memory_in: std_logic_vector(7 downto 0);
	signal cpu_address_in: std_logic_vector(15 downto 0);

	#include "control-signals.txt"

	signal  cpu_C : std_logic;
	signal  cpu_nDATA : std_logic;
	signal  cpu_D: std_logic;
	signal	cpu_Z: std_logic;
	signal	cpu_nJND: std_logic;

	signal	cpu_alu_input1: std_logic_vector(15 downto 0);
	signal	cpu_alu_input2: std_logic_vector(15 downto 0);
	signal	cpu_alu_output: std_logic_vector(15 downto 0);

	signal cpu_accu_data_out : std_logic_vector (7 downto 0);
	
	signal cpu_pc_out: std_logic_vector(15 downto 0);
	signal cpu_pc_address_out: std_logic_vector(15 downto 0);
	signal cpu_pc_data_out: std_logic_vector (7 downto 0);

	signal cpu_da_data_out: std_logic_vector (15 downto 0);
	signal cpu_da_address_out: std_logic_vector (15 downto 0);

	signal cpu_sp_data_out: std_logic_vector (15 downto 0);
	signal cpu_sp_address_out: std_logic_vector (15 downto 0);

	signal cpu_da2_data_out: std_logic_vector (15 downto 0);
	signal cpu_da2_address_out: std_logic_vector (15 downto 0);

	signal cpu_accu_output: std_logic_vector (15 downto 0);

	signal cpu_b_register_out: std_logic_vector (15 downto 0);
	signal cpu_b_address_out: std_logic_vector (15 downto 0);
	signal cpu_b_ld_low: std_logic;
	signal cpu_b_ld_hi: std_logic;
	signal cpu_b_ld_acc: std_logic;
	signal cpu_b_st_low: std_logic;
	signal cpu_b_st_hi: std_logic;
	signal cpu_b_data_out: std_logic_vector (7 downto 0);
	signal cpu_b_ld_alu: std_logic;

	signal cpu_c_register_out: std_logic_vector (15 downto 0);
	signal cpu_c_address_out: std_logic_vector (15 downto 0);
	signal cpu_c_ld_low: std_logic;
	signal cpu_c_ld_hi: std_logic;
	signal cpu_c_ld_acc: std_logic;
	signal cpu_c_st_low: std_logic;
	signal cpu_c_st_hi: std_logic;
	signal cpu_c_data_out: std_logic_vector (7 downto 0);
	signal cpu_c_ld_alu: std_logic;

	signal cpu_d_register_out: std_logic_vector (15 downto 0);
	signal cpu_d_address_out: std_logic_vector (15 downto 0);
	signal cpu_d_ld_low: std_logic;
	signal cpu_d_ld_hi: std_logic;
	signal cpu_d_ld_acc: std_logic;
	signal cpu_d_st_low: std_logic;
	signal cpu_d_st_hi: std_logic;
	signal cpu_d_data_out: std_logic_vector (7 downto 0);
	signal cpu_d_ld_alu: std_logic;

	signal cpu_accu_register_in: std_logic_vector (15 downto 0);

	signal cpu_effective_address:	std_logic_vector (15 downto 0);
	

begin

clk0:	clock_gen port map (clk => cpu_clk, clk1 => cpu_clk1, clk2 => cpu_clk2);

inst0:	instruction_sequencer port map (clk1 => cpu_clk1, clk2 => cpu_clk2, input => cpu_memory_out, nRST => cpu_nRST, nSTART => cpu_nSTART, control_signals => control_signals);


alu0:   alu port map (input1 => cpu_alu_input1, input2 => cpu_alu_input2, output => cpu_alu_output,
			nCLK1 => cpu_clk1,  nCLK2 => cpu_clk2,  
			control_signals => control_signals,
			C => cpu_C, Z => cpu_Z, D => cpu_D
		);

cpu_alu_input1 <= cpu_accu_output;

accu0:  accumulator port map (nRST => cpu_nRST, data_in => cpu_memory_out, 
			data_out => cpu_accu_data_out,
			alu_output => cpu_alu_output,
			register_in => cpu_accu_register_in,
			accumulator_output => cpu_accu_output,
			nCLK1 => cpu_clk1,  nCLK2 => cpu_clk2, control_signals => control_signals
		);

sp0:	 stack_pointer	port map (
			data_in => cpu_memory_out,
			alu_output => cpu_alu_output,
			data_out => cpu_sp_data_out,
			address_out => cpu_sp_address_out,
			nCLK1 => cpu_clk1, nCLK2 => cpu_clk2, control_signals => control_signals
		);

pc0:	program_counter port map (nRST => cpu_nRST, alu_output => cpu_alu_output,
			pc_out => cpu_pc_out,
			address_out => cpu_pc_address_out,
			data_out => cpu_pc_data_out,
			nCLK2 => cpu_clk2, 
			nCLK1 => cpu_clk1, control_signals => control_signals,
			C => cpu_C, Z => cpu_Z, D => cpu_D
		);

da0:	data_address_register port map (
			data_in => cpu_memory_out,
			alu_output => cpu_alu_output,
			data_out => cpu_da_data_out,
			address_out => cpu_da_address_out,
			effective_address_in => cpu_effective_address,
			nCLK1 => cpu_clk1,  nCLK2 => cpu_clk2, control_signals => control_signals
		);

da1:	data_address_register_2 port map (
			data_in => cpu_memory_out,
			alu_output => cpu_alu_output,
			data_out => cpu_da2_data_out,
			address_out => cpu_da2_address_out,
			effective_address_in => cpu_effective_address,
			nCLK1 => cpu_clk1,  nCLK2 => cpu_clk2, control_signals => control_signals
		);

addr0: effective_address_unit port map (
			b_register => cpu_b_register_out,
			c_register => cpu_c_register_out,
			d_register => cpu_d_register_out,
			da_register => cpu_da_data_out,
			output => cpu_effective_address,
			carry => cpu_C,
			clk1 => cpu_clk1, clk2 => cpu_clk2,
			control_signals => control_signals
		);

-- "b" register


cpu_b_ld_low <= nLBL and nLBIL and nLBSPL;
cpu_b_ld_hi <= nLBH and nLBIH and nLBSPH;
cpu_b_ld_acc <= nMOVAB;
cpu_b_st_low <= nSBL and nSSPBL;
cpu_b_st_hi  <= nSBH and nSSPBH;
cpu_b_ld_alu <= nINCB and nDECB;

breg:	generic_register
		port map (
			data_in => cpu_memory_out,
			data_out => cpu_b_data_out,
			register_out => cpu_b_register_out,
			accumulator_out =>  cpu_accu_output,
			address_out => cpu_b_address_out,
			alu_out => cpu_alu_output,
			nCLK1 => cpu_clk1, nCLK2 => cpu_clk2,
			nLD_LOW => cpu_b_ld_low, nLD_HI => cpu_b_ld_hi, 
			nLD_ACC => cpu_b_ld_acc, nST_LOW => cpu_b_st_low, 
			nST_HI => cpu_b_st_hi, nLD_ALU => cpu_b_ld_alu
		);

-- "c" register

cpu_c_ld_low <= nLCL and nLCIL and nLCSPL;
cpu_c_ld_hi <= nLCH and nLCIH and nLCSPH;
cpu_c_ld_acc <= nMOVAC;
cpu_c_st_low <= nSCL and nSSPCCL;
cpu_c_st_hi  <= nSCH and nSSPCCH;
cpu_c_ld_alu <= nINCC and nDECC;

creg:	generic_register
		port map (
			data_in => cpu_memory_out,
			data_out => cpu_c_data_out,
			register_out => cpu_c_register_out,
			accumulator_out =>  cpu_accu_output,
			address_out => cpu_c_address_out,
			alu_out => cpu_alu_output,
			nCLK1 => cpu_clk1, nCLK2 => cpu_clk2,
			nLD_LOW => cpu_c_ld_low, nLD_HI => cpu_c_ld_hi, 
			nLD_ACC => cpu_c_ld_acc, nST_LOW => cpu_c_st_low, 
			nST_HI => cpu_c_st_hi, nLD_ALU => cpu_c_ld_alu
		);

-- "d" register

cpu_d_ld_low <= nLDDL and nLDIL and nLDSPL;
cpu_d_ld_hi <= nLDDH and nLDIH and nLDSPH;
cpu_d_ld_acc <= nMOVAD;
cpu_d_st_low <= nSDL and nSSPDL;
cpu_d_st_hi  <= nSDH and nSSPDH;
cpu_d_ld_alu <= nINCD and nDECD;

dreg:	generic_register
		port map (
			data_in => cpu_memory_out,
			data_out => cpu_d_data_out,
			register_out => cpu_d_register_out,
			accumulator_out =>  cpu_accu_output,
			address_out => cpu_d_address_out,
			alu_out => cpu_alu_output,
			nCLK1 => cpu_clk1, nCLK2 => cpu_clk2,
			nLD_LOW => cpu_d_ld_low, nLD_HI => cpu_d_ld_hi, 
			nLD_ACC => cpu_d_ld_acc, nST_LOW => cpu_d_st_low, 
			nST_HI => cpu_d_st_hi, nLD_ALU => cpu_d_ld_alu
		);


-- muxes

-- address mux
--
--	controls memory address input
--
mux0:	process (cpu_da_address_out, cpu_pc_address_out, cpu_sp_address_out, nSAL, nSAH, nSPL, nSPH, nLAL, 
		 nLAH, nLIR, nLDL, nLDH, nLSPL, nLSPH, nSSPAL, nSSPAH, nLASPH, nLASPL, nSSPCL, nSSPCH, 
		 nLSPDH, nLSPDL, nLAIL, nLAIH, nLD2L, nLD2H, nLDD2L, nLDD2H, nLBL, nLBH, nSBL, nSBH, 
		 nLBIL, nLBIH, nLCL, nLCH, nLDDL, nLDDH, nSCL, nSCH, nSDL, nSDH, nLCIL, nLCIH, nLDIL, 
		 nLDIH, nSSPBL, nSSPBH, nLBSPH, nLBSPL, nSSPCCL, nSSPCCH, nLCSPH, nLCSPL, nSSPDL, 
		 nSSPDH, nLDSPH, nLDSPL, nLD2DL, nLD2DH)
	begin

	if (nSAL and nSAH and nSPL and nSPH and nLAL and nLAH and nLBL and nLBH and nSBL and nSBH and
	    nLCL and nLCH and nLDDL and nLDDH and nSCL and nSCH and nSDL and nSDH and nLD2DL and nLD2DH) = '0' then
		cpu_address_in <= cpu_da_address_out;
	elsif (nLIR and nLDL and nLDH and nLSPL and nLSPH and nLAIL and nLAIH and nLD2L and nLD2H and
	       nLBIL and nLBIH and nLCIL and nLCIH and nLDIL and nLDIH) = '0' then
		cpu_address_in <= cpu_pc_address_out;
	elsif (nSSPAL and nSSPAH and nLASPH and nLASPL and nSSPCL and nSSPCH and nLSPDH and nLSPDL and
		nSSPBL and nSSPBH and nLBSPH and nLBSPL and nSSPCCL and nSSPCCH and nLCSPH and nLCSPL and
		 nSSPDL and nSSPDH and nLDSPH and nLDSPL) = '0' then
		cpu_address_in <= cpu_sp_address_out; 
	elsif (nLDD2L and nLDD2H) = '0' then
		cpu_address_in <= cpu_da2_address_out;
	else 
		cpu_address_in <= "0000000000000000";
	end if;

	end process; 

-- memory input mux
--
--	controls data placed on memory bus
--
mux1:	process (cpu_accu_data_out, cpu_pc_data_out, cpu_b_data_out, cpu_c_data_out, cpu_d_data_out, nSPL, nSPH, nSAL, nSAH, nSSPAL, 
		 nSSPAH, nSSPCL, nSSPCH, nSBL, nSBH, nSCL, nSCH, nSDL, nSDH, nSSPBL, nSSPBH, nSSPCCL, nSSPCCH, 
		 nSSPDL, nSSPDH) 
	begin	
	if (nSPL and nSPH and nSSPCL and nSSPCH) = '0' then
		cpu_memory_in <= cpu_pc_data_out;
	elsif	(nSAL and nSAH and nSSPAL and nSSPAH) = '0' then	-- if storing accumulator or pushing accumulator onto the stack, memory bus
											-- driven from accumulator
		cpu_memory_in <= cpu_accu_data_out;
	elsif   (nSBL and nSBH and nSSPBL and nSSPBH) = '0' then
		cpu_memory_in <= cpu_b_data_out;	
	elsif	(nSCL and nSCH and nSSPCCL and nSSPCCH) = '0' then
		cpu_memory_in <= cpu_c_data_out;
	elsif	(nSDL and nSDH and nSSPDL and nSSPDH) = '0' then
		cpu_memory_in <= cpu_d_data_out;
	else
		cpu_memory_in <= "00000000";
	end if;
	end process;

-- alu input2 mux
--
--	controls second alu input
--
mux2:	process (cpu_pc_out, cpu_da_data_out, cpu_sp_data_out, 
		nLIR, nLDL, nLDH, nCMP, nPCZ, nPCD, nPCC, nLPC, 
		n_OR, n_AND, nADD, nSUB, nSAL, nSPL, nLAL, 
		nLSPL, nLSPH, nSSPAL, nSSPAH, nDECSP, nLASPH, 
		nSSPCL, nSSPCH, nLSPDH, nLSPDL, nXOR, nLAIL, nLAIH, 
		nLD2L, nLD2H, nLDD2L, nLDD2H, nADC, nSBB, nLBL, nLBH,
		nSBL, nSBH, nLBIL, nLBIH, nLCL, nLCH, nLDDL, nLDDH, 
		nSCL, nSCH, nSDL, nSDH, nLCIL, nLCIH, nLDIL, nLDIH, 
		nSSPBL, nSSPBH, nLBSPH, nLBSPL, nSSPCCL, nSSPCCH, nLCSPH, nLCSPL, nSSPDL, 
		nSSPDH, nLDSPH, nLDSPL, nINCB, nDECB, nINCC, nDECC, nINCD, nDECD, 
		nLD2DL, nLD2DH	
		)
	begin
	if (nLIR and nLDL and nLDH and nLSPL and nLSPH and nLAIL and nLAIH and 
	    nLD2L and nLD2H and nLBIL and nLBIH and nLCIL and nLCIH and nLDIL and
	    nLDIH) = '0' then
		cpu_alu_input2 <= cpu_pc_out;
	elsif (nCMP and nPCZ and nPCD and nPCC and nLPC and n_OR and n_AND and 
	       nADD and nSUB and nSAL and nSPL and nLAL and nXOR and nADC and
	       nSBB and nLBL and nLBH and nSBL and nSBH and nLCL and nLCH and
	       nLDDL and nLDDH and nSCL and nSCH and nSDL and nSDH and
	       nLD2DL and nLD2DH) = '0' then
		cpu_alu_input2 <= cpu_da_data_out;
	elsif (nSSPAL and nSSPAH and nDECSP and nLASPH and nSSPCL and nSSPCH and nLSPDH and
	       nSSPBL and nSSPBH and nLBSPH and nLBSPL and nSSPCCL and nSSPCCH and nLCSPH and nLCSPL and nSSPDL and 
		nSSPDH and nLDSPH and nLDSPL) = '0' then
		cpu_alu_input2 <= cpu_sp_data_out;
	elsif (nLDD2L and nLDD2H) = '0' then
		cpu_alu_input2 <= cpu_da2_data_out;
	elsif (nINCB and nDECB) = '0' then
		cpu_alu_input2 <= cpu_b_register_out;
	elsif (nINCC and nDECC) = '0' then
		cpu_alu_input2 <= cpu_c_register_out;
	elsif (nINCD and nDECD) = '0' then
		cpu_alu_input2 <= cpu_d_register_out;
	else
		cpu_alu_input2 <= "0000000000000000";
	end if;
	end process;

--
--	accumulator register input
--
mux3:	process (nMOVBA, nMOVCA, nMOVDA)
	begin
	if nMOVBA = '0' then
		cpu_accu_register_in <=  cpu_b_register_out;
	elsif nMOVCA = '0' then
		cpu_accu_register_in <= cpu_c_register_out;
	elsif nMOVDA = '0' then
		cpu_accu_register_in <= cpu_d_register_out;
	end if;
	end process;
	


-- memory bus control
--
--	Generates read and write strobe signals for external memory
--
--

cpu_address_bus <= cpu_address_in;

membus: process (cpu_clk2, nSAL, nSAH, nSPL, nSPH, cpu_clk1, 
		 nLIR, nLAL, nLAH, nLDL, nLDH,  
		 nSSPAL, nSSPAH, nLASPL, nLASPH,
		 nSSPCL, nSSPCH, nLSPDH, nLSPDL,
		 nLAIL, nLAIH, nLD2L, nLD2H, nLDD2L, 
		 nLDD2H, nLBL, nLBH, nSBL, nSBH,
		 nLBIL, nLBIH, nLCL, nLCH, nLDDL,
		 nLDDH, nSCL, nSCH, nSDL, nSDH, nLCIL,
		 nLCIH, nLDIL, nLDIH, nSSPBL, nSSPBH, 
		 nLBSPH, nLBSPL, nSSPCCL, nSSPCCH, 
		 nLCSPH, nLCSPL, nSSPDL, nSSPDH, nLDSPH, nLDSPL,
		 nLD2DL, nLD2DH,
		 cpu_memory_in, cpu_data_bus)
	begin

	if (nSAL and nSAH and nSPL and nSPH and nSSPAL and nSSPAH and nSSPCL and nSSPCH and
	    nSBL and nSBH and nSCL and nSCH and nSDL and nSDH and nSSPBL and nSSPBH and 
	    nSSPCCL and nSSPCCH and nSSPDL and nSSPDH) = '0' 
	    then	-- memory write
			-- TODO: check memory timing
		cpu_data_bus <= cpu_memory_in;
		cpu_nread <= '1';
		cpu_nwrite <= not cpu_clk1;
	elsif (nLIR and nLAL and nLAH and nLDL and nLDH and 
	       nLSPL and nLSPH and nLASPL and nLASPH and nLSPDL and 
	       nLSPDH and nLAIL and nLAIH and nLD2L and nLD2H and
	       nLDD2L and nLDD2H and nLBL and nLBH and nLBIL and 
	       nLBIH and nLCL and nLCH and nLDDL and nLDDH and
	       nLCIL and nLCIH and nLDIL and nLDIH and nLBSPH and nLBSPL and
	       nLCSPH and nLCSPL and nLDSPH and nLDSPL and nLD2DL and nLD2DH) = '0' 
	    then 	-- memory read
		cpu_data_bus <= (others => 'Z');
		cpu_nread <= '0';
		cpu_nwrite <= '1';
		if rising_edge(cpu_clk1) then
			cpu_memory_out <= cpu_data_bus;
		end if;
	else		-- else don't drive the bus 
		cpu_data_bus <= (others => 'Z');
		cpu_nwrite <= '1';
		cpu_nread <= '1';
	end if;	

	end process;


-- concurrent statements

#include "control-lines.txt"

end rtl;
