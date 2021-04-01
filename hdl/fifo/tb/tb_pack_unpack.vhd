-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_pack_unpack.vhd
-- Language      : VHDL-93
-- Module        : tb
-- Library       : lplib_mem_verif
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  Test the behaviour of the data_pack and data_unpack flow
--
-- -----------------------------------------------------------------------------
-- Dependencies
--
--  lplib_mem.fifo_sync_rf_ready(rtl)
--  lplib_mem.data_pack(rtl)
--  lplib_mem.data_unpack(rtl)
-- 
-- -----------------------------------------------------------------------------
-- Issues
-- 
-- -----------------------------------------------------------------------------
-- Copyright (c) 2021 Luca Pilato
-- MIT License
-- -----------------------------------------------------------------------------
-- date        who               changes
-- 2019-05-07  Luca Pilato       file creation
-- =============================================================================


-- STD lib
-- ----------------------------------------
use std.textio.all;

-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_textio.all;

-- User lib
-- ----------------------------------------
library lplib_mem;


entity tb is
end entity tb;


architecture beh of tb is

    -- TB common parameters and signals
    -- ----------------------------------------
    constant RST_POL    : std_logic := '0';
    -- constant CLK_FREQ   : positive := 50000000; -- 50 MHz (20 ns)
    -- constant CLK_FREQ   : positive := 33000000; -- 33 MHz (30.303 ns)
    -- constant CLK_FREQ   : positive := 25000000; -- 25 MHz (40 ns)
    -- constant CLK_FREQ   : positive := 20000000; -- 20 MHz (50 ns)
    constant CLK_FREQ   : positive := 10000000; -- 10 MHz (100 ns)
    --
    constant TCLK       : time := 1.0e10/real(CLK_FREQ) * (0.1 ns); -- clock period
    constant DUTYCLK    : real := 0.5; -- clock duty-cycle

    signal en_clk       : std_logic;
    --
    signal clk          : std_logic := '0';
    signal rst          : std_logic := RST_POL;
    --
    signal tcase        : integer := 0;


    -- Check Process
    -- ----------------------------------------
    signal err_counter          : integer   := 0;
    signal check_err_counter    : integer   := 0;


    -- Constant
    -- ----------------------------------------
    constant DATA_WIDTH : positive := 8;
    constant ADDR_WIDTH : positive := 6;
    constant M          : positive := 4;

    -- Signals
    -- ----------------------------------------
    signal clear            : std_logic;

    signal rx_wr            : std_logic;
    signal rx_wrdata        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rx_rd            : std_logic;
    signal rx_rddata        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rx_full          : std_logic;
    signal rx_empty         : std_logic;

    signal pack_wr          : std_logic;
    signal pack_wrdata      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal pack_rd          : std_logic;
    signal pack_rddata      : std_logic_vector(M*DATA_WIDTH-1 downto 0);
    signal pack_full        : std_logic;
    signal pack_empty       : std_logic;

    signal unpack_wr        : std_logic;
    signal unpack_wrdata    : std_logic_vector(M*DATA_WIDTH-1 downto 0);
    signal unpack_rd        : std_logic;
    signal unpack_rddata    : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal unpack_full      : std_logic;
    signal unpack_empty     : std_logic;

    signal tx_wr            : std_logic;
    signal tx_wrdata        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal tx_rd            : std_logic;
    signal tx_rddata        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal tx_full          : std_logic;
    signal tx_empty         : std_logic;




    -- Source
    -- ----------------------------------------
    signal hold_wrdata      : std_logic; -- after wr and full



    -- Check Array (High level FIFO)
    -- ----------------------------------------
    constant check_len  : integer := 100;
    type t_check_v is array (0 to check_len-1) of integer;
    signal check_v      : t_check_v;





    -- Procedures
    -- ----------------------------------------
    type str_ptr is access string;
    procedure print_tcase (
        signal tcase : in integer;
        variable msg_ptr : in str_ptr
    ) is
    begin
        wait for 0 ns; -- trick to update signals
        write(OUTPUT, "################################################################");
        write(OUTPUT, ">>> tcase: " & integer'image(tcase));
        write(OUTPUT, ">>> " & msg_ptr.all);
        write(OUTPUT, ">>> VHDL time now " & time'image(now) & LF);
        write(OUTPUT, "################################################################");
    end procedure print_tcase;

    procedure print_msg (
        variable msg_ptr : in str_ptr
    ) is
    begin
        -- wait for 0 ns; -- trick to update signals
        write(OUTPUT, ">>> " & msg_ptr.all);
        write(OUTPUT, ">>> VHDL time now " & time'image(now) & LF);
    end procedure print_msg;

    procedure check_uint_slv (
        constant i : in integer;
        signal slv : in std_logic_vector;
        signal err_counter : inout integer
        ) is
    variable msg_ptr : str_ptr;
    begin
        -- wait for 0 ns; -- trick to update signals
        if TO_INTEGER(unsigned(slv)) /= i then
            msg_ptr     := new string'(
                "ERROR: expected " & integer'image(i) &
                " got " & integer'image(TO_INTEGER(unsigned(slv)))
            );
            print_msg(msg_ptr);
            err_counter <= err_counter + 1;
        else
            msg_ptr     := new string'(
            "GOOD: expected " & integer'image(i) &
            " got " & integer'image(TO_INTEGER(unsigned(slv)))
            );
            print_msg(msg_ptr);
        end if;               
    end procedure check_uint_slv;


begin

    -- clock generator 50%
    -- ----------------------------------------
    clk <= not clk after TCLK/2 when en_clk='1' else '0';
    
    
    -- clock generator DUTYCLK% 
    -- ----------------------------------------
    -- proc_clk: process(clk, en_clk)
    -- begin
    --     if en_clk='1' then
    --         if clk='0' then
    --             clk <= '1' after TCLK*(1.0-DUTYCLK);
    --         else
    --             clk <= '0' after TCLK*DUTYCLK;
    --         end if;
    --     else
    --         clk <= '0'
    --     end if;
    -- end process proc_clk;



    -- Unit(s) Under Test
    -- ----------------------------------------
    --    1:1          4:5          4:5            4:5             4:5           
    --                      ------       --------
    --      ---------      |      |     |        |      ---------
    -- ==> | rx_fifo | ==> | pack | ==> | unpack | ==> | tx_fifo | ==>
    --      ---------      |      |     |        |      ---------
    --                      ------       --------
    -- ----------------------------------------

    i_rx_fifo: entity lplib_mem.fifo_sync_rf_ready(rtl)
    generic map (
        RST_POL         => '0'              ,
        DATA_WIDTH      => DATA_WIDTH       ,
        ADDR_WIDTH      => ADDR_WIDTH
    )
    port map (
        clk             => clk              ,
        rst             => rst              ,
        clear           => clear            ,
        wr              => rx_wr            ,
        wrdata          => rx_wrdata        ,
        rd              => rx_rd            ,
        rddata          => rx_rddata        ,
        full            => rx_full          ,
        empty           => rx_empty         ,
        afull_thr       => (others=>'0')    ,
        afull           => open             ,
        aempty_thr      => (others=>'0')    ,
        aempty          => open             ,
        data_cnt        => open   
    );

    rx_rd           <= (not pack_full) and (not rx_empty);
    pack_wr         <= (not pack_full) and (not rx_empty);
    pack_wrdata     <= rx_rddata;

    i_pack: entity lplib_mem.data_pack(rtl)
    generic map (
        RST_POL         => '0'              ,
        DATA_WIDTH      => DATA_WIDTH       ,
        M               => M                ,
        DATA_SWAP       => 0            
    )
    port map (
        clk             => clk              ,
        rst             => rst              ,
        wr              => pack_wr          ,
        wrdata          => pack_wrdata      ,
        rd              => pack_rd          ,
        rddata          => pack_rddata      ,
        full            => pack_full        ,
        empty           => pack_empty
    );

    pack_rd         <= unpack_empty and pack_full;
    unpack_wr       <= unpack_empty and pack_full;
    unpack_wrdata   <= pack_rddata;

    i_unpack: entity lplib_mem.data_unpack(rtl)
    generic map (
        RST_POL         => '0'              ,
        DATA_WIDTH      => DATA_WIDTH       ,
        M               => M                ,
        DATA_SWAP       => 0            
    )
    port map (
        clk             => clk              ,
        rst             => rst              ,
        wr              => unpack_wr        ,
        wrdata          => unpack_wrdata    ,
        rd              => unpack_rd        ,
        rddata          => unpack_rddata    ,
        full            => unpack_full      ,
        empty           => unpack_empty
    );

    unpack_rd       <= (not tx_full) and (not unpack_empty);
    tx_wr           <= (not tx_full) and (not unpack_empty);
    tx_wrdata       <= unpack_rddata;


    i_tx_fifo: entity lplib_mem.fifo_sync_rf_ready(rtl)
    generic map (
        RST_POL         => '0'              ,
        DATA_WIDTH      => DATA_WIDTH       ,
        ADDR_WIDTH      => ADDR_WIDTH
    )
    port map (
        clk             => clk              ,
        rst             => rst              ,
        clear           => clear            ,
        wr              => tx_wr            ,
        wrdata          => tx_wrdata        ,
        rd              => tx_rd            ,
        rddata          => tx_rddata        ,
        full            => tx_full          ,
        empty           => tx_empty         ,
        afull_thr       => (others=>'0')    ,
        afull           => open             ,
        aempty_thr      => (others=>'0')    ,
        aempty          => open             ,
        data_cnt        => open   
    );



    -- Source Process
    -- ---------------------------------------- 
    proc_source: process(rst,clk)
        variable i          : integer := 0;
    begin
        if rst=RST_POL then
            i           := 0;
            rx_wr       <= '0';
            rx_wrdata   <= (others=>'0');
            hold_wrdata <= '0';
        elsif rising_edge(clk) then
            i           := (i + 1) mod 2**DATA_WIDTH;
            if tcase=1 then -- test 4 bytes
                rx_wr       <= '1';
                rx_wrdata   <= std_logic_vector(TO_UNSIGNED(i, DATA_WIDTH));
            elsif tcase=2 then -- wait
                rx_wr       <= '0';
            elsif tcase=3 then -- 1-clock write
                if rx_full ='0' then
                    rx_wr       <= '1';
                    if hold_wrdata='0' then
                        -- can write new data
                        rx_wrdata   <= std_logic_vector(TO_UNSIGNED(i, DATA_WIDTH));
                    else -- rx_wrdata is already buffered
                        hold_wrdata <= '0';
                    end if;
                elsif rx_full ='1' then
                    if rx_wr ='1' then -- the current data wasn't written
                        hold_wrdata <= '1';
                    end if;
                    rx_wr       <= '0';
                end if;
            else -- other test cases
                rx_wr       <= '0';
            end if;
        end if;
    end process proc_source;
        
            


    -- Sink Process
    -- ---------------------------------------- 
    proc_sink: process(rst,clk)
        variable i          : integer := 0;
    begin
        if rst=RST_POL then
            tx_rd          <= '0';
        elsif rising_edge(clk) then
            -- always 1-clock read
            if tx_empty ='0' then
                tx_rd          <= '1';
            elsif tx_empty ='1' then
                tx_rd          <= '0';
            end if;
        end if;
    end process proc_sink;





    -- Check Process
    -- ---------------------------------------- 
    proc_check: process(rst,clk)
        variable i_wr       : integer := 0;
        variable i_rd       : integer := 0;
    begin
        if rst=RST_POL then
            check_v     <= (others=>0);
            i_wr        := 0;
            i_rd        := 0;
        elsif rising_edge(clk) then
            if rx_wr='1' and rx_full='0' then
                check_v(i_wr) <= TO_INTEGER(unsigned(rx_wrdata));
                i_wr        := (i_wr+1) mod check_len;
            end if;
            --
            if tx_rd='1' and tx_empty='0' then
                check_uint_slv(check_v(i_rd), tx_rddata, check_err_counter);
                i_rd        := (i_rd+1) mod check_len;
            end if;
        end if;
    end process proc_check;



    -- Drive Process
    -- ----------------------------------------   
    proc_drive: process
        variable msg_ptr    : str_ptr := NULL;
    begin
        -- ========================================================
        tcase       <= 0;
        msg_ptr     := new string'("SIMULATION START");
        print_tcase(tcase, msg_ptr);
        --
        en_clk      <= '0';
        rst         <= RST_POL;
        --
        clear       <= '0';
        --
        --
        --
        wait for 123 ns;
        en_clk     <= '1';
        wait for 123 ns;
        wait until falling_edge(clk);
        rst        <= not RST_POL;
        wait for 123 ns;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase       <= 1;
        msg_ptr     := new string'("4 byte test");
        print_tcase(tcase, msg_ptr);
        --
        -- 4 clock specific
        --
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase       <= 2;
        msg_ptr     := new string'("wait");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        --
        wait for 50 us;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase       <= 3;
        msg_ptr     := new string'("full speed write");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        --
        wait for 50 us;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase   <= -1;
        msg_ptr     := new string'("Power Off");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        wait for 333 ns;
        wait until rising_edge(clk);
        rst        <= '0';
        wait for 333 ns;
        en_clk     <= '0';
        wait for 333 ns;
        --
        err_counter <= err_counter + check_err_counter;
        wait for 333 ns;
        --
        --
        write(OUTPUT, "================================================================");
        write(OUTPUT, ">>> SIMULATION END");
        write(OUTPUT, ">>> VHDL time now " & time'image(now) & LF);
        -- write(OUTPUT, "Time now " & to_string(now)); -- if VHDL-2008
        write(OUTPUT, "================================================================");
        if err_counter /= 0 then
            write(OUTPUT, ">>> TEST FAILED   ... sorry");
        else
            write(OUTPUT, ">>> TEST SUCCESS  ... Wubba Lubba Dub Dub!");
        end if;
        write(OUTPUT, ">>> err_counter: " & integer'image(err_counter));
        write(OUTPUT, "================================================================");
        --
        wait;
    end process proc_drive;

end beh;