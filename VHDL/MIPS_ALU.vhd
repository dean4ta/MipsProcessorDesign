library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MIPS_ALU is
	generic(
		WIDTH : positive := 32);
	port (
		inputA			: in  std_logic_vector(WIDTH-1 downto 0);
		inputB			: in  std_logic_vector(WIDTH-1 downto 0);
		shiftAmount		: in  std_logic_vector(4 downto 0); --IR[10:6]
		OPSelect		: in  std_logic_vector(4 downto 0);
		branch_taken	: out std_logic;
		result_lo		: out std_logic_vector(WIDTH-1 downto 0);
		result_hi		: out std_logic_vector(WIDTH-1 downto 0)
	);
end MIPS_ALU;

architecture ALUHA of MIPS_ALU is

	--signal temp : std_logic_vector((2*WIDTH)-1 downto 0);
	--signal mult_flag : std_logic;

begin
	process(inputA, inputB, shiftAmount, OPSelect)
		variable mult : std_logic_vector((2*WIDTH)-1 downto 0);
	begin
		--temp <= (others => '0');
		--mult <= (others => '0');
		--mult2 <= (others => '0');
		branch_taken <= '0';
		--mult_flag <= '0';
		result_hi <= (others => '0');
		result_lo <= (others => '0');

		case(OPSelect) is	
			--add unsigned
			when "00000" =>
				result_lo <= std_logic_vector(unsigned(inputA)+unsigned(inputB));
			----add immediate unsigned
			--when "00001" =>
			--	result_lo <= std_logic_vector(unsigned(inputA)+unsigned(inputB));
			--sub unsigned
			when "00001" =>
				result_lo <= std_logic_vector(unsigned(inputA)-unsigned(inputB));
			----sub immediate unsigned
			--when "00011" =>
			--	result_lo <= std_logic_vector(unsigned(inputA)-unsigned(inputB));
			--mult unsigned
			when "00010" =>
				mult := std_logic_vector(unsigned(inputA)*unsigned(inputB));
				--result_lo <= mult(WIDTH-1 downto 0);
				--mult_flag <= '1';
				result_hi <= mult((2*WIDTH)-1 downto WIDTH);
				result_lo <= mult(WIDTH-1 downto 0);
			--mult signed
			when "00011" =>
				mult := std_logic_vector(signed(inputA)*signed(inputB));
				--result_lo <= mult(WIDTH-1 downto 0);
				--mult_flag <= '1';
				result_hi <= mult((2*WIDTH)-1 downto WIDTH);
				result_lo <= mult(WIDTH-1 downto 0);
			--and
			when "00100" =>
				result_lo <= inputA and inputB;
			----andi
			--when "00111" =>

			--or
			when "00101" =>
				result_lo <= inputA or inputB;
			----ori
			--when "01001" =>

			--xor
			when "00110" =>
				result_lo <= inputA xor inputB;
			----xori
			--when "01011" =>

			--srl (shift right logical)
			when "00111" =>
				result_lo <= std_logic_vector(shift_right(unsigned(inputB), to_integer(unsigned(shiftAmount))));
			--sll (shift left logical)
			when "01000" =>
				result_lo <= std_logic_vector(shift_left(unsigned(inputB), to_integer(unsigned(shiftAmount))));
			--sra (shift right arithmetic)
			when "01001" =>
				result_lo <= std_logic_vector(shift_right(signed(inputB), to_integer(unsigned(shiftAmount))));
			--slt (set on less than signed)
			when "01010" =>
				if signed(inputA) < signed(inputB) then
					result_lo <= std_logic_vector(to_unsigned(1, WIDTH));
				else
					result_lo <= (others => '0');
				end if ;
			----slti (set on less than immediate signed)
			--when "10000" =>

			--sltiu
			when "01011" =>
				if unsigned(inputA) < unsigned(inputB) then
					result_lo <= std_logic_vector(to_unsigned(1, WIDTH));
				else
					result_lo <= (others => '0');
				end if ;

			----sltu
			--when "10010" =>

			--mfhi
			when "01100" =>

			--mflo
			when "01101" =>

			--load word
			when "01110" =>

			--store word
			when "01111" =>

			--branch on equal
			when "10000" =>
				if inputA = inputB then
					branch_taken <= '1';		
				else
					branch_taken <= '0';
				end if ;

			--branch on not equal
			when "10001" =>
				if inputA = inputB then
					branch_taken <= '0';		
				else
					branch_taken <= '1';
				end if ;

			--branch on lt or eq to 0
			when "10010" =>
				if signed(inputA) <= to_signed(0, WIDTH) then
					branch_taken <= '1';		
				else
					branch_taken <= '0';
				end if ;

			--branch on gt 0
			when "10011" =>
				if signed(inputA) > to_signed(0, WIDTH) then
					branch_taken <= '1';		
				else
					branch_taken <= '0';
				end if ;

			--branch on lt 0
			when "10100" =>
				if signed(inputA) < to_signed(0, WIDTH) then
					branch_taken <= '1';		
				else
					branch_taken <= '0';
				end if ;

			--branch on gt or eq to 0
			when "10101" =>
				if signed(inputA) <= to_signed(0, WIDTH) then
					branch_taken <= '1';		
				else
					branch_taken <= '0';
				end if ;

			--jump to address
			when "10110" =>

			--jump and link
			when "10111" =>

			--jump register
			when "11000" =>

			--fake out
			when "11001" =>
		
			when others => null;
		
		end case ;
		
	end process;

	--result_hi <= temp((2*WIDTH)-1 downto WIDTH);
	--result_lo <= result_lo;
	--result_hi <= mult2(2*(WIDTH)-1 downto WIDTH);
	
	--with mult_flag select
	--	result_lo <= mult2(WIDTH-1 downto 0) when '1',
	--				 result_lo 					when others;

	--if (mult_flag = '1') then
	--	result_lo <= mult(WIDTH-1 downto 0);
	--else
	--	result_lo <= result_lo;
	--end if;
end ALUHA;