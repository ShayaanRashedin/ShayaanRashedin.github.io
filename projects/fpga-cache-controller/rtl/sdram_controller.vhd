----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:35:05 10/05/2026 
-- Design Name: 
-- Module Name:    sdram_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sdram_controller is
    Port (
        clk     : in  STD_LOGIC;
        addr    : in  STD_LOGIC_VECTOR(15 downto 0);
        wr_rd   : in  STD_LOGIC;
        memstrb : in  STD_LOGIC;
        din     : in  STD_LOGIC_VECTOR(7 downto 0);
        dout    : out STD_LOGIC_VECTOR(7 downto 0)
    );
end sdram_controller;


architecture Behavioral of sdram_controller is

    -- Memory

    type memory_type is array (0 to 8191)
        of STD_LOGIC_VECTOR(7 downto 0);

    signal memory : memory_type :=
        (others => (others => '0'));

    attribute ram_style : string;
    attribute ram_style of memory : signal is "block";

    signal dout_reg : STD_LOGIC_VECTOR(7 downto 0)
        := (others => '0');

begin

    -- Memory Operation

    process(clk)
    begin

        if rising_edge(clk) then

            if memstrb = '1' then

                if wr_rd = '1' then

                    memory(
                        to_integer(unsigned(addr(12 downto 0)))
                    ) <= din;

                else

                    dout_reg <= memory(
                        to_integer(unsigned(addr(12 downto 0)))
                    );

                end if;

            end if;

        end if;

    end process;


    -- Data Output

    dout <= dout_reg;


end Behavioral;