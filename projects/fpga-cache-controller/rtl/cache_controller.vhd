----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:31:33 10/05/2026 
-- Design Name: 
-- Module Name:    cache_controller - Behavioral 
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

entity cache_controller is
    Port (

        -- Clock and Reset

        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;


        -- CPU Interface

        cpu_addr    : in  STD_LOGIC_VECTOR(15 downto 0);
        cpu_wr_rd   : in  STD_LOGIC;
        cpu_cs      : in  STD_LOGIC;
        cpu_dout    : in  STD_LOGIC_VECTOR(7 downto 0);

        cpu_din     : out STD_LOGIC_VECTOR(7 downto 0);
        cpu_rdy     : out STD_LOGIC;
		  
		  dbg_hit	  : out STD_LOGIC;
		  dbg_check	  : out STD_LOGIC;


        -- BlockRAM Interface

        bram_addr   : out STD_LOGIC_VECTOR(7 downto 0);
        bram_din    : out STD_LOGIC_VECTOR(7 downto 0);
        bram_dout   : in  STD_LOGIC_VECTOR(7 downto 0);
        bram_we     : out STD_LOGIC;


        -- SDRAM Interface

        mem_addr    : out STD_LOGIC_VECTOR(15 downto 0);
        mem_wr_rd   : out STD_LOGIC;
        mem_strb    : out STD_LOGIC;
        mem_din     : out STD_LOGIC_VECTOR(7 downto 0);
        mem_dout    : in  STD_LOGIC_VECTOR(7 downto 0)

    );
end cache_controller;


architecture Behavioral of cache_controller is


    -- Address Signals

    signal awr : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    signal tag    : STD_LOGIC_VECTOR(7 downto 0);
    signal index  : STD_LOGIC_VECTOR(2 downto 0);
    signal offset : STD_LOGIC_VECTOR(4 downto 0);


    -- CPU Request Signals

    signal req_wr_rd : STD_LOGIC := '0';
    signal req_wdata : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');


    -- Cache Metadata

    type tag_array_type is array (0 to 7)
        of STD_LOGIC_VECTOR(7 downto 0);

    signal tag_array : tag_array_type :=
        (others => (others => '0'));

    signal valid_bits : STD_LOGIC_VECTOR(7 downto 0)
        := (others => '0');

    signal dirty_bits : STD_LOGIC_VECTOR(7 downto 0)
        := (others => '0');

    signal hit : STD_LOGIC;


    -- Block Counter

    signal block_count : unsigned(4 downto 0)
        := (others => '0');


    -- CPU Data

    signal cpu_din_reg : STD_LOGIC_VECTOR(7 downto 0)
        := (others => '0');


    -- FSM

    type state_type is (

        IDLE,
        CHECK,

        HIT_READ_ADDR,
        HIT_READ_RETURN,
        HIT_WRITE,

        WB_BRAM_ADDR,
        WB_MEM_SETUP,
        WB_MEM_STROBE,

        REFILL_SETUP,
        REFILL_STROBE,
        REFILL_BRAM_WRITE,

        EXECUTE_REQUEST,

        COMPLETE
    );

    signal state : state_type := IDLE;


