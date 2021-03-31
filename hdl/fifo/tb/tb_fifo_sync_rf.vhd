-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_fifo_sync_rf.vhd
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
--  Test the behaviour of the fifo
--
-- -----------------------------------------------------------------------------
-- Dependencies
--
--  lplib_mem.fifo_sync_rf(rtl)
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


    -- Signals
    -- ----------------------------------------
    signal clear        : std_logic;
    signal wr           : std_logic;
    signal wrdata       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rd           : std_logic;
    signal rddata       : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal full         : std_logic;
    signal empty        : std_logic;
    signal afull_thr    : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal afull        : std_logic;
    signal aempty_thr   : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal aempty       : std_logic;
    signal data_cnt     : std_logic_vector(ADDR_WIDTH-1 downto 0);
    
    
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
        wait for 0 ns; -- trick to update signals
        write(OUTPUT, ">>> " & msg_ptr.all);
        write(OUTPUT, ">>> VHDL time now " & time'image(now) & LF);
    end procedure print_msg;

    procedure check_slv_uint (
        constant i : in integer;
        signal slv : in std_logic_vector;
        signal err_counter : inout integer
        ) is
    variable msg_ptr : str_ptr;
    begin
        wait for 0 ns; -- trick to update signals
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
    end procedure check_slv_uint;




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
    i_fifo_sync_rf: entity lplib_mem.fifo_sync_rf(rtl)
    generic map (
        RST_POL         => '0'              ,
        DATA_WIDTH      => DATA_WIDTH       ,
        ADDR_WIDTH      => ADDR_WIDTH
    )
    port map (
        clk             => clk              ,
        rst             => rst              ,
        clear           => clear            ,
        wr              => wr               ,
        wrdata          => wrdata           ,
        rd              => rd               ,
        rddata          => rddata           ,
        --
        full            => full             ,
        empty           => empty            ,
        --
        afull_thr       => afull_thr        ,
        afull           => afull            ,
        aempty_thr      => aempty_thr       ,
        aempty          => aempty           ,
        data_cnt        => data_cnt         
    );



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
        wr          <= '0';
        wrdata      <= std_logic_vector(TO_UNSIGNED(0, DATA_WIDTH));
        rd          <= '0';
        --
        --
        afull_thr  <= std_logic_vector(TO_UNSIGNED(2**ADDR_WIDTH-2,ADDR_WIDTH));
        aempty_thr <= std_logic_vector(TO_UNSIGNED(2,ADDR_WIDTH));
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
        msg_ptr     := new string'("write-fast, no-read");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        -- write more data than capability
        for i in 0 to (2**ADDR_WIDTH+10) loop
            wr          <= '1';
            wrdata      <= std_logic_vector(TO_UNSIGNED(i+10, DATA_WIDTH));
            wait until rising_edge(clk);
        end loop;
        wr          <= '0';
        --
        wait for 50 us;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase       <= 2;
        msg_ptr     := new string'("no-write, read-fast");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        -- read more data than capability
        for i in 0 to (2**ADDR_WIDTH+10) loop
            rd          <= '1';
            wait until rising_edge(clk);
            if empty='0' then
                wait until falling_edge(clk); -- check in the middle of clock 
                check_slv_uint(i+10, rddata, err_counter);
            end if;
        end loop;
        rd          <= '0';
        --
        wait for 50 us;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase       <= 3;
        msg_ptr     := new string'("write then read");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        -- write -> read -> write -> ...
        for i in 0 to (2**ADDR_WIDTH+10) loop
            wr          <= '1';
            wrdata      <= std_logic_vector(TO_UNSIGNED(i+20, DATA_WIDTH));
            wait until rising_edge(clk);
            wr          <= '0';
            rd          <= '1';
            wait until rising_edge(clk);
            rd          <= '0';
        end loop;
        --
        wait for 50 us;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase       <= 4;
        msg_ptr     := new string'("write + read");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        -- write one data
        for i in 0 to (2**ADDR_WIDTH+10) loop
            wr          <= '1';
            rd          <= '1';
            wrdata      <= std_logic_vector(TO_UNSIGNED(i+10, DATA_WIDTH));
            wait until rising_edge(clk);
            wr          <= '0';
            rd          <= '0';
        end loop;
        --
        wait for 50 us;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase       <= 5;
        msg_ptr     := new string'("write++, read, clear");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        -- write one data
        for i in 0 to (2**ADDR_WIDTH+10) loop
            wr          <= '1';
            if i > 10 then
                rd          <= '1';
            end if;
            wrdata      <= std_logic_vector(TO_UNSIGNED(i+20, DATA_WIDTH));
            wait until rising_edge(clk);
            wr          <= '0';
            rd          <= '0';
        end loop;
        --
        wait for 2 us;
        wait until rising_edge(clk);
        clear       <= '1';
        wait until rising_edge(clk);
        clear       <= '0';                
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
            write(OUTPUT, ">>> TEST FAILED   ...sorry");
        else
            write(OUTPUT, ">>> TEST SUCCESS  ...Wubba Lubba Dub Dub!");
        end if;
        write(OUTPUT, ">>> err_counter: " & integer'image(err_counter));
        write(OUTPUT, "================================================================");
        --
        wait;
    end process proc_drive;

end beh;