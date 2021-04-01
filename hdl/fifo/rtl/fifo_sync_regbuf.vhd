-- =============================================================================
-- Whatis        : Synchronous FIFO-like, single register buffer
-- Project       : FPGA-LPLIB_MEM
-- -----------------------------------------------------------------------------
-- File          : fifo_sync_regbuf.vhd
-- Language      : VHDL-93
-- Module        : fifo_sync_regbuf
-- Library       : lplib_mem
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  - Replacement of fifo_sync_rf_ready.vhd 
--  - NO RAM USED
--  - If simultaneous rd/wr depends on full/empty state (rd/wr are mutual)
--
--  FIFO type:
--      * synchronous   : same clock for write and read operation.
--      * memory        : single register buffer.
--      * write cycle   : wrdata shall be valid the same clock of the wr pulse, if not full.
--      * read cycle    : rddata is valid WHEN NOT EMPTY, (rd pulse as ack).
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
-- 2019-09-17  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity fifo_sync_regbuf is
    generic (
        RST_POL         : std_logic := '0' ;
        DATA_WIDTH      : positive  := 8
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        clear           : in  std_logic;
        wr              : in  std_logic;
        wrdata          : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        rd              : in  std_logic;
        rddata          : out std_logic_vector(DATA_WIDTH-1 downto 0);
        full            : out std_logic;
        empty           : out std_logic
    );
end fifo_sync_regbuf;

architecture rtl of fifo_sync_regbuf is

    signal full_s       : std_logic;
    signal wr_valid     : std_logic;

    signal empty_s      : std_logic;
    signal rd_valid     : std_logic;

    signal regbuf       : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    -- internal masked write
    -- ----------------------------------------------------------------
    wr_valid <= wr and (not full_s);
    full     <= full_s;

    -- -- internal masked read
    -- -- ----------------------------------------------------------------
    rd_valid    <= rd and not(empty_s);
    empty_s     <= not full_s;
    empty       <= empty_s;


    proc_regbuf: process(rst, clk)
    begin
        if rst=RST_POL then
            regbuf  <= (others=>'0');
            full_s  <= '0';
        elsif rising_edge(clk) then
            if clear='1' then
                regbuf  <= (others=>'0');
                full_s  <= '0';
            else
                if wr_valid='1' then
                    regbuf   <= wrdata;
                    full_s  <= '1';
                elsif rd_valid='1' then -- here rd and wr are mutual
                    full_s  <= '0';
                end if;
            end if;
        end if;
    end process proc_regbuf;

    rddata  <= regbuf;

end rtl;
