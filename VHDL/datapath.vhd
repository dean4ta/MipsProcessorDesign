library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is  
	generic( 
		WIDTH : positive := 32;
		ADDR_WIDTH	: positive := 8;
		IR15to0_W  	: positive := 16;
		IR15to11_W 	: positive := 5;
		IR20to16_W 	: positive := 5;
		IR25to21_W 	: positive := 5;
		IR31to26_W 	: positive := 6;
		IR25to0_W  	: positive := 26;
		IR10to6_W  	: positive := 5
		);
	port(
		clk			: in  std_logic;
		--rst 		: in  std_logic;	Buttons(1)

        --Controller
        PCen		: in  std_logic;
        IorD		: in  std_logic;
        MemRead		: in  std_logic;
        MemWrite	: in  std_logic;
        MemToReg	: in  std_logic;
        IRWrite		: in  std_logic;
        RegDst		: in  std_logic;
        RegWrite	: in  std_logic;
        ALUSrcA		: in  std_logic;
        ALUSrcB		: in  std_logic_vector(1 downto 0);
        ALUOp		: in  std_logic;
        PCSource	: in  std_logic_vector(1 downto 0);
        isSigned	: in  std_logic;
        JumpAndLink	: in  std_logic;
        IR_total	: out std_logic_vector(WIDTH-1 downto 0);
        Branch_Taken	: out std_logic;
        
        --IO
        Buttons		: in  std_logic_vector(1 downto 0);
        Switches	: in  std_logic_vector(9 downto 0);
        Outport		: out std_logic_vector(WIDTH-1 downto 0);

        --ALU control
        OPSelect	: in  std_logic_vector(4 downto 0);
        ALU_Lo_Hi	: in  std_logic_vector(1 downto 0);
        LO_en		: in  std_logic;
        HI_en		: in  std_logic
        --IR[5:0]	: out
        --ALUOp		: out

    );
end datapath;

architecture STR of datapath is
	------------------------------------------------
	----signals based on outputs from components----
	------------------------------------------------
	--PC reg
	signal PC_out		: std_logic_vector(WIDTH-1 downto 0);
	
	--Mem_addr MUX for Memory
	signal sram_input	: std_logic_vector(WIDTH-1 downto 0);

	--Memory
	signal mem_out		: std_logic_vector(WIDTH-1 downto 0);

	--zero extend
	signal inportExtended 	: std_logic_vector(WIDTH-1 downto 0);
	--signal inport1extended 	: std_logic_vector(WIDTH-1 downto 0);

	--Instruction Reg
	signal IR15to0 		: std_logic_vector(15 downto 0);
	signal IR15to11 	: std_logic_vector(4 downto 0);
	signal IR20to16 	: std_logic_vector(4 downto 0);
	signal IR25to21 	: std_logic_vector(4 downto 0);
	signal IR31to26 	: std_logic_vector(5 downto 0);
	signal IR25to0  	: std_logic_vector(25 downto 0);
	signal IR10to6  	: std_logic_vector(4 downto 0);
	--signal IR31to28  	: std_logic_vector(3 downto 0);

	--Memory Data Reg
	signal mem_out_registered	: std_logic_vector(WIDTH-1 downto 0);

	--Write_reg MUX for Register File
	signal writeToRegister	: std_logic_vector(IR20to16_W-1 downto 0);

	--Write_data MUX for Register File
	signal writeToData		: std_logic_vector(WIDTH-1 downto 0);

	--Registers File
	signal rd_data1		: std_logic_vector(WIDTH-1 downto 0);
	signal rd_data2		: std_logic_vector(WIDTH-1 downto 0);

	--Sign Extend for IR[15:0]
	signal IR15to0_signed 	: std_logic_vector(WIDTH-1 downto 0);

	--Shift Left 2 for Sign Extend
	signal IR15to0_signed_sl2	: std_logic_vector(WIDTH-1 downto 0);
	
	--RegA from Registers File
	signal RegA			: std_logic_vector(WIDTH-1 downto 0);

	--RegB from Registers File
	signal RegB			: std_logic_vector(WIDTH-1 downto 0);

	--InputA MUX for ALU
	signal ALU_inputA	: std_logic_vector(WIDTH-1 downto 0);

	--InputB MUX for ALU
	signal ALU_inputB	: std_logic_vector(WIDTH-1 downto 0);

	--ALU
	--signal branch_taken	: std_logic;
	signal result_lo	: std_logic_vector(WIDTH-1 downto 0);
	signal result_hi	: std_logic_vector(WIDTH-1 downto 0);

	--Shift Left 2 for IR[25:0]
	signal IR25to0_sl2	: std_logic_vector(27 downto 0);

	--Concat PC[31:28] from Shift Left 2 output
	signal PCconcat		: std_logic_vector(WIDTH-1 downto 0);

	--PC input MUX
	signal choosePC		: std_logic_vector(WIDTH-1 downto 0);

	--ALU OUT reg
	signal ALU_Out		: std_logic_vector(WIDTH-1 downto 0);

	--ALU LO reg
	signal ALU_Lo		: std_logic_vector(WIDTH-1 downto 0);

	--ALU HI reg
	signal ALU_Hi		: std_logic_vector(WIDTH-1 downto 0);

	--ALU controller

	--ALU outputs MUX
	signal ALUmuxOut 	: std_logic_vector(WIDTH-1 downto 0);


	--other signals
	signal ip0EN, ip1EN 			: std_logic;
	signal memory_data_register_en	: std_logic;
	signal one						: std_logic;
	signal rst						: std_logic;
	signal four						: std_logic_vector(WIDTH-1 downto 0);
