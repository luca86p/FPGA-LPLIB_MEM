-- =============================================================================
-- Whatis        : Synchronous RAM, simple dual-port, single-clock, write-first
-- Project       : FPGA-LPLIB_MEM
-- -----------------------------------------------------------------------------
-- File          : ram_sync_sdp_sc_wf.vhd
-- Language      : VHDL-93
-- Module        : ram_sync_sdp_sc_wf
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
--      Data:       [x] DI/DO   [ ] DI/DO(A,B)  [ ] DI(A,B)/DO(A,B)
--      Address:    [ ] ADDR    [x] WA/RA       [ ] WA(A,B)/RA(A,B)
--      Enable:     [ ] WE      [x] WE/RE       [ ] WE(A,B)/RE(A,B)
--
--  Read mode:      (these apply only if synchronous-read)
--                  [ ] old-data (read-first) 
--                  [x] new-data (write-first)
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
--  The re port is actually unused, internal always-active
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

entity ram_sync_sdp_sc_wf is
    generic (
        RST_POL         : std_logic := '0';
        DATA_WIDTH      : positive  := 8;
        ADDR_WIDTH      : positive  := 6;
        DO_REG          : integer range 0 to 1 := 0
    );
    port (
        rst             : in  std_logic;
        clk             : in  std_logic;
        raddr           : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        waddr           : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        re              : in  std_logic;
        we              : in  std_logic;
        di              : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        do              : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end ram_sync_sdp_sc_wf;

architecture rtl of ram_sync_sdp_sc_wf is

    -- 2D array of memory
    constant MEM_LINES : integer := 2**ADDR_WIDTH;

    -- Address section
    signal wa_i : integer range 0 to MEM_LINES-1;
    signal ra_i : integer range 0 to MEM_LINES-1;
    subtype addr_t is std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal ra_buf : addr_t;

    subtype word_t is std_logic_vector(DATA_WIDTH-1 downto 0);
    type mem_array_t is array (0 to MEM_LINES-1) of word_t;
    signal mem_array    : mem_array_t;

    -- Output section
    signal do_mem       : word_t;
    signal do_buf       : word_t;

begin


    -- WRITE
    -- -------------------------------------------------------------------------
    wa_i <= TO_INTEGER(unsigned(waddr));

    proc_wr: process(clk)
    begin
        if rising_edge(clk) then
            if we='1' then
                mem_array(wa_i) <= di;
            end if;
        end if;
    end process proc_wr;


    -- READ new-data (write-first) 
    -- -------------------------------------------------------------------------
    proc_rd: process(clk)
    begin
        if rising_edge(clk) then
            --if re='1' then -- without re: infers less logic
                ra_buf <= raddr;
            --end if;
        end if;
    end process proc_rd;

    ra_i <= TO_INTEGER(unsigned(ra_buf));

    do_mem <= mem_array(ra_i);    


    -- DO_REG (Additional output register)
    -- -------------------------------------------------------------------------
    gen_DO_REG_0: if DO_REG=0 generate
        do_buf <= do_mem;
    end generate gen_DO_REG_0;

    gen_DO_REG_1: if DO_REG=1 generate
        proc_do_buf: process(clk,rst)
        begin
            if rst=RST_POL then
                do_buf <= (others=>'0');
            elsif rising_edge(clk) then
                do_buf <= do_mem;
            end if;
        end process proc_do_buf;
    end generate gen_DO_REG_1;

    do <= do_buf;

end rtl;
