-- =============================================================================
-- Whatis        : Pack serial data into a parallel word.
-- Project       : FPGA-LPLIB_MEM
-- -----------------------------------------------------------------------------
-- File          : data_pack.vhd
-- Language      : VHDL-93
-- Module        : data_pack
-- Library       : lplib_mem
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  * NO RAM USED
--  * Pack M serial word of DATA_WIDTH      TO the output word .
--  * DATA_SWAP
--          MSB                      LSB
--      0 : [data3][data2][data1][data0]
--      1 : [data0][data1][data2][data3]
--
--  * Only the FULL flag should be monitored to write and to read.
--  * READ is priority on WRITE.
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
-- 2021-04-01  Luca Pilato       file creation
-- =============================================================================


-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity data_pack is
    generic (
        RST_POL         : std_logic := '0' ;
        DATA_WIDTH      : positive  := 8   ;
        M               : positive  := 4   ;
        DATA_SWAP       : integer range 0 to 1 := 0
    );
    port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        wr              : in  std_logic;
        wrdata          : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        rd              : in  std_logic;
        rddata          : out std_logic_vector(M*DATA_WIDTH-1 downto 0);
        full            : out std_logic;
        empty           : out std_logic
    );
end data_pack;

architecture rtl of data_pack is

    -- data index counter
    signal icnt         : integer range 0 to M-1;

    signal full_s       : std_logic;
    signal wr_valid     : std_logic;
    
    signal empty_s      : std_logic;
    signal rd_valid     : std_logic;

    type t_data_buf     is array (0 to M-1) of  std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_buf     : t_data_buf;

begin

    -- internal masked write
    -- ----------------------------------------------------------------
    wr_valid    <= wr and (not full_s);
    full        <= full_s;

    -- internal masked read
    -- ----------------------------------------------------------------
    rd_valid    <= rd and not(empty_s);
    empty       <= empty_s;

    -- control + data logic
    -- ----------------------------------------------------------------
    proc_pack: process(rst,clk)
    begin
        if rst=RST_POL then
            icnt        <= 0;
            data_buf    <= (others=>(others=>'0'));
            full_s      <= '0';
            empty_s     <= '1';
        elsif rising_edge(clk) then
            -- the read always clear the buffer
            if rd_valid='1' then
                icnt        <= 0;
                data_buf    <= (others=>(others=>'0'));
                full_s      <= '0';
                empty_s     <= '1';
            elsif wr_valid='1' then
                if DATA_SWAP=0 then
                    data_buf(icnt)      <= wrdata;
                elsif DATA_SWAP=1 then
                    data_buf(M-1-icnt)  <= wrdata;
                end if;
                if icnt=(M-1) then
                    full_s      <= '1';
                else
                    icnt        <= icnt + 1;
                end if;
                empty_s     <= '0';                
            end if;
        end if;
    end process proc_pack;

    gen_rddata: for i in 0 to M-1 generate
        rddata((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH) <= data_buf(i);
    end generate gen_rddata;

end rtl;
