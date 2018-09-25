library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is
end top_level_tb;

architecture TB of top_level_tb is

	component top_level
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
	end component;

	constant WIDTH 			: positive := 32;
	constant ADDR_WIDTH		: positive := 8;
	constant IR15to0_W  	: positive := 16;
	constant IR15to11_W 	: positive := 5;
	constant IR20to16_W 	: positive := 5;
	constant IR25to21_W 	: positive := 5;
	constant IR31to26_W 	: positive := 6;
	constant IR25to0_W  	: positive := 26;
	constant IR10to6_W  	: positive := 5;

	signal clk 		: std_logic := '0';
	signal done		: std_logic := '0';
	--signal rst 		: std_logic := '1';
	signal Buttons 	: std_logic_vector(1 downto 0) := "10";
	--Buttons(0) ipEN, Buttons(1) rst
	signal rst 		: std_logic;
	signal LEDs 	: std_logic_vector(31 downto 0);
	signal switches : std_logic_vector(9 downto 0) := "0000000110";


begin

	U_THE_FINAL_BOSS	: top_level
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
		port map ( 
			clk 		=> clk,
			--rst 		=> rst, --Buttons(1)
			Buttons 	=> Buttons,
			LEDs 		=> LEDs,
			switches 	=> switches 
		);

	clk <= not clk and not done after 20 ns;
	rst <= Buttons(1);

	process
	begin

		Buttons(1) <= '1';
		wait for 30 ns;
		Buttons(1) <= '0';
		Buttons(0) <= '1';

		wait for 300 ns;
		switches <= "1000000100";

		wait for 16400 ns;
		done <= '1';

		wait;
	end process;

end TB;