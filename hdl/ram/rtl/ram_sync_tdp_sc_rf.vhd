-- =============================================================================
-- Whatis        : Synchronous RAM, true dual-port, single-clock, read-first
-- Project       : FPGA-LPLIB_MEM
-- -----------------------------------------------------------------------------
-- File          : ram_sync_tdp_sc_rf.vhd
-- Language      : VHDL-93
-- Module        : ram_sync_tdp_sc_rf
-- Library       : lplib_mem
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  RAM type:       [x] synchronous-read    [ ] asynchronous-read
--
--  Interface type:
--      Clock:      [x] CLK     [ ] WCLK/RCLK   [ ] INCLK/OUTCLK    [ ] CLK(A,B)
--      Data:       [ ] DI/DO   [ ] DI/DO(A,B)  [x] DI(A,B)/DO(A,B)
--      Address:    [ ] ADDR    [ ] WA/RA       [x] WA(A,B)/RA(A,B)
--      Enable:     [ ] WE      [ ] WE/RE       [x] WE(A,B)/RE(A,B)
--
--  Read mode:      (apply only if synchronous-read)
--                  [x] old-data (read-first) 
--                  [ ] new-data (write-first)
--                  [ ] no-change
--
--  Generic:
--                  - DO_REG (Additional output register)
--
-- -----------------------------------------------------------------------------
-- Dependencies
-- 
-- -----------------------------------------------------------------------------
-- Issues
--
--  Simultaneously writing to the same address causes data uncertainty.
-- 
-- -----------------------------------------------------------------------------
-- Copyright (c) 2021 Luca Pilato
-- MIT License
-- -----------------------------------------------------------------------------
-- date        who               changes
-- 2019-05-07  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ram_sync_tdp_sc_rf is
    generic (
        RST_POL         : std_logic := '0';
        DATA_WIDTH      : positive  := 8;
        ADDR_WIDTH      : positive  := 6;
        DO_REG          : integer range 0 to 1 := 0
    );
    port (
        rst             : in  std_logic;
        clk             : in  std_logic;
        raddr_a         : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        waddr_a         : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        raddr_b         : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        waddr_b         : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        re_a            : in  std_logic;
        re_b            : in  std_logic;
        we_a            : in  std_logic;
        we_b            : in  std_logic;
        di_a            : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        di_b            : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        do_a            : out std_logic_vector(DATA_WIDTH-1 downto 0);
        do_b            : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end ram_sync_tdp_sc_rf;

architecture rtl of ram_sync_tdp_sc_rf is

    -- 2D array of memory
    constant MEM_LINES : integer := 2**ADDR_WIDTH;

    -- Address section
    signal wa_a_i : integer range 0 to MEM_LINES-1;
    signal ra_a_i : integer range 0 to MEM_LINES-1;
    signal wa_b_i : integer range 0 to MEM_LINES-1;
    signal ra_b_i : integer range 0 to MEM_LINES-1;
    subtype addr_t is std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal ra_a_buf : addr_t;
    signal ra_b_buf : addr_t;

    subtype word_t is std_logic_vector(DATA_WIDTH-1 downto 0);
    type mem_array_t is array (0 to MEM_LINES-1) of word_t;
    signal mem_array    : mem_array_t;

    -- Output section
    signal do_a_mem       : word_t;
    signal do_a_buf       : word_t;
    signal do_b_mem       : word_t;
    signal do_b_buf       : word_t;

begin


    -- WRITE Porta A/B
    -- -------------------------------------------------------------------------
    wa_a_i <= TO_INTEGER(unsigned(waddr_a));
    wa_b_i <= TO_INTEGER(unsigned(waddr_b));

    proc_wr_a: process(clk)
    begin
        if rising_edge(clk) then
            if we_a='1' then
                mem_array(wa_a_i) <= di_a;
            end if;
        end if;
    end process proc_wr_a;

    proc_wr_b: process(clk)
    begin
        if rising_edge(clk) then
            if we_b='1' then
                mem_array(wa_b_i) <= di_b;
            end if;
        end if;
    end process proc_wr_b;


    -- READ old-data (read-first) Porta A/B
    -- -------------------------------------------------------------------------
    ra_a_buf <= raddr_a;
    ra_b_buf <= raddr_b;

    ra_a_i <= TO_INTEGER(unsigned(ra_a_buf));
    ra_b_i <= TO_INTEGER(unsigned(ra_b_buf));

    proc_rd_a: process(clk)
    begin
        if rising_edge(clk) then
            if re_a='1' then
                do_a_mem <= mem_array(ra_a_i);
            end if;
        end if;
    end process proc_rd_a;

    proc_rd_b: process(clk)
    begin
        if rising_edge(clk) then
            if re_b='1' then
                do_b_mem <= mem_array(ra_b_i);
            end if;
        end if;
    end process proc_rd_b;


    -- DO_REG (Additional output register) Porta A/B
    -- -------------------------------------------------------------------------
    gen_DO_REG_0: if DO_REG=0 generate
        do_a_buf <= do_a_mem;
        do_b_buf <= do_b_mem;
    end generate gen_DO_REG_0;

    gen_DO_REG_1: if DO_REG=1 generate
        proc_do_a_buf: process(clk,rst)
        begin
            if rst=RST_POL then
                do_a_buf <= (others=>'0');
            elsif rising_edge(clk) then
                do_a_buf <= do_a_mem;
            end if;
        end process proc_do_a_buf;
        proc_do_b_buf: process(clk,rst)
        begin
            if rst=RST_POL then
                do_b_buf <= (others=>'0');
            elsif rising_edge(clk) then
                do_b_buf <= do_b_mem;
            end if;
        end process proc_do_b_buf;
    end generate gen_DO_REG_1;

    do_a <= do_a_buf;
    do_b <= do_b_buf;

end rtl;
