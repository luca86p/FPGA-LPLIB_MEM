-- =============================================================================
-- Whatis        : Synchronous FIFO, read-first mem
-- Project       : FPGA-LPLIB_MEM
-- -----------------------------------------------------------------------------
-- File          : fifo_sync_rf.vhd
-- Language      : VHDL-93
-- Module        : fifo_sync_rf
-- Library       : lplib_mem
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  FIFO type:
--      * synchronous   : same clock for write and read operation.
--      * memory        : Synchronous RAM, simple dual-port, single-clock, read-first
--      * write cycle   : wrdata shall be valid the same clock of the wr pulse, if not full.
--      * read cycle    : rddata is valid the clock after the rd pulse, if not empty.
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

-- User lib
-- ----------------------------------------
library lplib_mem;


entity fifo_sync_rf is
    generic (
        RST_POL         : std_logic := '0' ;
        DATA_WIDTH      : positive  := 8;
        ADDR_WIDTH      : positive  := 6
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        clear           : in  std_logic;
        wr              : in  std_logic;
        wrdata          : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        rd              : in  std_logic;
        rddata          : out std_logic_vector(DATA_WIDTH-1 downto 0);
        --
        full            : out std_logic;
        empty           : out std_logic;
        --
        afull_thr       : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        afull           : out std_logic;
        aempty_thr      : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        aempty          : out std_logic;
        data_cnt        : out std_logic_vector(ADDR_WIDTH-1 downto 0)
    );
end fifo_sync_rf;


architecture rtl of fifo_sync_rf is

    constant FIFO_DEPTH : positive := 2**ADDR_WIDTH;
    signal wr_ptr_u     : unsigned(ADDR_WIDTH-1 downto 0);
    signal rd_ptr_u     : unsigned(ADDR_WIDTH-1 downto 0);
    signal data_cnt_u   : unsigned(ADDR_WIDTH-1 downto 0);

    signal full_s       : std_logic;
    signal wr_valid     : std_logic;

    signal empty_s      : std_logic;
    signal rd_valid     : std_logic;

    signal wr_addr      : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal rd_addr      : std_logic_vector(ADDR_WIDTH-1 downto 0);

begin

    -- internal masked write
    -- ----------------------------------------------------------------
    wr_valid <= wr and (not full_s);
    full     <= full_s;

    -- internal masked read
    -- ----------------------------------------------------------------
    rd_valid <= rd and (not empty_s);
    empty    <= empty_s;

    -- control logic: write/read pointer
    -- ----------------------------------------------------------------
    proc_ptr: process(rst,clk)
    begin
        if rst=RST_POL then
            wr_ptr_u   <= (others=>'0');
            rd_ptr_u   <= (others=>'0');
        elsif rising_edge(clk) then
            if clear='1' then
                wr_ptr_u   <= (others=>'0');
                rd_ptr_u   <= (others=>'0');
            else
                if wr_valid='1' then
                    wr_ptr_u   <= wr_ptr_u + 1;
                end if;
                if rd_valid='1' then
                    rd_ptr_u   <= rd_ptr_u + 1;
                end if;
            end if;
        end if;
    end process proc_ptr;

    -- control logic: data counter
    -- ----------------------------------------------------------------
    proc_cnt: process(rst,clk)
    begin
        if rst=RST_POL then
            data_cnt_u <= (others=>'0');
        elsif rising_edge(clk) then
            if clear='1' then
                data_cnt_u <= (others=>'0');
            else
                if (wr_valid='1' and rd_valid='0') then
                    data_cnt_u <= data_cnt_u + 1;
                elsif (wr_valid='0' and rd_valid='1') then
                    data_cnt_u <= data_cnt_u - 1;
                end if;
            end if;
        end if;
    end process proc_cnt;

    data_cnt <= std_logic_vector(data_cnt_u);

    -- control logic: flags
    -- ----------------------------------------------------------------
    proc_flags: process(rst,clk)
    begin
        if rst=RST_POL then
            full_s  <= '0';
            empty_s <= '1';
            --
            afull   <= '0';
            aempty  <= '1';
        elsif rising_edge(clk) then
            if clear='1' then
                full_s  <= '0';
                empty_s <= '1';
                --
                afull   <= '0';
                aempty  <= '1';
            else
                if wr_valid='1' and empty_s='1' then
                    empty_s <= '0';
                elsif wr_valid='0' and rd_valid='1' and data_cnt_u=1 then
                    empty_s <= '1';
                end if;
                if wr_valid='1' and rd_valid='0' and data_cnt_u=FIFO_DEPTH-1 then
                    full_s  <= '1';
                elsif rd_valid='1' and full_s='1' then
                    full_s  <= '0';
                end if;
                -- 
                if wr_valid='1' and rd_valid='0' and data_cnt_u=unsigned(afull_thr) then
                    afull   <= '1';
                elsif wr_valid='0' and rd_valid='1' and data_cnt_u=unsigned(afull_thr) then
                    afull   <= '0';
                end if;
                --
                if wr_valid='1' and rd_valid='0' and data_cnt_u=unsigned(aempty_thr) then
                    aempty  <= '0';
                elsif wr_valid='0' and rd_valid='1' and data_cnt_u=unsigned(aempty_thr) then
                    aempty  <= '1';
                end if;
                --
            end if;
        end if;
    end process proc_flags;

    -- memory
    -- ----------------------------------------------------------------
    wr_addr <= std_logic_vector(wr_ptr_u);
    rd_addr <= std_logic_vector(rd_ptr_u);

    i_mem: entity lplib_mem.ram_sync_sdp_sc_rf(rtl)
    generic map (
        RST_POL         => RST_POL          ,
        DATA_WIDTH      => DATA_WIDTH       ,
        ADDR_WIDTH      => ADDR_WIDTH       ,
        DO_REG          => 0
    )
    port map (
        rst             => rst              ,
        clk             => clk              ,
        raddr           => rd_addr          ,
        waddr           => wr_addr          ,
        re              => rd_valid         ,
        we              => wr_valid         ,
        di              => wrdata           ,
        do              => rddata
    );

end rtl;