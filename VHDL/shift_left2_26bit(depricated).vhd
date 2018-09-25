library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_left2_26bit is
	port (
		input  : in  std_logic_vector(25 downto 0);
		output : out std_logic_vector(27 downto 0));
end shift_left2_26bit;

architecture SHIFT_LEFT of shift_left2_26bit is
begin
	process(input)
		variable temp 	: unsigned(27 downto 0);
	begin
		temp := (27 downto 26 => '0') & input;
		output <= std_logic_vector(shift_left(unsigned(temp), 2));
	end process;

end SHIFT_LEFT;