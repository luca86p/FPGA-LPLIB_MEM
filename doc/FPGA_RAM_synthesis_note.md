# FPGA RAM synthesis note

<br>

## VHDL(s) classification as function of the interface:

| vhdl | Clock | Data | Address | Enable | Note |
|---|---|---|---|---|---|
| *Single-Port* |_____|_____|_____|_____|_____|
| ram_sync_sp_rf.vhd | CLK | DI / DO | ADDR | WE / RE | old-data (read-first)   |
| ram_sync_sp_wf.vhd | CLK | DI / DO | ADDR | WE / RE | new-data (write-first)  |
| ram_sync_sp_nc.vhd | CLK | DI / DO | ADDR | WE / RE | no-change               |
| *Simple-Dual-Port* |_____|_____|_____|_____|_____|
| ram_sync_sdp_sc_rf.vhd | CLK | DI / DO | WA / RA | WE / RE | old-data (read-first)  |
| ram_sync_sdp_sc_wf.vhd | CLK | DI / DO | WA / RA | WE / RE | new-data (write-first) |
| ram_sync_sdp_sc_nc.vhd | CLK | DI / DO | WA / RA | WE / RE | no-change  |
| ram_sync_sdp_rwc_rf.vhd | WCLK / RCLK | DI / DO | WA / RA | WE / RE | old-data (read-first)  |
| ram_sync_sdp_rwc_wf.vhd | WCLK / RCLK | DI / DO | WA / RA | WE / RE | new-data (write-first) |
| *True-Dual-Port* |_____|_____|_____|_____|_____|
| ram_sync_tdp_sc_rf.vhd | CLK | DI(A,B) / DO(A,B) | WA(A,B) / RA(A,B) | WE(A,B) / RE(A,B) | old-data (read-first) |
| ram_sync_tdp_sc_wf.vhd | CLK | DI(A,B) / DO(A,B) | WA(A,B) / RA(A,B) | WE(A,B) / RE(A,B) | new-data (write-first) |
| ram_sync_tdp_abc_rf.vhd | CLK(A,B) | DI(A,B) / DO(A,B) | WA(A,B) / RA(A,B) | WE(A,B) / RE(A,B) | old-data (read-first) |

<br>

## *Single-Port* Implementation Results

The synthesis **software** used are:

1. Libero SoC v11.9 SP5; Synplify Pro
2. Xilinx Vivado v2019.1

<br>

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sp_rf.vhd | 8 | 6 | 0 | 1. | A3PE600 |
```
Report for cell ram_sync_sp_rf.rtl
                                          Cell usage:
                               cell       count     area    count*area
                             CLKBUF         1       0.0        0.0
                                GND         1       0.0        0.0
                              INBUF        16       0.0        0.0
                                INV         2       1.0        2.0
                             OUTBUF         8       0.0        0.0
                          RAM512X18         1       0.0        0.0
                                VCC         1       0.0        0.0
                            
                         TOTAL             30                  2.0
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sp_rf.vhd | 8 | 6 | 1 | 1. | A3PE600 |
```
Report for cell ram_sync_sp_rf.rtl
                                          Cell usage:
                               cell       count     area    count*area
                             CLKBUF         1       0.0        0.0
                             DFN1C0         8       1.0        8.0
                                GND         1       0.0        0.0
                              INBUF        17       0.0        0.0
                                INV         2       1.0        2.0
                             OUTBUF         8       0.0        0.0
                          RAM512X18         1       0.0        0.0
                                VCC         1       0.0        0.0
                            
                         TOTAL             39                 10.0
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sp_wf.vhd | 8 | 6 | 0 | 1. | A3PE600 |
```
Report for cell ram_sync_sp_wf.rtl
                                          Cell usage:
                               cell       count     area    count*area
                             CLKBUF         1       0.0        0.0
                                GND         1       0.0        0.0
                              INBUF        15       0.0        0.0
                                INV         1       1.0        1.0
                             OUTBUF         8       0.0        0.0
                          RAM512X18         1       0.0        0.0
                                VCC         1       0.0        0.0
                            
                         TOTAL             28                  1.0
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sp_wf.vhd | 8 | 6 | 1 | 1. | A3PE600 |
```
Report for cell ram_sync_sp_wf.rtl
                                          Cell usage:
                               cell       count     area    count*area
                             CLKBUF         1       0.0        0.0
                             DFN1C0         8       1.0        8.0
                                GND         1       0.0        0.0
                              INBUF        16       0.0        0.0
                                INV         1       1.0        1.0
                             OUTBUF         8       0.0        0.0
                          RAM512X18         1       0.0        0.0
                                VCC         1       0.0        0.0
                            
                         TOTAL             37                  9.0
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sp_nc.vhd | 8 | 6 | 0 | 1. | A3PE600 |
```
Report for cell ram_sync_sp_nc.rtl
                                          Cell usage:
                               cell       count     area    count*area
                             CLKBUF         1       0.0        0.0
                                GND         1       0.0        0.0
                              INBUF        16       0.0        0.0
                                INV         1       1.0        1.0
                               OR2A         1       1.0        1.0
                             OUTBUF         8       0.0        0.0
                          RAM512X18         1       0.0        0.0
                                VCC         1       0.0        0.0
                            
                         TOTAL             30                  2.0
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sp_nc.vhd | 8 | 6 | 1 | 1. | A3PE600 |
```
Report for cell ram_sync_sp_nc.rtl
                                          Cell usage:
                               cell       count     area    count*area
                             CLKBUF         1       0.0        0.0
                             DFN1C0         8       1.0        8.0
                                GND         1       0.0        0.0
                              INBUF        17       0.0        0.0
                                INV         1       1.0        1.0
                               OR2A         1       1.0        1.0
                             OUTBUF         8       0.0        0.0
                          RAM512X18         1       0.0        0.0
                                VCC         1       0.0        0.0
                            
                         TOTAL             39                 10.0
```

<br>

## *Simple-Dual-Port* Implementation Results

The synthesis **software** used are:

1. Libero SoC v11.9 SP5; Synplify Pro
2. Xilinx Vivado v2019.1

<br>

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sdp_sc_rf.vhd | 8 | 6 | 0 | 1. | A3PE600 |
```
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sdp_sc_rf.vhd | 8 | 6 | 1 | 1. | A3PE600 |
```
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sdp_sc_wf.vhd | 8 | 6 | 0 | 1. | A3PE600 |
```
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sdp_sc_wf.vhd | 8 | 6 | 1 | 1. | A3PE600 |
```
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sdp_sc_nc.vhd | 8 | 6 | 0 | 1. | A3PE600 |
```
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sdp_sc_nc.vhd | 8 | 6 | 1 | 1. | A3PE600 |
```
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sdp_rwc_rf.vhd | 8 | 6 | 0 | 1. | A3PE600 |
```
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sdp_rwc_rf.vhd | 8 | 6 | 1 | 1. | A3PE600 |
```
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sdp_rwc_wf.vhd | 8 | 6 | 0 | 1. | A3PE600 |
```
```

| vhdl | DATA_WIDTH | ADDR_WIDTH | DO_REG | Software | Device |
|---|---|---|---|---|---|
| ram_sync_sdp_rwc_wf.vhd | 8 | 6 | 1 | 1. | A3PE600 |
```
```

<br>

### Note
The Actel (Microsemi) RAM512x18 is a two port RAM and supports the following features:
- Variable aspect ratios of 512x9 or 256x18
- Dedicated Read and Write Ports
- Active Low Read and Write Enable
- Synchronous Write and Pipelined or Non-Pipelined Synchronous Read
- Active Low Asynchronous Output Reset
