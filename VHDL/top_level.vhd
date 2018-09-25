library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
	generic( 
		WIDTH 		: positive := 32;
		ADDR_WIDTH	: positive := 8;
		IR15to0_W  	: positive := 16;
		IR15to11_W 	: positive := 5;
		IR20to16_W 	: positive := 5;
		IR25to21_W 	: positive := 5;
		IR31to26_W 	: positive := 6;
		IR25to0_W  	: positive := 26;
		IR10to6_W  	: positive := 5
		);
	port (
		clk			: in  std_logic;
		--rst 		: in  std_logic; Buttons(1)
		Buttons		: in  std_logic_vector(1 downto 0);
		Switches	: in  std_logic_vector(9 downto 0); 
		LEDs		: out std_logic_vector(31 downto 0)
	) ;
end top_level;

architecture THE_FINAL_BOSS of top_level is

	------------------------
	----Datapath Signals----
	------------------------
    --Controller
    signal PCen			:  std_logic;
    signal IorD			:  std_logic;
    signal MemRead		:  std_logic;
    signal MemWrite		:  std_logic;
    signal MemToReg		:  std_logic;
    signal IRWrite		:  std_logic;
    signal RegDst		:  std_logic;
    signal RegWrite		:  std_logic;
    signal ALUSrcA		:  std_logic;
    signal ALUSrcB		:  std_logic_vector(1 downto 0);
    signal ALUOp		:  std_logic;
    signal PCSource		:  std_logic_vector(1 downto 0);
    signal isSigned		:  std_logic;
    signal JumpAndLink	:  std_logic;
    signal IR_total		:  std_logic_vector(WIDTH-1 downto 0);
    signal Branch_Taken	:  std_logic;
	signal PCWriteCond	:  std_logic;
	signal PCWrite  	:  std_logic;
    
    --IO
    --signal Buttons		:  std_logic_vector(1 downto 0);
    --signal Switches		:  std_logic_vector(9 downto 0);
    --signal Outport		:  std_logic_vector(WIDTH-1 downto 0);

    --ALU control
    signal OPSelect		:  std_logic_vector(4 downto 0);
    signal ALU_Lo_Hi	:  std_logic_vector(1 downto 0);
    signal LO_en		:  std_logic;
    signal HI_en		:  std_logic;

    --Buttons(1) <= rst;

begin

	PCen <= (PCWriteCond AND Branch_Taken) OR PCWrite;

	U_DATAPATH		: entity work.datapath
		generic map(
			WIDTH 		=> WIDTH,
			ADDR_WIDTH	=> ADDR_WIDTH,
			IR15to0_W  	=> IR15to0_W,
			IR15to11_W 	=> IR15to11_W,
			IR20to16_W 	=> IR20to16_W,
			IR25to21_W 	=> IR25to21_W,
			IR31to26_W 	=> IR31to26_W,
			IR25to0_W  	=> IR25to0_W,
			IR10to6_W  	=> IR10to6_W
		)
		port map(
			clk			=> clk,
			--rst 		=> rst,

	        --Controller
	        PCen		=> PCen,
	        IorD		=> IorD,
	        MemRead		=> MemRead,
	        MemWrite	=> MemWrite,
	        MemToReg	=> MemToReg,
	        IRWrite		=> IRWrite,
	        RegDst		=> RegDst,
	        RegWrite	=> RegWrite,
	        ALUSrcA		=> ALUSrcA,
	        ALUSrcB		=> ALUSrcB,
	        ALUOp		=> ALUOp,
	        PCSource	=> PCSource,
	        isSigned	=> isSigned,
	        JumpAndLink	=> JumpAndLink,
	        IR_total	=> IR_total,
	        Branch_Taken	=> Branch_Taken,
	        
	        --IO
	        Buttons		=> Buttons, --includes rst
	        Switches	=> Switches,
	        Outport		=> LEDs,

	        --ALU control
	        OPSelect	=> OPSelect,
	        ALU_Lo_Hi	=> ALU_Lo_Hi,
	        LO_en		=> LO_en,
	        HI_en		=> HI_en
		);


	U_CONTROLLER 	: entity work.controller 
		port map(
			clk			=> clk,
			rst 		=> Buttons(1),

			PCWrite		=> PCWrite,
			IorD		=> IorD,
			MemRead		=> MemRead,
			MemWrite	=> MemWrite,
			MemToReg	=> MemToReg,
			IRWrite		=> IRWrite,
			RegDst		=> RegDst,
			RegWrite	=> RegWrite,
			ALUSrcA		=> ALUSrcA,
			ALUSrcB		=> ALUSrcB,
			ALUOp		=> ALUOp,
			PCSource	=> PCSource,
			isSigned	=> isSigned,
			JumpAndLink	=> JumpAndLink,
			IR_total	=> IR_total,
			--Branch_Taken	=> Branch_Taken,
			PCWriteCond => PCWriteCond,

			OPSelect	=> OPSelect,
			ALU_Lo_Hi	=> ALU_Lo_Hi,
			LO_en		=> LO_en,
			HI_en		=> HI_en
			);

end THE_FINAL_BOSS;