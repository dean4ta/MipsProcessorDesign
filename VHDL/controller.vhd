library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
	port (
		clk			: in  std_logic;
		rst 		: in  std_logic;

		PCWrite		: out std_logic;
		IorD		: out std_logic;
		MemRead		: out std_logic;
		MemWrite	: out std_logic;
		MemToReg	: out std_logic;
		IRWrite		: out std_logic;
		RegDst		: out std_logic;
		RegWrite	: out std_logic;
		ALUSrcA		: out std_logic;
		ALUSrcB		: out std_logic_vector(1 downto 0);
		ALUOp		: out std_logic;
		PCSource	: out std_logic_vector(1 downto 0);
		isSigned	: out std_logic;
		JumpAndLink	: out std_logic;
		IR_total	: in  std_logic_vector(31 downto 0);
		--BranchTaken	: in  std_logic;
		PCWriteCond	: out std_logic;

		OPSelect	: out std_logic_vector(4 downto 0);
		ALU_Lo_Hi	: out std_logic_vector(1 downto 0);
		LO_en		: out std_logic;
		HI_en		: out std_logic
	);
end controller;

architecture IVE_LOST_CONTROL of controller is
	
	type STATE_TYPE is (
		S0, 
		S1, 
		S2, 
		R_TYPE, 
		LW_SW, 
		I_TYPE, 
		BRANCH,
		LW,
		SW,
		LW_1,
		LW_wait,
		LW_2,
		LW_n1,
		SW_1,
		S_ADDI,
		S_ADDIU,
		S_XOR,
		S_MULTU,
		S_MFLO,
		S_MFHI,
		S_HALT,
		S_ADDU,
		S_SUBU,
		JS0,
		JS1,
		J_type,
		S_MULT,
		S_AND,
		S_OR,
		S_SRL,
		S_SLL,
		S_SRA,
		S_SLT,
		S_SLTU,
		S_Check_Branch,
		S_SUBIU,
		S_ANDI,
		S_ORI,
		S_XORI,
		S_SLTI,
		S_SLTIU,
		J_JAL1,
		J_JAL2,
		J_JAL3,
		BRANCH2
		);
    signal state, next_state : STATE_TYPE;


