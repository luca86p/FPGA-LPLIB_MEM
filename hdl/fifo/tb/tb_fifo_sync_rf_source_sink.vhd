-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_fifo_sync_rf_source_sink.vhd
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
--  Emulate the logics to source and sink from fifo(s)
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
    signal clear            : std_logic;
    signal rf_wr            : std_logic;
    signal rf_wrdata        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rf_rd            : std_logic;
    signal rf_rddata        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rf_full          : std_logic;
    signal rf_empty         : std_logic;
    signal rf_afull_thr     : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal rf_afull         : std_logic;
    signal rf_aempty_thr    : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal rf_aempty        : std_logic;
    signal rf_data_cnt      : std_logic_vector(ADDR_WIDTH-1 downto 0);
    

    -- Source
    -- ----------------------------------------
    signal hold_wrdata      : std_logic; -- after rf_wr and full
  
    -- Sink
    -- ----------------------------------------
    signal valid_rddata     : std_logic; -- after rf_rd and not empty 


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
        wr              => rf_wr            ,
        wrdata          => rf_wrdata        ,
        rd              => rf_rd            ,
        rddata          => rf_rddata        ,
        full            => rf_full          ,
        empty           => rf_empty         ,
        afull_thr       => rf_afull_thr     ,
        afull           => rf_afull         ,
        aempty_thr      => rf_aempty_thr    ,
        aempty          => rf_aempty        ,
        data_cnt        => rf_data_cnt         
    );



    -- Source Process
    -- ---------------------------------------- 
    proc_source: process(rst,clk)
        variable i          : integer := 0;
        variable check_i    : integer := 0;
    begin
        if rst=RST_POL then
            i           := 0;
            rf_wr       <= '0';
            rf_wrdata   <= (others=>'0');
            check_v     <= (others=>0);
            check_i     := 0;
            hold_wrdata <= '0';
        elsif rising_edge(clk) then
            i           := (i + 1) mod 2**DATA_WIDTH;
            if tcase=1 then -- 2-clock write
                if rf_full='0' and rf_wr='0' then
                    rf_wr       <= '1';
                    rf_wrdata   <= std_logic_vector(TO_UNSIGNED(i, DATA_WIDTH));
                    check_v(check_i) <= i;
                    check_i     := (check_i+1) mod check_len;
                else
                    rf_wr       <= '0';
                end if;
            elsif tcase=2 then -- 2-clock write
                if rf_full='0' and rf_wr='0' then
                    rf_wr       <= '1';
                    rf_wrdata   <= std_logic_vector(TO_UNSIGNED(i, DATA_WIDTH));
                    check_v(check_i) <= i;
                    check_i     := (check_i+1) mod check_len;
                else
                    rf_wr       <= '0';
                end if;
            elsif tcase=3 then -- 2-clock write-slow
                -- add some delay
                if rf_full='0' and rf_wr='0' and (i mod 5)=0 then
                    rf_wr       <= '1';
                    rf_wrdata   <= std_logic_vector(TO_UNSIGNED(i, DATA_WIDTH));
                    check_v(check_i) <= i;
                    check_i     := (check_i+1) mod check_len;
                else
                    rf_wr       <= '0';
                end if;
            elsif tcase=4 then -- 1-clock write
                if rf_full='0' then
                    rf_wr       <= '1';
                    if hold_wrdata='0' then
                        -- can write new data
                        rf_wrdata   <= std_logic_vector(TO_UNSIGNED(i, DATA_WIDTH));
                        check_v(check_i) <= i;
                        check_i     := (check_i+1) mod check_len;
                    else -- rf_wrdata is already buffered
                        hold_wrdata <= '0';
                    end if;
                elsif rf_full='1' then
                    if rf_wr='1' then -- the current data wasn't written
                        hold_wrdata <= '1';
                    end if;
                    rf_wr       <= '0';
                end if;
            elsif tcase=5 then -- 2-clock write
                if rf_full='0' and rf_wr='0' then
                    rf_wr       <= '1';
                    rf_wrdata   <= std_logic_vector(TO_UNSIGNED(i, DATA_WIDTH));
                    check_v(check_i) <= i;
                    check_i     := (check_i+1) mod check_len;
                else
                    rf_wr       <= '0';
                end if;
            elsif tcase=6 then -- 1-clock write
                if rf_full='0' then
                    rf_wr       <= '1';
                    if hold_wrdata='0' then
                        -- can write new data
                        rf_wrdata   <= std_logic_vector(TO_UNSIGNED(i, DATA_WIDTH));
                        check_v(check_i) <= i;
                        check_i     := (check_i+1) mod check_len;
                    else -- rf_wrdata is already buffered
                        hold_wrdata <= '0';
                    end if;
                elsif rf_full='1' then
                    if rf_wr='1' then -- the current data wasn't written
                        hold_wrdata <= '1';
                    end if;
                    rf_wr       <= '0';
                end if;
            else -- other test cases
                rf_wr       <= '0';
            end if;
        end if;
    end process proc_source;



    -- Sink Process
    -- ---------------------------------------- 
    proc_sink: process(rst,clk)
        variable i          : integer := 0;
        variable check_i    : integer := 0;
    begin
        if rst=RST_POL then
            i           := 0;
            rf_rd       <= '0';
            check_i     := 0;
            valid_rddata <= '0'; 
        elsif rising_edge(clk) then
            i           := (i + 1) mod 2**DATA_WIDTH;
            -- rd control
            -- default
            valid_rddata <= rf_rd;
            --
            if tcase=1 then -- 2-clock read
                if rf_empty='0' and rf_rd='0' then
                    rf_rd       <= '1';
                else
                    rf_rd       <= '0';
                end if;
            elsif tcase=2 then -- 2-clock read-slow
                -- add some delay
                if rf_empty='0' and rf_rd='0' and (i mod 3)=0 then
                    rf_rd       <= '1';
                else
                    rf_rd       <= '0';
                end if;
            elsif tcase=3 then -- 2-clock read
                if rf_empty='0' and rf_rd='0' then
                    rf_rd       <= '1';
                else
                    rf_rd       <= '0';
                end if;
            elsif tcase=4 then -- 2-clock read
                if rf_empty='0' and rf_rd='0' then
                    rf_rd       <= '1';
                else
                    rf_rd       <= '0';
                end if;
            elsif tcase=5 then -- 1-clock read
                if rf_empty='0' then
                    rf_rd       <= '1';
                elsif rf_empty='1' then
                    if rf_rd='1' then
                        valid_rddata <= '0';
                    end if;
                    rf_rd       <= '0';
                end if;
            elsif tcase=6 then -- 1-clock read
                if rf_empty='0' then
                    rf_rd       <= '1';
                elsif rf_empty='1' then
                    if rf_rd='1' then
                        valid_rddata <= '0';
                    end if;
                    rf_rd       <= '0';
                end if;
            else -- other test cases
                rf_rd       <= '0';
                valid_rddata <= '0';
            end if;
            -- rd check cycle
            if valid_rddata='1' then
                check_uint_slv(check_v(check_i), rf_rddata, check_err_counter);
                check_i     := (check_i+1) mod check_len;
            end if;
        end if;
    end process proc_sink;




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
        rf_afull_thr  <= std_logic_vector(TO_UNSIGNED(2**ADDR_WIDTH-2,ADDR_WIDTH));
        rf_aempty_thr <= std_logic_vector(TO_UNSIGNED(2,ADDR_WIDTH));
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
        msg_ptr     := new string'("2-clock write read");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        --
        wait for 50 us;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase       <= 2;
        msg_ptr     := new string'("2-clock write read-slow");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        --
        wait for 50 us;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase       <= 3;
        msg_ptr     := new string'("2-clock write-slow read");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        --
        wait for 50 us;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase       <= 4;
        msg_ptr     := new string'("1-clock write, 2-clock read");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        --
        wait for 50 us;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase       <= 5;
        msg_ptr     := new string'("2-clock write, 1-clock read");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        --
        wait for 50 us;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase       <= 6;
        msg_ptr     := new string'("1-clock write, 1-clock read");
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
            write(OUTPUT, ">>> TEST FAILED  ... sorry");
        else
            write(OUTPUT, ">>> TEST SUCCESS ... Wubba Lubba Dub Dub!");
        end if;
        write(OUTPUT, ">>> err_counter: " & integer'image(err_counter));
        write(OUTPUT, "================================================================");
        --
        wait;
    end process proc_drive;

end beh;
