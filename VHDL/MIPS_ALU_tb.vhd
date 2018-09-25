library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MIPS_ALU_tb is
end MIPS_ALU_tb;

architecture TB of MIPS_ALU_tb is

	component MIPS_ALU
		generic (
			WIDTH		: positive := 32);
		port(
			inputA			: in  std_logic_vector(WIDTH-1 downto 0);
			inputB			: in  std_logic_vector(WIDTH-1 downto 0);
			shiftAmount		: in  std_logic_vector(4 downto 0); --IR[10:6]
			OPSelect		: in  std_logic_vector(4 downto 0);
			branch_taken	: out std_logic;
			result_lo		: out std_logic_vector(WIDTH-1 downto 0);
			result_hi		: out std_logic_vector(WIDTH-1 downto 0)
			);
	end component;

	constant WIDTH 		: positive := 32;
	signal  inputA, 
			inputB,
			result_lo, 
			result_hi	: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	signal  shiftAmount, 
			OPSelect	: std_logic_vector(4 downto 0) := (others => '0');
	signal  branch_taken : std_logic := '0';
	signal  done,
			rst,
			clk		: std_logic := '0';

begin

	U_MEM_TOP_LEVEL : MIPS_ALU
		generic map(WIDTH => WIDTH)
		port map(
			inputA			=> inputA,
			inputB			=> inputB,
			shiftAmount		=> shiftAmount,
			OPSelect		=> OPSelect,
			branch_taken	=> branch_taken,
			result_lo		=> result_lo,
			result_hi		=> result_hi
			);

	clk <= not clk and not done after 20 ns;

	process
	begin

		rst <= '1';
		wait for 20 ns;
		rst <= '0';

		--add 10+15
		inputA <= std_logic_vector(to_unsigned(10,WIDTH));
		inputB <= std_logic_vector(to_unsigned(15,WIDTH));
		OPSelect <= "00000";
		wait for 20 ns;

		--subtract 25-10
		inputA <= std_logic_vector(to_unsigned(25,WIDTH));
		inputB <= std_logic_vector(to_unsigned(10,WIDTH));
		OPSelect <= "00001";
		wait for 20 ns;		

		--mult signed 10*(-4)
		inputA <= std_logic_vector(to_signed(10,WIDTH));
		inputB <= std_logic_vector(to_signed(-4,WIDTH));
		OPSelect <= "00011";
		wait for 20 ns;		

		--mult unsigned 65536*131072
		inputA <= std_logic_vector(to_unsigned(65536,WIDTH));
		inputB <= std_logic_vector(to_unsigned(131072,WIDTH));
		OPSelect <= "00010";
		wait for 20 ns;

		--AND 0x0000ffff and 0xffff1234
		inputA <= x"0000ffff";
		inputB <= x"ffff1234";
		OPSelect <= "00100";
		wait for 20 ns;

		--shift right logical 0x000000f by 4
		inputB <= x"0000000f";
		OPSelect <= "00111";
		shiftAmount <= std_logic_vector(to_unsigned(4,5));
		wait for 20 ns;

		--shift right arithmetic 0xf0000008 by 1
		inputB <= x"f0000008";
		OPSelect <= "01001";
		shiftAmount <= std_logic_vector(to_unsigned(1,5));
		wait for 20 ns;

		--shift right arithmetic 0x00000008 by 1
		inputB <= x"00000008";
		OPSelect <= "01001";
		shiftAmount <= std_logic_vector(to_unsigned(1,5));
		wait for 20 ns;

		--set on lt 10 and 15
		inputA <= std_logic_vector(to_signed(10,WIDTH));
		inputB <= std_logic_vector(to_signed(15,WIDTH));
		OPSelect <= "01010";
		wait for 20 ns;		

		--set on lt 15 and 10
		inputA <= std_logic_vector(to_signed(15,WIDTH));
		inputB <= std_logic_vector(to_signed(10,WIDTH));
		OPSelect <= "01010";
		wait for 20 ns;	

		--branch not taken for 5 <= 0
		inputA <= std_logic_vector(to_signed(5,WIDTH));
		OPSelect <= "10010";
		wait for 20 ns;

		--branch taken for 5 > 0
		inputA <= std_logic_vector(to_signed(5,WIDTH));
		OPSelect <= "10011";
		wait for 20 ns;


		report "DONE!";
        done <= '1';
        wait;

	end process;

end TB;