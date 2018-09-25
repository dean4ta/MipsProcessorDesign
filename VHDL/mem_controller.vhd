library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_controller is
	generic(
		WIDTH		: positive := 32;
		ADDR_WIDTH	: positive := 8); --if changed, ensure if statements are correct size
	port(
		memRead		: in  std_logic;
		memWrite	: in  std_logic;
		inputBus	: in  std_logic_vector(WIDTH-1 downto 0);
		outportEN	: out std_logic;
		writeEN		: out std_logic;
		regSel		: out std_logic_vector(1 downto 0));
end mem_controller;

architecture MYLIFEISOUTOF_CONTROL of mem_controller is
begin
	process(memRead, memWrite, inputBus)
	begin
		--defaults
		writeEN <= '0';
		outportEN <= '0';
		regSel <= "00";
		
		if memRead = '1' then  --reading
			if inputBus = x"0000FFF8" then 
				--choose inport0
				regSel <= "01";
			elsif inputBus = x"0000FFFC" then
				--choose inport0
				regSel <= "10";
			else --RAM addresses
				writeEN <= '0'; --redundant
				regSel <= "00"; --redundant
			end if ;

		elsif memWrite <= '1' and memRead = '0' then --writing
			if inputBus = x"0000FFFC" then
				outportEN <= '1';
			else --RAM addresses
				writeEN <= '1';
			end if ;

		else -- memWrite and memRead are 0
			--do nothing
		end if ;
	end process ;
end MYLIFEISOUTOF_CONTROL;