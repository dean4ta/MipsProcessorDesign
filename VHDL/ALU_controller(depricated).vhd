library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_controller is  
	port(
        IR_5to0		: in  std_logic_vector(5 downto 0);
        ALUOp		: in  std_logic;
        OpSelect	: out std_logic_vector(4 downto 0);
        HI_en		: out std_logic;
        LO_en		: out std_logic;
        ALU_LO_HI	: out std_logic_vector(1 downto 0)
    );
end ALU_controller;

architecture CONTROL of ALU_controller is

	signal 

begin
	process(IR_5to0, ALUOp)
	begin

		

	end process;

end CONTROL;