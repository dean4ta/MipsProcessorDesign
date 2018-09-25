library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--entity shift_left2 is
--	port (
--		input0  : in  std_logic_vector(31 downto 0);
--		output0 : out std_logic_vector(31 downto 0));
--end shift_left2;

--architecture SHIFT_LEFT of shift_left2 is

--	signal temp		: unsigned(31 downto 0);

--begin
	
--	temp <= (shift_left(unsigned(input0), 2));
--	output0 <= std_logic_vector(temp);
	
--end SHIFT_LEFT;
entity shift_left2 is
end shift_left2;

architecture behave of shift_left2 is
  signal r_Shift1     : std_logic_vector(3 downto 0) := "1000";
  signal r_Unsigned_L : unsigned(3 downto 0)         := "0000";
  signal r_Unsigned_R : unsigned(3 downto 0)         := "0000";
  signal r_Signed_L   : signed(3 downto 0)           := "0000";
  signal r_Signed_R   : signed(3 downto 0)           := "0000";
   
begin
 
  process is
  begin
    -- Left Shift
    r_Unsigned_L <= shift_left(unsigned(r_Shift1), 1);
    r_Signed_L   <= shift_left(signed(r_Shift1), 1);
     
    -- Right Shift
    r_Unsigned_R <= shift_right(unsigned(r_Shift1), 2);
    r_Signed_R   <= shift_right(signed(r_Shift1), 2);
 
    wait for 100 ns;
  end process;
end architecture behave;