begin
	memory_data_register_en <= '1';
	one <= '1';
	four <= std_logic_vector(to_unsigned(4, WIDTH));
	rst <= Buttons(1);
	--branch_taken <= '0';
	--PCen <= '0';

	U_PC_REG		: entity work.gen_register
		generic map( WIDTH => WIDTH )
		port map(
			clk    => clk,
		    rst    => rst,
		    en     => PCen,
		    input  => choosePC, --signal
		    output => PC_out	--signal
		);

	U_MUX_TO_MEM	: entity work.gen_mux_2x1
		generic map( WIDTH => WIDTH )
		port map(
			input0	=> PC_out,		--signal
			input1	=> ALU_Out,		--signal
			sel 	=> IorD,
			output 	=> sram_input	--signal
		);

	--IOen <= Button(0);
	ip0EN <= Buttons(0) and not Switches(9);
	--ip1EN <= Buttons(0) and Switches(9);

	--ip0EN <= '1';
	ip1EN <= '1';

	inportExtended <= "00000000000000000000000" & Switches(8 downto 0);
	--inport1extended <= "00000000000000000000000" & Switches(8 downto 0);

	U_MEM			: entity work.mem_top_level
		generic map(
			WIDTH => WIDTH,
			ADDR_WIDTH => ADDR_WIDTH
		)
		port map(
			inputBus	=> sram_input,		--signal
			memRead		=> memRead,
			memWrite	=> memWrite,
			data		=> RegB,			--signal
			inport0EN	=> ip0EN,
			inport1EN	=> ip1EN,
			inport0 	=> inportExtended, --signal
			inport1 	=> inportExtended, --signal
			clk 		=> clk,
			rst 		=> rst,
			mem_out		=> mem_out,			--signal
			outport 	=> Outport
		);

	--U_ZERO_EXTEND	: entity work.zero_extend
	--	port map(
	--		input 	=> Switches,
	--		output0	=> inport0extended,	--signal
	--		output1	=> inport1extended 	--signal
	--	);

	U_INSTRUCTION_REG_15to0		: entity work.gen_register 
		generic map( WIDTH => IR15to0_W )
		port map(
			clk 		=> clk,
			rst 		=> rst,
			en 			=> IRWrite,
			input		=> mem_out(15 downto 0),				--signal
			output  	=> IR15to0	--signal
		);
	U_INSTRUCTION_REG_15to11	: entity work.gen_register 
		generic map( WIDTH => IR15to11_W )
		port map(
			clk 		=> clk,
			rst 		=> rst,
			en 			=> IRWrite,
			input 		=> mem_out(15 downto 11),				--signal
			output  	=> IR15to11	--signal
		);
	U_INSTRUCTION_REG_20to16	: entity work.gen_register 
		generic map( WIDTH => IR20to16_W )
		port map(
			clk 		=> clk,
			rst 		=> rst,
			en 			=> IRWrite,
			input 		=> mem_out(20 downto 16),				--signal
			output  	=> IR20to16	--signal
		);
	U_INSTRUCTION_REG_25to21	: entity work.gen_register 
		generic map( WIDTH => IR25to21_W )
		port map(
			clk 		=> clk,
			rst 		=> rst,
			en 			=> IRWrite,
			input 		=> mem_out(25 downto 21),				--signal
			output  	=> IR25to21	--signal
		);
	U_INSTRUCTION_REG_31to26	: entity work.gen_register 
		generic map( WIDTH => IR31to26_W )
		port map(
			clk 		=> clk,
			rst 		=> rst,
			en 			=> IRWrite,
			input 		=> mem_out(31 downto 26),				--signal
			output  	=> IR31to26	--signal
		);
	U_INSTRUCTION_REG_25to0	: entity work.gen_register 
		generic map( WIDTH => IR25to0_W )
		port map(
			clk 		=> clk,
			rst 		=> rst,
			en 			=> IRWrite,
			input 		=> mem_out(25 downto 0),				--signal
			output  	=> IR25to0	--signal
		);
	U_INSTRUCTION_REG_10to6		: entity work.gen_register 
		generic map( WIDTH => IR10to6_W )
		port map(
			clk 		=> clk,
			rst 		=> rst,
			en 			=> IRWrite,
			input		=> mem_out(10 downto 6),				--signal
			output  	=> IR10to6	--signal
		);

	IR_total <= IR31to26 & IR25to0;

	--U_INSTRUCTION_REG_31to28	: entity work.gen_register 
	--	generic map( WIDTH => IR31to28_W )
	--	port map(
	--		clk 		=> clk,
	--		rst 		=> rst,
	--		en 			=> IRWrite,
	--		input		=> mem_out(31 downto 28),				--signal
	--		output  	=> IR10to6	--signal
	--	);

	U_MEM_REG			: entity work.gen_register
		generic map( WIDTH => WIDTH )
		port map(
			clk 	=> clk,
			rst 	=> rst,
			en 		=> memory_data_register_en,
			input 	=> mem_out,				--signal
			output 	=> mem_out_registered	--signal
		);

	U_WRITE_REG_MUX		: entity work.gen_mux_2x1
		generic map( WIDTH => IR20to16_W )
		port map(
			input0	=> IR20to16,		--signal
			input1	=> IR15to11,		--signal
			sel 	=> RegDst,
			output 	=> writeToRegister	--signal
		);

	U_WRITE_DATA_MUX	: entity work.gen_mux_2x1
		generic map( WIDTH => WIDTH )
		port map(
			input0	=> ALUmuxOut,		--signal
			input1	=> mem_out_registered,	--signal
			sel 	=> MemToReg,
			output 	=> writeToData	--signal
		);

	U_REGISTERS_FILE	: entity work.registers_file 
		port map(
			clk             => clk,
	        rst             => rst,
	        rd_reg1         => IR25to21,
	        rd_reg2         => IR20to16,
	        wr_reg          => writeToRegister,
	        regWrite        => RegWrite,
	        jump_and_link   => JumpAndLink,
	        wr_data         => writeToData,
	        rd_data1        => rd_data1,	--signal
	        rd_data2        => rd_data2		--signal
		);

	U_SIGN_EXTEND		: entity work.sign_extension
		port map(
			input 		=> IR15to0,
			output 		=> IR15to0_signed,	--signal
			isSigned 	=> isSigned
		);

	--U_SHIFT_LEFT2		: entity work.shift_left2 
	--	port map(
	--		input 	=> IR15to0_signed,
	--		output 	=> IR15to0_signed_sl2	--signal
	--	);

	IR15to0_signed_sl2 <= IR15to0_signed(29 downto 0) & "00";

	U_REG_A		: entity work.gen_register
		generic map( WIDTH => WIDTH )
		port map(
			clk 	=> clk,
			rst 	=> rst,
			en 		=> one,
			input 	=> rd_data1,			
			output 	=> RegA	--signal
		);

	U_REG_B		: entity work.gen_register
		generic map( WIDTH => WIDTH )
		port map(
			clk 	=> clk,
			rst 	=> rst,
			en 		=> one,
			input 	=> rd_data2,			
			output 	=> RegB	--signal
		);

	U_MUX_TO_ALU_A	: entity work.gen_mux_2x1
		generic map( WIDTH => WIDTH )
		port map(
			input0	=> PC_out,
			input1	=> RegA,
			sel 	=> ALUSrcA,
			output 	=> ALU_inputA	--signal
		);
	
	U_MUX_TO_ALU_B	: entity work.gen_mux_4x1
		generic map( WIDTH => WIDTH )
		port map(
			input0  => RegB,
			input1  => four,
			input2  => IR15to0_signed,
			input3  => IR15to0_signed_sl2,
			sel     => ALUSrcB,
			output 	=> ALU_inputB	--signal
		);

	U_ALU		: entity work.MIPS_ALU
		generic map( WIDTH => WIDTH )
		port map(
			inputA			=> ALU_inputA,
			inputB			=> ALU_inputB,
			shiftAmount		=> IR10to6,
			OPSelect		=> OPSelect,
			branch_taken	=> branch_taken,	--signal
			result_lo		=> result_lo, 		--signal
			result_hi		=> result_hi		--signal
		);

	U_ALU_OUT_REG 		: entity work.gen_register
		generic map( WIDTH => WIDTH )
		port map(
			clk 		=> clk,
			rst 		=> rst,
			en 			=> one,
			input 		=> result_lo,
			output  	=> ALU_Out	--signal
		);
	U_ALU_LO_REG 		: entity work.gen_register
		generic map( WIDTH => WIDTH )
		port map(
			clk 		=> clk,
			rst 		=> rst,
			en 			=> HI_en,
			input 		=> result_lo,
			output  	=> ALU_Lo	--signal
		);
	U_ALU_HI_REG 		: entity work.gen_register
		generic map( WIDTH => WIDTH )
		port map(
			clk 		=> clk,
			rst 		=> rst,
			en 			=> LO_en,
			input 		=> result_hi,
			output  	=> ALU_Hi	--signal
		);

	--U_SHIFT_LEFT2_26BIT	: entity work.shift_left2_26bit 
	--	port map(
	--		input 	=> IR25to0,
	--		output 	=> IR25to0_sl2	--signal
	--	);

	PCconcat <= PC_out(31 downto 28) & IR25to0(25 downto 0) & "00";

	--U_CONCAT_SL2		: entity work.concatenate
	--	port map(
	--		vect31to28	=> PC_out(31 downto 28),
	--		vect27to0	=> IR25to0_sl2,
	--		output 		=> PCconcat		--signal
	--	);

	U_MUX_TO_PC			: entity work.gen_mux_4x1
		generic map( WIDTH => WIDTH )
		port map(
			input0    => result_lo,
			input1    => ALU_Out,
			input2    => PCconcat,
			input3    => PCconcat,
			sel       => PCSource,
			output    => choosePC
		);

	U_MUX_ALU_OUT		: entity work.gen_mux_4x1
		generic map( WIDTH => WIDTH )
		port map(
			input0    => ALU_Out,
			input1    => ALU_Lo,
			input2    => ALU_Hi,
			input3    => ALU_Hi,
			sel       => ALU_Lo_Hi,
			output    => ALUmuxOut
		);


end STR;