begin

	process(clk, rst)
	begin
		if (rst = '1') then
			--output <= (others => '0');
			state <= S0;
		elsif(clk'event and clk = '1') then
			state <= next_state;
		end if;
	end process;

	process(state, IR_total)
	begin

	PCWrite		<= '0';
	IorD		<= '0';
	MemRead		<= '1'; --
	MemWrite	<= '0';
	MemToReg	<= '0';
	IRWrite		<= '0';
	RegDst		<= '0';
	RegWrite	<= '0';
	ALUSrcA		<= '0';
	ALUSrcB		<= "00";
	ALUOp		<= '0';
	PCSource	<= "00";
	isSigned	<= '0';
	JumpAndLink <= '0';
	PCWriteCond <= '0';

	OPSelect	<= "00000";
	ALU_Lo_Hi	<= "00";
	LO_en		<= '0';
	HI_en		<= '0';

	case state is
		when S0 =>
			IRWrite <= '1';
			next_state <= S1;

		when JS0 =>
			IRWrite <= '1';
			next_state <= JS1; --skip the PC increment step

		when S1 =>
			--increment PC while 32 bits load into IR
			IRWrite <= '1';
			ALUSrcA <= '0';
			ALUSrcB <= "01";
			OPSelect <= "00000";
			PCSource <= "00";
			PCWrite <= '1';
			next_state <= S2;

		when JS1 =>
			--increment PC while 32 bits load into IR
			IRWrite <= '1';
			ALUSrcA <= '0';
			ALUSrcB <= "01";
			OPSelect <= "00000";
			PCSource <= "00";
			--PCWrite <= '1';
			next_state <= S2;

		when S2 =>
			--increment PC while 32 bits load into IR
			--decode top bits of OP code
			----IRWrite <= '1';
			if IR_total(31 downto 26) = "000000" AND IR_total(5 downto 0) /= "001001" then
				--we have R-type
				next_state <= R_TYPE;

			elsif IR_total(31 downto 26) = "000010" OR IR_total(31 downto 26) = "000011" OR (IR_total(31 downto 26) = "000000" AND IR_total(5 downto 0) = "001001") then
				next_state <= J_type;
	
			elsif IR_total = x"FC000000" then
				next_state <= S_HALT;

			elsif IR_total(31) = '1' then
				--we have LW/SW
				next_state <= LW_SW;			

			elsif IR_total(30) = '1' or IR_total(29) = '1' then
				--we have an I-type
				next_state <= I_TYPE;	
				
			else
				--we have a branch
				next_state <= BRANCH;	

			end if;	

		when R_TYPE =>
			--xor
			if IR_total(5 downto 0) = "100110" then
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "00110";
				next_state <= S_XOR;
			--multu
			elsif IR_total(5 downto 0) = "011001" then
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "00010";
				HI_en <= '1';
				LO_en <= '1';
				next_state <= S_MULTU;
			--mult
			elsif IR_total(5 downto 0) = "011000" then
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "00011";
				HI_en <= '1';
				LO_en <= '1';
				next_state <= S_MULT;
			--mflo
			elsif IR_total(5 downto 0) = "010010" then
				ALU_Lo_Hi <= "01";
				MemToReg <= '0';
				RegDst <= '1';
				RegWrite <= '1';
				next_state <= S_MFLO;
			--mfhi
			elsif IR_total(5 downto 0) = "010000" then
				ALU_Lo_Hi <= "10";
				MemToReg <= '0';
				RegDst <= '1';
				RegWrite <= '1';
				next_state <= S_MFHI;
			--addu
			elsif IR_total(5 downto 0) = "100001" then
				RegDst <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "00000";
				next_state <= S_ADDU;
			--subu
			elsif IR_total(5 downto 0) = "100011" then
				RegDst <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "00001";
				next_state <= S_SUBU;
			--and
			elsif IR_total(5 downto 0) = "100100" then
				RegDst <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "00100";
				next_state <= S_AND;
			--or
			elsif IR_total(5 downto 0) = "100101" then
				RegDst <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "00101";
				next_state <= S_OR;
			--srl
			elsif IR_total(5 downto 0) = "000010" then
				RegDst <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "00111";
				next_state <= S_SRL;
			--sll
			elsif IR_total(5 downto 0) = "000000" then
				RegDst <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "01000";
				next_state <= S_SLL;
			--sra
			elsif IR_total(5 downto 0) = "000011" then
				RegDst <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "01001";
				next_state <= S_SRA;
			--slt
			elsif IR_total(5 downto 0) = "101010" then
				RegDst <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "01010";
				next_state <= S_SLT;
			--sltu
			elsif IR_total(5 downto 0) = "101011" then
				RegDst <= '1';
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "01011";
				next_state <= S_SLTU;

			else
				next_state <= S0;
			end if ;

		when BRANCH =>
			--calculate branch addr
			ALUSrcB <= "11";
			isSigned <= '1';
			ALUSrcA <= '0';
			OPSelect <= "00000";
			next_state <= BRANCH2;

		when BRANCH2 =>
			--beq
			if IR_total(31 downto 26) = "000100" then
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "10000";
				PCWriteCond <= '1';
				--if BranchTaken = '1' then
					PCSource <= "01";
				--else --BranchTaken = '0'
					--do nothing
				--end if ;
				next_state <= S0;
			--bne
			elsif IR_total(31 downto 26) = "000101" then
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "10001";
				PCWriteCond <= '1';
				--if BranchTaken = '1' then
					PCSource <= "01";
				--else --BranchTaken = '0'
					--do nothing
				--end if ;
				next_state <= S0;
			--blez
			elsif IR_total(31 downto 26) = "000110" then
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "10010";
				PCWriteCond <= '1';
				--if BranchTaken = '1' then
					PCSource <= "01";
				--else --BranchTaken = '0'
					--do nothing
				--end if ;
				next_state <= S0;
			--bgtz
			elsif IR_total(31 downto 26) = "000111" then
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "10011";
				PCWriteCond <= '1';
				--if BranchTaken = '1' then
					PCSource <= "01";
				--else --BranchTaken = '0'
					--do nothing
				--end if ;
				next_state <= S0;
			--bltz
			elsif IR_total(31 downto 26) = "000001" AND IR_total(20 downto 16) = "00000" then
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "10100";
				--if BranchTaken = '1' then
					PCSource <= "01";
				--else --BranchTaken = '0'
					--do nothing
				--end if ;
				next_state <= S0;
			--bgez
			elsif IR_total(31 downto 26) = "000001" AND IR_total(20 downto 16) = "00001" then
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				OPSelect <= "10101";
				--if BranchTaken = '1' then
					PCSource <= "01";
				--else --BranchTaken = '0'
					--do nothing
				--end if ;
				next_state <= S0;

			else
				next_state <= S0;
			end if ;

		--when S_Check_Branch =>
		--	if BranchTaken = '1' then
		--		ALUSrcA <= '0';
		--		ALUSrcB <= "11";
		--		OPSelect <= "00000";
		--		PCSource <= "00";
		--		PCWrite <= '1';
		--	else --BranchTaken = '0'
		--		--do nothing
		--	end if ;
		--	next_state <= S0;

		when J_type =>
			--j
			if IR_total(31 downto 26) = "000010" then
				PCSource <= "10";
				PCWrite <= '1';
				next_state <= JS0;
			--jal
			elsif IR_total(31 downto 26) = "000011" then
				--JumpAndLink <= '1';
				MemToReg <= '0';  --NOT SURE ABOUT THIS
				PCSource <= "10";
				PCWrite <= '1';
				next_state <= J_JAL1;
			--jr
			elsif IR_total(31 downto 26) = "000000" AND IR_total(5 downto 0) = "001001" then
				ALUSrcA <= '1';
				PCSource <= "00";
				PCWrite <= '1';
				next_state <= JS0;

			else
				next_state <= S0;
			end if ;

		when J_JAL1 => 
			JumpAndLink <= '1';
			RegWrite <= '1';
			MemToReg <= '0';  --NOT SURE ABOUT THIS
			PCSource <= "10";
			PCWrite <= '1';
			next_state <= JS0;

		when S_MULTU => 
			next_state <= S0;

		when S_MULT => 
			next_state <= S0;

		when S_MFLO => 
			next_state <= S0;

		when S_MFHI => 
			next_state <= S0;

		when LW_SW => 
			ALUSrcA <= '1';
			ALUSrcB <= "10";
			OPSelect <= "00000";--add
			PCWrite <= '0';
			--IorD <= '1';

			if IR_total(31 downto 26) = "100011" then
				--we have Load Word
				next_state <= LW_n1;
			elsif IR_total(31 downto 26) = "101011" then
				--we have Store Word
				next_state <= SW;
			else
				next_state <= S0; --robustness
			end if ;

		when I_TYPE => 
			--if addi
			if IR_total(31 downto 26) = "001000" then
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				OPSelect <= "00000";
				next_state <= S_ADDI;
			--if addiu
			elsif IR_total(31 downto 26) = "001001" then
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				OPSelect <= "00000";
				next_state <= S_ADDIU;
			--subiu
			elsif IR_total(31 downto 26) = "010000" then
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				OPSelect <= "00001";
				next_state <= S_SUBIU;
			--andi
			elsif IR_total(31 downto 26) = "001100" then
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				OPSelect <= "00100";
				next_state <= S_ANDI;
			--ori
			elsif IR_total(31 downto 26) = "001101" then
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				OPSelect <= "00101";
				next_state <= S_ORI;
			--xori
			elsif IR_total(31 downto 26) = "001110" then
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				OPSelect <= "00110";
				next_state <= S_XORI;
			--slti
			elsif IR_total(31 downto 26) = "001010" then
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				OPSelect <= "01010";
				next_state <= S_SLTI;
			--sltiu
			elsif IR_total(31 downto 26) = "001011" then
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				OPSelect <= "01011";
				next_state <= S_SLTIU;
			else
				next_state <= S0;
			end if ;

		when S_XOR => 
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '1';
			RegWrite <= '1';
			next_state <= S0;

		when S_ADDI =>
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '0';
			RegWrite <= '1';
			next_state <= S0;

		when S_ADDIU =>
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '0';
			RegWrite <= '1';
			next_state <= S0;

		when S_SUBIU => 
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '0';
			RegWrite <= '1';
			next_state <= S0;

		when S_ANDI => 
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '0';
			RegWrite <= '1';
			next_state <= S0;

		when S_ORI => 
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '0';
			RegWrite <= '1';
			next_state <= S0;

		when S_XORI => 
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '0';
			RegWrite <= '1';
			next_state <= S0;

		when S_SLTI => 
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '0';
			RegWrite <= '1';
			next_state <= S0;
		
		when S_SLTIU => 
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '0';
			RegWrite <= '1';
			next_state <= S0;
		
		--Load Word, Store Word
		when LW_n1 =>
			ALUSrcA <= '1';
			ALUSrcB <= "10";
			IorD <= '1';
			RegDst <= '0';
			next_state <= LW;

		when LW => 
			ALUSrcA <= '1';
			ALUSrcB <= "10";
			IorD <= '1';
			RegDst <= '0';
			next_state <= LW_1;

		when LW_1 => 
			ALUSrcA <= '1';
			ALUSrcB <= "10";
			--IorD <= '1';
			RegDst <= '0'; -- Write to reg[addr] where addr is IR[20:16]
			MemToReg <= '1'; -- from memDataReg
			RegWrite <= '1';
			next_state <= S0;

		when SW => 
			ALUSrcA <= '1';
			ALUSrcB <= "10";
			IorD <= '1';
			MemWrite <= '1';
			MemRead <= '0';
			next_state <= SW_1;

		when SW_1 =>
			ALUSrcA <= '1';
			ALUSrcB <= "10";
			IorD <= '1';
			MemWrite <= '1';
			MemRead <= '0';
			next_state <= S0;

		when S_HALT => 
			next_state <= S_HALT;

		when S_ADDU => 
			RegDst <= '1';
			ALUSrcA <= '1';
			ALUSrcB <= "00";
			OPSelect <= "00000";
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '1';
			RegWrite <= '1';
			next_state <= S0;

		when S_SUBU => 
			RegDst <= '1';
			ALUSrcA <= '1';
			ALUSrcB <= "00";
			OPSelect <= "00001";
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '1';
			RegWrite <= '1';
			next_state <= S0;

		when S_AND => 
			RegDst <= '1';
			ALUSrcA <= '1';
			ALUSrcB <= "00";
			OPSelect <= "00100";
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '1';
			RegWrite <= '1';
			next_state <= S0;

		when S_OR => 
			RegDst <= '1';
			ALUSrcA <= '1';
			ALUSrcB <= "00";
			OPSelect <= "00101";
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '1';
			RegWrite <= '1';
			next_state <= S0;

		when S_SRL => 
			RegDst <= '1';
			ALUSrcA <= '1';
			ALUSrcB <= "00";
			OPSelect <= "00111";
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '1';
			RegWrite <= '1';
			next_state <= S0;

		when S_SLL => 
			RegDst <= '1';
			ALUSrcA <= '1';
			ALUSrcB <= "00";
			OPSelect <= "01000";
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '1';
			RegWrite <= '1';
			next_state <= S0;

		when S_SRA => 
			RegDst <= '1';
			ALUSrcA <= '1';
			ALUSrcB <= "00";
			OPSelect <= "01001";
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '1';
			RegWrite <= '1';
			next_state <= S0;

		when S_SLT => 
			RegDst <= '1';
			ALUSrcA <= '1';
			ALUSrcB <= "00";
			OPSelect <= "01010";
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '1';
			RegWrite <= '1';
			next_state <= S0;

		when S_SLTU => 
			RegDst <= '1';
			ALUSrcA <= '1';
			ALUSrcB <= "00";
			OPSelect <= "01011";
			ALU_Lo_Hi <= "00";
			MemToReg <= '0';
			RegDst <= '1';
			RegWrite <= '1';
			next_state <= S0;

		when others => null;
	end case;
	end process;
end IVE_LOST_CONTROL;



