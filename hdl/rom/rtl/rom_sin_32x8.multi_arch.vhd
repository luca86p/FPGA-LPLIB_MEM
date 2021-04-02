-- =============================================================================
-- Whatis        : ROM
-- Project       : FPGA-LPLIB_MEM
-- -----------------------------------------------------------------------------
-- File          : rom_sin_32x8.multi_arch.vhd
-- Language      : VHDL-93
-- Module        : rom_sin_32x8
-- Library       : lplib_mem
-- -----------------------------------------------------------------------------
-- Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
--                 
-- Company       : 
-- Addr          : 
-- -----------------------------------------------------------------------------
-- Description
--
--  ROM used as LUT (Look Up Table) for sin function
--  NLINES = 32 (x : 5-bit depth)
--  NBIT   =  8 (y : 8-bit depth)
--
--  the raw LUT data are generated with the q_sin_lut.c with:
--  ---------------------------------------------------------
--      $ ./a.exe 32 8
--      
--      -- SIN samples for VHDL LUT
--      -- LUT lines:   32
--      --   number of LUT line address, as unsigned
--      -- bit depth:    8
--      --   y bit-depth, as C2 balanced
--
--          0 =>       0 ,
--          1 =>      25 ,
--          2 =>      49 ,
--          3 =>      71 ,
--          4 =>      90 ,
--          5 =>     106 ,
--          6 =>     117 ,
--          7 =>     125 ,
--          8 =>     127 ,
--          9 =>     125 ,
--          10 =>    117 ,
--          11 =>    106 ,
--          12 =>     90 ,
--          13 =>     71 ,
--          14 =>     49 ,
--          15 =>     25 ,
--          16 =>      0 ,
--          17 =>    -25 ,
--          18 =>    -49 ,
--          19 =>    -71 ,
--          20 =>    -90 ,
--          21 =>   -106 ,
--          22 =>   -117 ,
--          23 =>   -125 ,
--          24 =>   -127 ,
--          25 =>   -125 ,
--          26 =>   -117 ,
--          27 =>   -106 ,
--          28 =>    -90 ,
--          29 =>    -71 ,
--          30 =>    -49 ,
--          31 =>    -25 ,
--  ---------------------------------------------------------
--
--  Multi Architecture for comparison
--      * rtl_case      : use a combinational process and case statements;
--      * rtl_const     : use a constant table defintion;
--      * rtl_compute   : use a VHDL function to generate the lut constant;
--      * rtl_impure    : use external txt file to initalize the lut constant;
--      * rtl_txtproc   : use external txt file to load a lut signal;
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
-- 2021-04-02  Luca Pilato       file creation
-- =============================================================================


-- STD lib
-- ----------------------------------------
use std.textio.all; -- for rtl_impure

-- IEEE lib
-- ----------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity rom_sin_32x8 is
    port (
        addr        : in  std_logic_vector(4 downto 0);
        data        : out std_logic_vector(7 downto 0)
    );
end entity rom_sin_32x8;


architecture rtl_case of rom_sin_32x8 is

    subtype t_int_data is integer range -128 to 127;
    signal    int_data : t_int_data;

begin

    proc_rom: process(addr)
        variable int_addr : integer range 0 to 31;
    begin
        int_addr    := TO_INTEGER(unsigned(addr));
        case int_addr is
            when     0 =>   int_data <=        0 ;
            when     1 =>   int_data <=       25 ;
            when     2 =>   int_data <=       49 ;
            when     3 =>   int_data <=       71 ;
            when     4 =>   int_data <=       90 ;
            when     5 =>   int_data <=      106 ;
            when     6 =>   int_data <=      117 ;
            when     7 =>   int_data <=      125 ;
            when     8 =>   int_data <=      127 ;
            when     9 =>   int_data <=      125 ;
            when    10 =>   int_data <=      117 ;
            when    11 =>   int_data <=      106 ;
            when    12 =>   int_data <=       90 ;
            when    13 =>   int_data <=       71 ;
            when    14 =>   int_data <=       49 ;
            when    15 =>   int_data <=       25 ;
            when    16 =>   int_data <=        0 ;
            when    17 =>   int_data <=      -25 ;
            when    18 =>   int_data <=      -49 ;
            when    19 =>   int_data <=      -71 ;
            when    20 =>   int_data <=      -90 ;
            when    21 =>   int_data <=     -106 ;
            when    22 =>   int_data <=     -117 ;
            when    23 =>   int_data <=     -125 ;
            when    24 =>   int_data <=     -127 ;
            when    25 =>   int_data <=     -125 ;
            when    26 =>   int_data <=     -117 ;
            when    27 =>   int_data <=     -106 ;
            when    28 =>   int_data <=      -90 ;
            when    29 =>   int_data <=      -71 ;
            when    30 =>   int_data <=      -49 ;
            when    31 =>   int_data <=      -25 ;
            -- when others => null;
        end case;
    end process proc_rom;
    
    data    <= std_logic_vector(TO_SIGNED(int_data,8));

