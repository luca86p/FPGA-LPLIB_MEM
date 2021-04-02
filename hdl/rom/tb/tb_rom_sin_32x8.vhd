-- =============================================================================
-- Whatis        : testbench
-- Project       : 
-- -----------------------------------------------------------------------------
-- File          : tb_rom_sin_32x8.vhd
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
--  Test the behaviour of the different architectures of 
--    rom_sin_32x8.multi_arch.vhd
--
-- -----------------------------------------------------------------------------
-- Dependencies
--
--  lplib_mem.rom_sin_32x8(rtl_case)
--  lplib_mem.rom_sin_32x8(rtl_const)
--  lplib_mem.rom_sin_32x8(rtl_compute)
--  lplib_mem.rom_sin_32x8(rtl_impure)
--  lplib_mem.rom_sin_32x8(rtl_txtproc)
-- 
-- -----------------------------------------------------------------------------
-- Issues
-- 
-- -----------------------------------------------------------------------------
-- Copyright (c) 2021 Luca Pilato
-- MIT License
-- -----------------------------------------------------------------------------
-- date        who               changes
-- 2021-04-02  Luca Pilato       file creation
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
    constant ADDR_WIDTH : positive := 5;


    -- Signals
    -- ----------------------------------------
    signal addr             : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal data_rtl_case    : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_rtl_const   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_rtl_compute : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_rtl_impure  : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_rtl_txtproc : std_logic_vector(DATA_WIDTH-1 downto 0);

  
begin

    -- clock generator 50%
    -- ----------------------------------------
    clk <= not clk after TCLK/2 when en_clk='1' else '0';


    -- Unit(s) Under Test
    -- ----------------------------------------
    i_rtl_case: entity lplib_mem.rom_sin_32x8(rtl_case)
    port map (
        addr        => addr             ,
        data        => data_rtl_case
    );

    i_rtl_const: entity lplib_mem.rom_sin_32x8(rtl_const)
    port map (
        addr        => addr             ,
        data        => data_rtl_const
    );

    i_rtl_compute: entity lplib_mem.rom_sin_32x8(rtl_compute)
    port map (
        addr        => addr             ,
        data        => data_rtl_compute
    );

    i_rtl_impure: entity lplib_mem.rom_sin_32x8(rtl_impure)
    port map (
        addr        => addr             ,
        data        => data_rtl_impure
    );

    i_rtl_txtproc: entity lplib_mem.rom_sin_32x8(rtl_txtproc)
    port map (
        addr        => addr             ,
        data        => data_rtl_txtproc
    );





    -- Check Process
    -- ---------------------------------------- 
    proc_check: process(rst,clk)
    begin
        if falling_edge(clk) then
            if data_rtl_case /= data_rtl_const then
                check_err_counter   <= check_err_counter + 1 ;
                write(OUTPUT, ">>> ERROR: data_rtl_case /= data_rtl_const");
                write(OUTPUT, ">>> VHDL time now " & time'image(now) & LF);
            end if;
            if data_rtl_const /= data_rtl_compute then
                check_err_counter   <= check_err_counter + 1 ;
                write(OUTPUT, ">>> ERROR: data_rtl_const /= data_rtl_compute");
                write(OUTPUT, ">>> VHDL time now " & time'image(now) & LF);
            end if;
            if data_rtl_compute /= data_rtl_impure then
                check_err_counter   <= check_err_counter + 1 ;
                write(OUTPUT, ">>> ERROR: data_rtl_compute /= data_rtl_impure");
                write(OUTPUT, ">>> VHDL time now " & time'image(now) & LF);
            end if;
            if data_rtl_impure /= data_rtl_txtproc then
                check_err_counter   <= check_err_counter + 1 ;
                write(OUTPUT, ">>> ERROR: data_rtl_impure /= data_rtl_txtproc");
                write(OUTPUT, ">>> VHDL time now " & time'image(now) & LF);
            end if;
        end if;
    end process proc_check;


    -- Drive Process
    -- ----------------------------------------   
    proc_drive: process
    begin
        -- ========================================================
        tcase       <= 0;
        --
        en_clk      <= '0';
        rst         <= RST_POL;
        --
        --
        addr        <= (others=>'0'); 
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
        --
        for i in 0 to 2**ADDR_WIDTH-1 loop
            wait until rising_edge(clk);
            addr        <= std_logic_vector(TO_UNSIGNED(i, ADDR_WIDTH));
        end loop;
        wait until rising_edge(clk);
        --
        wait for 1 us;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase       <= 2;
        --
        for k in 0 to 3 loop
            for i in 0 to 2**ADDR_WIDTH-1 loop
                wait until rising_edge(clk);
                addr        <= std_logic_vector(TO_UNSIGNED(i, ADDR_WIDTH));
            end loop;
        end loop;
        wait until rising_edge(clk);
        --
        wait for 1 us;
        wait until rising_edge(clk);
        --
        -- ========================================================
        tcase   <= -1;
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