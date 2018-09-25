library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extension is
	port (
		input  		: in  std_logic_vector(15 downto 0);
		output 		: out std_logic_vector(31 downto 0);
		isSigned	: in  std_logic);
end sign_extension;

architecture SIGN_EXTEND of sign_extension is
begin
	process(isSigned, input)
	begin
		output(15 downto 0) <= input;
		if isSigned = '1' then
			if input(15) = '1' then
				output(31 downto 16) <= (others => '1'); --pad with 1s
			else
				output(31 downto 16) <= (others => '0'); --pad with 0s
			end if;
		else
			output(31 downto 16) <= (others => '0'); --pad with 0s
		end if;
	end process;
end SIGN_EXTEND;