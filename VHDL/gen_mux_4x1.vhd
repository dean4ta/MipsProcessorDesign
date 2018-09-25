library ieee;
use ieee.std_logic_1164.all;

entity gen_mux_4x1 is
	generic(
		WIDTH  : positive := 8);
	port(
		input0    : in  std_logic_vector(WIDTH-1 downto 0);
		input1    : in  std_logic_vector(WIDTH-1 downto 0);
		input2    : in  std_logic_vector(WIDTH-1 downto 0);
		input3    : in  std_logic_vector(WIDTH-1 downto 0);
		sel       : in  std_logic_vector(1 downto 0);
		output    : out std_logic_vector(WIDTH-1 downto 0));
end gen_mux_4x1;

architecture GEN_MUX of gen_mux_4x1 is
begin

  with sel select
    output <= input0 when "00",
              input1 when "01",
              input2 when "10",
              input3 when others;
end GEN_MUX;