end rtl_case;


architecture rtl_const of rom_sin_32x8 is

    subtype t_int_data is integer range -128 to 127;
    signal    int_data : t_int_data;
    type    t_lut is array (natural range 0 to 31) of t_int_data;
    constant  LUT : t_lut := (
        0 =>       0 ,
        1 =>      25 ,
        2 =>      49 ,
        3 =>      71 ,
        4 =>      90 ,
        5 =>     106 ,
        6 =>     117 ,
        7 =>     125 ,
        8 =>     127 ,
        9 =>     125 ,
        10 =>    117 ,
        11 =>    106 ,
        12 =>     90 ,
        13 =>     71 ,
        14 =>     49 ,
        15 =>     25 ,
        16 =>      0 ,
        17 =>    -25 ,
        18 =>    -49 ,
        19 =>    -71 ,
        20 =>    -90 ,
        21 =>   -106 ,
        22 =>   -117 ,
        23 =>   -125 ,
        24 =>   -127 ,
        25 =>   -125 ,
        26 =>   -117 ,
        27 =>   -106 ,
        28 =>    -90 ,
        29 =>    -71 ,
        30 =>    -49 ,
        31 =>    -25
    );

begin

    int_data    <= LUT(TO_INTEGER(unsigned(addr)));
    data        <= std_logic_vector(TO_SIGNED(int_data,8));

end rtl_const;


architecture rtl_compute of rom_sin_32x8 is

    subtype t_int_data is integer range -128 to 127;
    signal    int_data : t_int_data;
    type    t_lut is array (natural range 0 to 31) of t_int_data;

    function compute_lut (b_x : positive; b_y : positive) return t_lut is
        variable LSB_xq     : real;
        variable x          : real;
        variable LSB_yq     : real;
        variable y          : real;
        variable yq         : integer;
        variable lutyq      : t_LUT;
    begin
        LSB_xq  := MATH_2_PI / 2.0**(b_x);
        LSB_yq  := 1.0 / (2.0**(b_y-1) - 1.0); -- balanced
        for xq in 0 to 2**b_x-1 loop
            x   := real(xq)*LSB_xq;
            y   := SIN(x);
            yq  := integer(ROUND(y/LSB_yq));
            lutyq(xq) := yq;
        end loop;
        return lutyq;
    end function compute_lut;
       
    constant LUT : t_LUT := compute_lut(5,8);

begin

    int_data    <= LUT(TO_INTEGER(unsigned(addr)));
    data        <= std_logic_vector(TO_SIGNED(int_data,8));

end rtl_compute;


architecture rtl_impure of rom_sin_32x8 is

    subtype t_int_data is integer range -128 to 127;
    signal    int_data : t_int_data;
    type    t_lut is array (natural range 0 to 31) of t_int_data;

    -- this path depends on where the vhdl is compiled
    constant ROM_TXT_PATH   : string := "../hdl/rom/rtl/rom_sin_32x8.txt";

    impure function rom_init(filename : string) return t_lut is
        file     ROM_TXT_F  : TEXT open read_mode is filename;
        variable rom_line   : line;
        variable data_read  : t_int_data;
        variable luttmp     : t_lut;
    begin
        for i in 0 to 31 loop
            readline(ROM_TXT_F, rom_line);
            read(rom_line, data_read);
            luttmp(i) := data_read;
        end loop;
        return luttmp;
    end function rom_init;
       
    constant LUT : t_lut := rom_init(filename => ROM_TXT_PATH);

begin

    int_data    <= LUT(TO_INTEGER(unsigned(addr)));
    data        <= std_logic_vector(TO_SIGNED(int_data,8));

end rtl_impure;


architecture rtl_txtproc of rom_sin_32x8 is

    subtype t_int_data is integer range -128 to 127;
    signal    int_data : t_int_data;
    type    t_lut is array (natural range 0 to 31) of t_int_data;
    signal    lut      : t_lut;

    -- this path depends on where the vhdl is compiled
    constant ROM_TXT_PATH   : string := "../hdl/rom/rtl/rom_sin_32x8.txt";
    file     ROM_TXT_F  : TEXT open read_mode is ROM_TXT_PATH;

begin

    proc_load_rom: process
        variable rom_line   : line;
        variable data_read  : t_int_data;
    begin
        for i in 0 to 31 loop
            readline(ROM_TXT_F, rom_line);
            read(rom_line, data_read);
            lut(i) <= data_read;
        end loop;
        file_close(ROM_TXT_F);
        wait;
    end process proc_load_rom;

    int_data    <= lut(TO_INTEGER(unsigned(addr)));
    data        <= std_logic_vector(TO_SIGNED(int_data,8));

end rtl_txtproc;