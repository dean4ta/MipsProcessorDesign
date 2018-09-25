library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity concatenate is
	port (
		vect31to28	: in  std_logic_vector(3 downto 0);
		vect27to0	: in  std_logic_vector(27 downto 0);
		output 		: out std_logic_vector(31 downto 0)
		);
end concatenate;

architecture SHIFT_LEFT of concatenate is
begin
	process(vect31to28, vect27to0)
		--variable temp 	: std_logic_vector(31 downto 0);
	begin
		--temp := std_logic_vector(shift_left(unsigned(vect31to28), 28));
		output <= vect31to28 & vect27to0;
	end process;

end SHIFT_LEFT;