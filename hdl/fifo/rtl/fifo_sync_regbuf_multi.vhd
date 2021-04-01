-- =============================================================================
-- Whatis        : Synchronous FIFO-like, multi-stage register buffer, shift mechanism
-- Project       : FPGA-LPLIB_MEM
-- -----------------------------------------------------------------------------
-- File          : fifo_sync_regbuf_multi.vhd
-- Language      : VHDL-93
-- Module        : fifo_sync_regbuf_multi
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
--  - build cascading fifo_sync_regbuf
--  - 2-clock write cycle and 2-clock read cycle (slow interfaces)
--  - NSTAGE -> NSTAGE latency before ready
--
--  NO TIMING PERFORMANCE, but VERY SIMPLE LOGIC
--
--  FIFO type:
--      * synchronous   : same clock for write and read operation.
--      * memory        : multi-stage register buffer.
--      * write cycle   : wrdata shall be valid the same clock of the wr pulse, if not full.
--      * read cycle    : rddata is valid WHEN NOT EMPTY, (rd pulse as ack).
--
-- -----------------------------------------------------------------------------
-- Dependencies
-- 
--  lplib_mem.fifo_sync_regbuf(rtl)
-- 
-- -----------------------------------------------------------------------------
-- Issues
-- 
-- -----------------------------------------------------------------------------
-- Copyright (c) 2021 Luca Pilato
-- MIT License
-- -----------------------------------------------------------------------------
-- date        who               changes
-- 2021-04-01  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- User lib
-- ----------------------------------------
library lplib_mem;


entity fifo_sync_regbuf_multi is
    generic (
        RST_POL         : std_logic := '0'  ;
        DATA_WIDTH      : positive  := 8    ;
        NSTAGE          : positive range 2 to 8 := 4
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
end fifo_sync_regbuf_multi;


architecture rtl of fifo_sync_regbuf_multi is

    signal v_wr         : std_logic_vector(1 to NSTAGE);
    type t_v_wrdata is array (1 to NSTAGE) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal v_wrdata     : t_v_wrdata;
    signal v_rd         : std_logic_vector(1 to NSTAGE);
    type t_v_rddata is array (1 to NSTAGE) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal v_rddata     : t_v_rddata;
    signal v_full       : std_logic_vector(1 to NSTAGE);
    signal v_empty      : std_logic_vector(1 to NSTAGE);

begin


    gen_regbuf: for i in 1 to NSTAGE generate

        -- all instances of regbuf
        i_fifo_sync_regbuf: entity lplib_mem.fifo_sync_regbuf(rtl)
        generic map (
            RST_POL         => '0'              ,
            DATA_WIDTH      => DATA_WIDTH       
        )
        port map (
            clk             => clk              ,
            rst             => rst              ,
            clear           => clear            ,
            wr              => v_wr(i)          ,
            wrdata          => v_wrdata(i)      ,
            rd              => v_rd(i)          ,
            rddata          => v_rddata(i)      ,
            full            => v_full(i)        ,
            empty           => v_empty(i)           
        );
        
        -- exception
        gen_first: if i=1 generate
            v_wr(i)     <= wr;
            v_wrdata(i) <= wrdata;
        end generate gen_first;
        gen_middle: if i>1 and i<NSTAGE generate
            v_rd(i-1)   <= (not v_full(i)) and (not v_empty(i-1));
            v_wr(i)     <= (not v_full(i)) and (not v_empty(i-1));
            v_wrdata(i) <= v_rddata(i-1);
        end generate gen_middle;
        gen_last: if i=NSTAGE generate
            v_rd(i-1)   <= (not v_full(i)) and (not v_empty(i-1));
            v_wr(i)     <= (not v_full(i)) and (not v_empty(i-1));
            v_wrdata(i) <= v_rddata(i-1);
            v_rd(i)     <= rd;
            rddata      <= v_rddata(i);
            full        <= v_full(i);
            empty       <= v_empty(i);
        end generate gen_last;

    end generate gen_regbuf;

end rtl;