begin


    -- Address Split

    tag    <= awr(15 downto 8);
    index  <= awr(7 downto 5);
    offset <= awr(4 downto 0);


    -- Hit Detection

    hit <= '1'
        when
            valid_bits(to_integer(unsigned(index))) = '1'
            and
            tag_array(to_integer(unsigned(index))) = tag
        else '0';


    -- CPU Outputs

    cpu_din <= cpu_din_reg;

    cpu_rdy <= '1'
        when (state = IDLE or state = COMPLETE)
        else '0';
		  
	 --Debug Outputs
	 dbg_hit <= hit;
		  
	 dbg_check <= '1' when state = CHECK else '0';


    -- Main FSM

    process(clk, rst)

        variable idx : integer range 0 to 7;

    begin

        if rst = '1' then

            awr         <= (others => '0');

            req_wr_rd   <= '0';
            req_wdata   <= (others => '0');

            valid_bits  <= (others => '0');
            dirty_bits  <= (others => '0');

            block_count <= (others => '0');

            cpu_din_reg <= (others => '0');

            state       <= IDLE;


        elsif rising_edge(clk) then

            idx := to_integer(unsigned(index));

            case state is


                when IDLE =>

                    if cpu_cs = '1' then

                        awr       <= cpu_addr;
                        req_wr_rd <= cpu_wr_rd;
                        req_wdata <= cpu_dout;

                        state <= CHECK;

                    end if;


                when CHECK =>

                    if hit = '1' then

                        if req_wr_rd = '1' then

                            state <= HIT_WRITE;

                        else

                            state <= HIT_READ_ADDR;

                        end if;

                    else

                        block_count <= (others => '0');

                        if
                            valid_bits(idx) = '1'
                            and
                            dirty_bits(idx) = '1'
                        then

                            state <= WB_BRAM_ADDR;

                        else

                            state <= REFILL_SETUP;

                        end if;

                    end if;


                when HIT_READ_ADDR =>

                    state <= HIT_READ_RETURN;


                when HIT_READ_RETURN =>

                    cpu_din_reg <= bram_dout;

                    state <= COMPLETE;


                when HIT_WRITE =>

                    valid_bits(idx) <= '1';
                    dirty_bits(idx) <= '1';

                    state <= COMPLETE;


                when WB_BRAM_ADDR =>

                    state <= WB_MEM_SETUP;


                when WB_MEM_SETUP =>

                    state <= WB_MEM_STROBE;


                when WB_MEM_STROBE =>

                    if block_count = to_unsigned(31, 5) then

                        block_count <= (others => '0');

                        state <= REFILL_SETUP;

                    else

                        block_count <= block_count + 1;

                        state <= WB_BRAM_ADDR;

                    end if;


                when REFILL_SETUP =>

                    state <= REFILL_STROBE;


                when REFILL_STROBE =>

                    state <= REFILL_BRAM_WRITE;


                when REFILL_BRAM_WRITE =>

                    if block_count = to_unsigned(31, 5) then

                        tag_array(idx)  <= tag;
                        valid_bits(idx) <= '1';
                        dirty_bits(idx) <= '0';

                        block_count <= (others => '0');

                        state <= EXECUTE_REQUEST;

                    else

                        block_count <= block_count + 1;

                        state <= REFILL_SETUP;

                    end if;


                when EXECUTE_REQUEST =>

                    if req_wr_rd = '1' then

                        state <= HIT_WRITE;

                    else

                        state <= HIT_READ_ADDR;

                    end if;


                when COMPLETE =>

                    if cpu_cs = '0' then

                        state <= IDLE;

                    end if;


                when others =>

                    state <= IDLE;

            end case;

        end if;

    end process;


    -- Output Logic

    process(
        state,
        index,
        offset,
        block_count,
        req_wdata,
        bram_dout,
        mem_dout,
        tag_array
    )

        variable idx : integer range 0 to 7;

    begin

        idx := to_integer(unsigned(index));


        -- Default Outputs

        bram_addr <= index & offset;
        bram_din  <= (others => '0');
        bram_we   <= '0';

        mem_addr  <= (others => '0');
        mem_wr_rd <= '0';
        mem_strb  <= '0';
        mem_din   <= (others => '0');


        case state is


            when HIT_READ_ADDR =>

                bram_addr <= index & offset;
                bram_we   <= '0';


            when HIT_READ_RETURN =>

                bram_addr <= index & offset;
                bram_we   <= '0';


            when HIT_WRITE =>

                bram_addr <= index & offset;
                bram_din  <= req_wdata;
                bram_we   <= '1';


            when WB_BRAM_ADDR =>

                bram_addr <=
                    index &
                    STD_LOGIC_VECTOR(block_count);

                bram_we <= '0';


            when WB_MEM_SETUP =>

                bram_addr <=
                    index &
                    STD_LOGIC_VECTOR(block_count);

                mem_addr <=
                    tag_array(idx)
                    & index
                    & STD_LOGIC_VECTOR(block_count);

                mem_din   <= bram_dout;
                mem_wr_rd <= '1';
                mem_strb  <= '0';


            when WB_MEM_STROBE =>

                bram_addr <=
                    index &
                    STD_LOGIC_VECTOR(block_count);

                mem_addr <=
                    tag_array(idx)
                    & index
                    & STD_LOGIC_VECTOR(block_count);

                mem_din   <= bram_dout;
                mem_wr_rd <= '1';
                mem_strb  <= '1';


            when REFILL_SETUP =>

                mem_addr <=
                    tag
                    & index
                    & STD_LOGIC_VECTOR(block_count);

                mem_wr_rd <= '0';
                mem_strb  <= '0';


            when REFILL_STROBE =>

                mem_addr <=
                    tag
                    & index
                    & STD_LOGIC_VECTOR(block_count);

                mem_wr_rd <= '0';
                mem_strb  <= '1';


            when REFILL_BRAM_WRITE =>

                bram_addr <=
                    index &
                    STD_LOGIC_VECTOR(block_count);

                bram_din <= mem_dout;
                bram_we  <= '1';


            when others =>

                null;

        end case;

    end process;


end Behavioral;