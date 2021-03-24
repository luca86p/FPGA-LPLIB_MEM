-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_ram_sdp_sc.vhd
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
-- -----------------------------------------------------------------------------
-- Dependencies
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
    signal raddr    : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal waddr    : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal re       : std_logic;
    signal we       : std_logic;
    signal di       : std_logic_vector(DATA_WIDTH-1 downto 0);


    type str_ptr is access string;

    -- Procedures
    -- ----------------------------------------
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
    i_ram_sync_sdp_sc_nc_DO0: entity lplib_mem.ram_sync_sdp_sc_nc(rtl)
    generic map (
        RST_POL         => RST_POL       ,
        DATA_WIDTH      => DATA_WIDTH    ,
        ADDR_WIDTH      => ADDR_WIDTH    ,
        DO_REG          => 0
    )
    port map (
        clk             => clk           ,
        rst             => rst           ,
        raddr           => raddr         ,
        waddr           => waddr         ,
        re              => re            ,
        we              => we            ,
        di              => di            ,
        do              => open
    );

    i_ram_sync_sdp_sc_nc_DO1: entity lplib_mem.ram_sync_sdp_sc_nc(rtl)
    generic map (
        RST_POL         => RST_POL       ,
        DATA_WIDTH      => DATA_WIDTH    ,
        ADDR_WIDTH      => ADDR_WIDTH    ,
        DO_REG          => 1
    )
    port map (
        clk             => clk           ,
        rst             => rst           ,
        raddr           => raddr         ,
        waddr           => waddr         ,
        re              => re            ,
        we              => we            ,
        di              => di            ,
        do              => open
    );
    
    i_ram_sync_sdp_sc_rf_DO0: entity lplib_mem.ram_sync_sdp_sc_rf(rtl)
    generic map (
        RST_POL         => RST_POL       ,
        DATA_WIDTH      => DATA_WIDTH    ,
        ADDR_WIDTH      => ADDR_WIDTH    ,
        DO_REG          => 0
    )
    port map (
        clk             => clk           ,
        rst             => rst           ,
        raddr           => raddr         ,
        waddr           => waddr         ,
        re              => re            ,
        we              => we            ,
        di              => di            ,
        do              => open
    );

    i_ram_sync_sdp_sc_rf_DO1: entity lplib_mem.ram_sync_sdp_sc_rf(rtl)
    generic map (
        RST_POL         => RST_POL       ,
        DATA_WIDTH      => DATA_WIDTH    ,
        ADDR_WIDTH      => ADDR_WIDTH    ,
        DO_REG          => 1
    )
    port map (
        clk             => clk           ,
        rst             => rst           ,
        raddr           => raddr         ,
        waddr           => waddr         ,
        re              => re            ,
        we              => we            ,
        di              => di            ,
        do              => open
    );

    i_ram_sync_sdp_sc_wf_DO0: entity lplib_mem.ram_sync_sdp_sc_wf(rtl)
    generic map (
        RST_POL         => RST_POL       ,
        DATA_WIDTH      => DATA_WIDTH    ,
        ADDR_WIDTH      => ADDR_WIDTH    ,
        DO_REG          => 0
    )
    port map (
        clk             => clk           ,
        rst             => rst           ,
        raddr           => raddr         ,
        waddr           => waddr         ,
        re              => re            ,
        we              => we            ,
        di              => di            ,
        do              => open
    );

    i_ram_sync_sdp_sc_wf_DO1: entity lplib_mem.ram_sync_sdp_sc_wf(rtl)
    generic map (
        RST_POL         => RST_POL       ,
        DATA_WIDTH      => DATA_WIDTH    ,
        ADDR_WIDTH      => ADDR_WIDTH    ,
        DO_REG          => 1
    )
    port map (
        clk             => clk           ,
        rst             => rst           ,
        raddr           => raddr         ,
        waddr           => waddr         ,
        re              => re            ,
        we              => we            ,
        di              => di            ,
        do              => open
    );

  


    -- Drive Process
    -- ----------------------------------------   
    proc_drive: process
        variable msg_ptr    : str_ptr := NULL;
    begin
        tcase       <= 0;
        msg_ptr     := new string'("SIMULATION START");
        print_tcase(tcase, msg_ptr);
        --
        en_clk      <= '0';
        rst         <= RST_POL;
        --
        --
        raddr      <= std_logic_vector(TO_UNSIGNED(0,ADDR_WIDTH));
        waddr      <= std_logic_vector(TO_UNSIGNED(0,ADDR_WIDTH));
        re         <= '0';
        we         <= '0';
        di         <= std_logic_vector(TO_UNSIGNED(0,DATA_WIDTH));
        --
        --
        wait for 123 ns;
        en_clk     <= '1';
        wait for 123 ns;
        wait until falling_edge(clk);
        -- reset release
        rst        <= not RST_POL;
        wait for 123 ns;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase           <= 1;
        msg_ptr     := new string'("init wr-burst loop");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        we         <= '1';
        for i in 0 to 2**ADDR_WIDTH-1 loop
            waddr       <= std_logic_vector(TO_UNSIGNED(i,ADDR_WIDTH));
            di          <= std_logic_vector(TO_UNSIGNED(i+16,DATA_WIDTH));
            wait until rising_edge(clk);
        end loop;
        we         <= '0';
        --
        wait for 333 ns;
        wait until rising_edge(clk);
        --  
        --  
        -- ========================================================
        tcase           <= 2;
        msg_ptr     := new string'("rd-burst loop");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        re         <= '1';
        for i in 0 to 2**ADDR_WIDTH-1 loop
            raddr       <= std_logic_vector(TO_UNSIGNED(i,ADDR_WIDTH));
            wait until rising_edge(clk);
        end loop;
        re         <= '0';
        --
        wait for 333 ns;
        wait until rising_edge(clk);
        --
        --
        -- ======================================================== 
        tcase           <= 3;
        msg_ptr     := new string'("wr/rd-burst loop");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        re         <= '1';
        we         <= '1';
        for i in 0 to 2**ADDR_WIDTH-1 loop
            waddr       <= std_logic_vector(TO_UNSIGNED(i,ADDR_WIDTH));
            di          <= std_logic_vector(TO_UNSIGNED(i+32,DATA_WIDTH));
            raddr       <= std_logic_vector(TO_UNSIGNED(i,ADDR_WIDTH));
            wait until rising_edge(clk);
        end loop;
        re         <= '0';
        we         <= '0';
        --
        wait for 333 ns;
        wait until rising_edge(clk);
        --
        --
        -- ========================================================
        tcase           <= 4;
        msg_ptr     := new string'("rd-pulse loop");
        print_tcase(tcase, msg_ptr);
        wait until rising_edge(clk);
        --
        for i in 0 to 2**ADDR_WIDTH-1 loop
            re         <= '1';
            raddr       <= std_logic_vector(TO_UNSIGNED(i,ADDR_WIDTH));
            wait until rising_edge(clk);
            re         <= '0';
            wait until rising_edge(clk);
            wait until rising_edge(clk);
            wait until rising_edge(clk);
        end loop;
        --
        wait for 333 ns;
        wait until rising_edge(clk);
        --
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
