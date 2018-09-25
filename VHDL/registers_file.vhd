library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers_file is
    port(
        clk             : in  std_logic;
        rst             : in  std_logic;
        rd_reg1         : in  std_logic_vector(4 downto 0);
        rd_reg2         : in  std_logic_vector(4 downto 0);
        wr_reg          : in  std_logic_vector(4 downto 0);
        regWrite        : in  std_logic;
        jump_and_link   : in  std_logic;
        wr_data         : in  std_logic_vector(31 downto 0);
        rd_data1        : out std_logic_vector(31 downto 0);
        rd_data2        : out std_logic_vector(31 downto 0)
        );
end registers_file;


architecture async_read of registers_file is
    type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array;
begin
    process (clk, rst) is
    begin
        if (rst = '1') then
            for i in regs'range loop
                regs(i) <= (others => '0');
            end loop;
        elsif (rising_edge(clk)) then

        if regWrite = '1' and jump_and_link = '1' then
            regs(31) <= wr_data;
        end if;
----------------
        if wr_reg /= std_logic_vector(to_unsigned(0,5)) then

            if regWrite = '1' and jump_and_link = '0' then
                regs(to_integer(unsigned(wr_reg))) <= wr_data;
            end if;

        end if;
-------------------
               
        end if;
    end process;

    rd_data1 <= regs(to_integer(unsigned(rd_reg1)));
    rd_data2 <= regs(to_integer(unsigned(rd_reg2)));
   
end async_read;