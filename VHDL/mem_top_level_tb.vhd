library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_top_level_tb is
end mem_top_level_tb;

architecture TB of mem_top_level_tb is

	component mem_top_level
		generic (
			WIDTH		: positive := 32;
			ADDR_WIDTH	: positive := 8
			);
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
	end component;

	constant WIDTH 		: positive := 32;
	constant ADDR_WIDTH	: positive := 8;
	signal  inputBus, 
			data,
			mem_out, 
			outport		: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	signal  inport0 	: std_logic_vector(WIDTH-1 downto 0) := x"00010000";
	signal  inport1 	: std_logic_vector(WIDTH-1 downto 0) := x"00000001";
	signal  memRead,
			memWrite,
			inport0EN,
			inport1EN,
			clk,
			rst			: std_logic := '0';
	signal  done		: std_logic := '0';

begin

	U_MEM_TOP_LEVEL : mem_top_level
		generic map(
			WIDTH => WIDTH,
			ADDR_WIDTH => ADDR_WIDTH)
		port map(
			inputBus	=> inputBus,
			memRead		=> memRead,
			memWrite	=> memWrite,
			data		=> data,
			inport0EN	=> inport0EN,
			inport1EN	=> inport1EN,
			inport0 	=> inport0,
			inport1 	=> inport1,
			clk 		=> clk,
			rst 		=> rst,
			mem_out		=> mem_out,
			outport		=> outport
			);

	clk <= not clk and not done after 10 ns;

	process
	begin

		rst <= '1';
		wait for 200 ns;
		rst <= '0';

		--write to 0a0a0a0a to addr 0
		memWrite <= '1';
		memRead <= '0';
		data <= x"0A0A0A0A";
		inputBus <= x"00000000";
		wait for 80 ns;

		data <= x"F0F0F0F0";
		inputBus <= x"00000004";
		wait for 80 ns;

		--read from addr 0
		memWrite <= '0';
		memRead <= '1';
		inputBus <= x"00000000";
		wait for 80 ns;

		inputBus <= x"00000001";
		wait for 80 ns;

		inputBus <= x"00000004";
		wait for 80 ns;

		inputBus <= x"00000005";
		wait for 80 ns;

		--write 0x00001111 to outport
		memWrite <= '1';
		memRead <= '0';
		data <= x"00001111";
		inputBus <= x"0000FFFC";
		wait for 80 ns;

		--read from inport0
		inport0EN <= '1';
		memWrite <= '0';
		memRead <= '1';
		inputBus <= x"0000FFF8";
		wait for 80 ns;

		--read from inport1
		inport1EN <= '1';
		memWrite <= '0';
		memRead <= '1';
		inputBus <= x"0000FFFC";
		wait for 80 ns;


		report "DONE!";
        done <= '1';
        wait;

	end process;

end TB;