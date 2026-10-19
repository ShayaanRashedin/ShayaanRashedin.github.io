library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cache_top is
    Port (
        clk : in STD_LOGIC
    );
end cache_top;


architecture Behavioral of cache_top is


    -- CPU Generator

    component CPU_gen
        Port (
            clk     : in  STD_LOGIC;
            rst     : in  STD_LOGIC;
            trig    : in  STD_LOGIC;
            Address : out STD_LOGIC_VECTOR(15 downto 0);
            wr_rd   : out STD_LOGIC;
            cs      : out STD_LOGIC;
            DOut    : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;


    -- Cache Controller

    component cache_controller
        Port (
            clk       : in  STD_LOGIC;
            rst       : in  STD_LOGIC;

            cpu_addr  : in  STD_LOGIC_VECTOR(15 downto 0);
            cpu_wr_rd : in  STD_LOGIC;
            cpu_cs    : in  STD_LOGIC;
            cpu_dout  : in  STD_LOGIC_VECTOR(7 downto 0);

            cpu_din   : out STD_LOGIC_VECTOR(7 downto 0);
            cpu_rdy   : out STD_LOGIC;
				
				dbg_hit   : out STD_LOGIC;
				dbg_check : out STD_LOGIC;

            bram_addr : out STD_LOGIC_VECTOR(7 downto 0);
            bram_din  : out STD_LOGIC_VECTOR(7 downto 0);
            bram_dout : in  STD_LOGIC_VECTOR(7 downto 0);
            bram_we   : out STD_LOGIC;

            mem_addr  : out STD_LOGIC_VECTOR(15 downto 0);
            mem_wr_rd : out STD_LOGIC;
            mem_strb  : out STD_LOGIC;
            mem_din   : out STD_LOGIC_VECTOR(7 downto 0);
            mem_dout  : in  STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;


    -- BlockRAM

    component bram
        Port (
            clka  : in  STD_LOGIC;
            wea   : in  STD_LOGIC_VECTOR(0 downto 0);
            addra : in  STD_LOGIC_VECTOR(7 downto 0);
            dina  : in  STD_LOGIC_VECTOR(7 downto 0);
            douta : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;


    -- SDRAM Controller

    component sdram_controller
        Port (
            clk     : in  STD_LOGIC;
            addr    : in  STD_LOGIC_VECTOR(15 downto 0);
            wr_rd   : in  STD_LOGIC;
            memstrb : in  STD_LOGIC;
            din     : in  STD_LOGIC_VECTOR(7 downto 0);
            dout    : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;


    -- ICON

    component icon
        Port (
            CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            CONTROL1 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0)
        );
    end component;


    -- ILA

    component ila
        Port (
            CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            CLK     : IN STD_LOGIC;
            DATA    : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            TRIG0   : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;


    -- VIO

    component vio
        Port (
            CONTROL   : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            ASYNC_OUT : OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
        );
    end component;


    -- CPU Signals

    signal cpu_addr_sig  : STD_LOGIC_VECTOR(15 downto 0);
    signal cpu_wr_rd_sig : STD_LOGIC;
    signal cpu_cs_sig    : STD_LOGIC;
    signal cpu_dout_sig  : STD_LOGIC_VECTOR(7 downto 0);
    signal cpu_din_sig   : STD_LOGIC_VECTOR(7 downto 0);
    signal cpu_rdy_sig   : STD_LOGIC;
	 
	 signal hit_dbg_sig   : STD_LOGIC;
	 signal check_dbg_sig : STD_LOGIC;


    -- BlockRAM Signals

    signal bram_addr_sig   : STD_LOGIC_VECTOR(7 downto 0);
    signal bram_din_sig    : STD_LOGIC_VECTOR(7 downto 0);
    signal bram_dout_sig   : STD_LOGIC_VECTOR(7 downto 0);
    signal bram_we_sig     : STD_LOGIC;
    signal bram_we_vec_sig : STD_LOGIC_VECTOR(0 downto 0);


    -- SDRAM Signals

    signal mem_addr_sig  : STD_LOGIC_VECTOR(15 downto 0);
    signal mem_wr_rd_sig : STD_LOGIC;
    signal mem_strb_sig  : STD_LOGIC;
    signal mem_din_sig   : STD_LOGIC_VECTOR(7 downto 0);
    signal mem_dout_sig  : STD_LOGIC_VECTOR(7 downto 0);


    -- ChipScope Signals

    signal control0 : STD_LOGIC_VECTOR(35 downto 0);
    signal control1 : STD_LOGIC_VECTOR(35 downto 0);

    signal ila_data : STD_LOGIC_VECTOR(31 downto 0);
    signal trig0    : STD_LOGIC_VECTOR(7 downto 0);

    signal vio_out  : STD_LOGIC_VECTOR(17 downto 0);

    signal rst_sig  : STD_LOGIC;
    signal trig_sig : STD_LOGIC;


begin


    -- VIO Controls

    rst_sig  <= vio_out(0);
    trig_sig <= vio_out(1);


    -- CPU Generator

    system_cpu : CPU_gen
        Port Map (
            clk     => clk,
            rst     => rst_sig,
            trig    => trig_sig,
            Address => cpu_addr_sig,
            wr_rd   => cpu_wr_rd_sig,
            cs      => cpu_cs_sig,
            DOut    => cpu_dout_sig
        );


    -- Cache Controller

    system_cache_controller : cache_controller
        Port Map (
            clk       => clk,
            rst       => rst_sig,

            cpu_addr  => cpu_addr_sig,
            cpu_wr_rd => cpu_wr_rd_sig,
            cpu_cs    => cpu_cs_sig,
            cpu_dout  => cpu_dout_sig,

            cpu_din   => cpu_din_sig,
            cpu_rdy   => cpu_rdy_sig,
				
				dbg_hit   => hit_dbg_sig,
				dbg_check => check_dbg_sig,
				
            bram_addr => bram_addr_sig,
            bram_din  => bram_din_sig,
            bram_dout => bram_dout_sig,
            bram_we   => bram_we_sig,

            mem_addr  => mem_addr_sig,
            mem_wr_rd => mem_wr_rd_sig,
            mem_strb  => mem_strb_sig,
            mem_din   => mem_din_sig,
            mem_dout  => mem_dout_sig
        );


    -- BlockRAM

    bram_we_vec_sig(0) <= bram_we_sig;

    system_bram : bram
        Port Map (
            clka  => clk,
            wea   => bram_we_vec_sig,
            addra => bram_addr_sig,
            dina  => bram_din_sig,
            douta => bram_dout_sig
        );


    -- SDRAM Controller

    system_sdram : sdram_controller
        Port Map (
            clk     => clk,
            addr    => mem_addr_sig,
            wr_rd   => mem_wr_rd_sig,
            memstrb => mem_strb_sig,
            din     => mem_din_sig,
            dout    => mem_dout_sig
        );


    -- ICON

    system_icon : icon
        Port Map (
            CONTROL0 => control0,
            CONTROL1 => control1
        );


    -- ILA

    system_ila : ila
        Port Map (
            CONTROL => control0,
            CLK     => clk,
            DATA    => ila_data,
            TRIG0   => trig0
        );


    -- VIO

    system_vio : vio
        Port Map (
            CONTROL   => control1,
            ASYNC_OUT => vio_out
        );


    -- ILA Data

	ila_data(15 downto 0) <= cpu_addr_sig;

	ila_data(16) <= cpu_wr_rd_sig;
	ila_data(17) <= cpu_cs_sig;
	ila_data(18) <= cpu_rdy_sig;

	ila_data(19) <= mem_wr_rd_sig;
	ila_data(20) <= mem_strb_sig;

	ila_data(28 downto 21) <= cpu_din_sig;

	ila_data(29) <= bram_we_sig;
	ila_data(30) <= rst_sig;
	ila_data(31) <= trig_sig;



    -- ILA Trigger

    trig0(0) <= cpu_cs_sig;
    trig0(7 downto 1) <= (others => '0');


end Behavioral;