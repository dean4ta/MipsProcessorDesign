library ieee;
use ieee.std_logic_1164.all;

entity mem_top_level is
	generic(
		WIDTH		: positive := 32;
		ADDR_WIDTH	: positive := 8);
	port(
		inputBus	: in  std_logic_vector(WIDTH-1 downto 0); --addr
		memRead		: in  std_logic;
		memWrite	: in  std_logic;
		data		: in  std_logic_vector(WIDTH-1 downto 0);
		inport0EN	: in  std_logic;
		inport1EN	: in  std_logic;
		inport0 	: in  std_logic_vector(WIDTH-1 downto 0);
		inport1 	: in  std_logic_vector(WIDTH-1 downto 0);
		clk 		: in  std_logic;
		rst 		: in  std_logic;
		mem_out		: out std_logic_vector(WIDTH-1 downto 0);
		outport		: out std_logic_vector(WIDTH-1 downto 0)
	);
end mem_top_level;

architecture STR of mem_top_level is

	--mem_controller
	signal writeEN, outportEN 		: std_logic;
	signal regSel					: std_logic_vector(1 downto 0);
	--RAM
	signal RAMout					: std_logic_vector(WIDTH-1 downto 0);
	--MUX/Registers
	signal inport0Reg, inport1Reg	: std_logic_vector(WIDTH-1 downto 0);

begin

	U_MEM_CONTROLLER 	: entity work.mem_controller 
		generic map(
			WIDTH		=> WIDTH,
			ADDR_WIDTH	=> ADDR_WIDTH
		)
		port map(
			memRead		=> memRead,
			memWrite	=> memWrite,
			inputBus	=> inputBus,
			outportEN	=> outportEN,
			writeEN		=> writeEN,
			regSel		=> regSel
		);
	U_RAM 				: entity work.test_case_1
		port map(
			address		=> inputBus(9 downto 2),
			clock		=> clk,
			data		=> data,
			wren		=> writeEN,
			q			=> RAMout
		);
	
	U_INPORT0_REG		: entity work.gen_register
		generic map(
			WIDTH 		=> WIDTH
		)
		port map(
			clk 		=> clk,
			rst 		=> rst,
			en 			=> inport0EN,
			input 		=> inport0,
			output		=> inport0Reg
		);
	U_INPORT1_REG		: entity work.gen_register
		generic map(
			WIDTH 		=> WIDTH
		)
		port map(
			clk 		=> clk,
			rst 		=> rst,
			en 			=> inport1EN,
			input 		=> inport1,
			output		=> inport1Reg
		);
	U_OUTPORT_REG		: entity work.gen_register
		generic map(
			WIDTH 		=> WIDTH
		)
		port map(
			clk 		=> clk,
			rst 		=> rst,
			en 			=> outportEN,
			input 		=> data,
			output		=> outport
		);

	U_MUX				: entity work.gen_mux_4x1
		generic map(
			WIDTH 		=> WIDTH
		)
		port map(
			input0		=> RAMout,
			input1		=> inport0Reg,
			input2		=> inport1Reg,
			input3		=> RAMout,    --never chosen
			sel 		=> regSel,
			output		=> mem_out
		);

end STR;