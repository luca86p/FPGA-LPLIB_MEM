# FPGA RAM resources note
A short summary for FPGA RAM design and/or utilization.

<br>

## Synch vs Asynch Definition

### Synchronous Write Operation
The synchronous write operation is a single clock-edge operation with a write-enable (WE) feature. When WE is active, the data input is loaded into the memory location at the proper address.

### Synchronous vs. Asynchronous Read Operation
- Synch read takes into account a clock signal from the read address input to the read data output.
- Asynch read doesn't use clocks or enables from the read address input to the read data output. Each time a new address is applied to the address pins, the data value in the memory location of that address is available on the output after the time delay to access the memory (LUT). This operation is asynchronous and independent of the clock signal.

### Xilinx RAM types
- Distributed RAM
    - Synchronous write
    - Asynchronous read
- Block Ram
    - Synchronous write
    - Synchronous read

### Microsemi (Actel) RAM types
- Block RAM: RAM4K9, RAM512X18
    - Synchronous write
    - Synchronous read

<br>

## Ports Classification

### Single-port
- In a single-port RAM, the read and write operations share the same address (common address port). It is used for processor(s) scratch RAM, look-up tables, ...

### Simple dual-port
- In a simple dual-port RAM, a dedicated address port is available for each read and write operation (one read port and one write port). It is used for content addressable memories, FIFOs. It can use the same clock for the read and write port or a diferent read clock and write clock.

### True dual-port
- In a true dual-port RAM, there are two fully independent ports (Port A and Port B). Each port has its own address, data in/out, clock, and enables. Both read/write are usually synchronous. Simultaneously writing to the same address causes data uncertainty. It is used for multi processor storage.

### Multi-port
- A multi-port RAM in a simple or true port architecture.

<br>

## Clocking modes

### Single clock mode
- In the single clock mode, a single clock, together with a clock enable if any, controls all registers and latches of the memory block.

### Read/Write clock mode
- In the read/write clock mode, a separate clock is available for each read and write port. A read clock controls the data output, read address, and read enable registers, if any. A write clock controls the data input, write address, write enable, and byte enable registers, if any.

### Input/Output clock mode
- In input/output clock mode, a separate clock is available for each input and output port. An input clock controls all registers related to the data input to the memory block including data, address, byte enables, read enables, and write enables. An output clock controls the data output registers.

### Independent clock mode
- In the independent clock mode, a separate clock is available for each port (A and B). Clock A controls all registers on the port A side; clock B controls all registers on the port B side.

### Clocking mode applicability
| Clocking modes | Single-port | Simple dual-port | True dual-port |
|---|:---:|:---:|:---:|
| Single clock          | x | x | x |
| Read/Write clock      | - | x | - |
| Input/Output clock    | x | x | x |
| Independent clock     | - | - | x |

<br>
<br>

## Ports list examples
In general there are different types of RAM, depending on the port number, signals and behavior (operational modes).
- Clock ports:
    - `CLK` : Clock input (if read and write on the same clock domain).
    - `WCLK` : Write clock input (if asynchronous with read clock).
    - `RCLK` : Read clock input (if asynchronous with write clock).
    - `INCLK` : Input clock input (if asynchronous with output clock).
    - `OUTCLK` : Output clock input (if asynchronous with input clock).
    - `CLK(A|B)` : Independent Clock input for Port A or Port B.
- Data ports:
    - `DI` : Data input bus.
    - `DI(A|B)` : Data input bus Port A or Port B.
    - `DIP(A|B)` : Data input parity bus.
    - `DICB(A|B)` : Data input checkbit(s) bus.
    - `DO` : Data output bus.
    - `DO(A|B)` : Data output bus Port A or Port B.
    - `DOP(A|B)` : Data output parity bus.
    - `DOCB(A|B)` : Data output checkbit(s) bus.
- Address ports:
    - `ADDR` : Address bus (same for read and write operation).
    - `WADDR` or `WA` : Write address bus.
    - `RADDR` or `RA` : Read address bus.
- Reset ports:
    - `RST` : Asynchronous reset to the RAM (or to the output data latches).
    - `ACLR` : Asynchronous clear, same as `RST`.
    - `SCLR` : Synchronous clear to the RAM (or to the output registers).
- Enable ports:
    - `EN` : When inactive no data is written to the RAM and the output bus remains in its previous state.
    - `WE` : Write enable.
    - `WBE` : Write byte enable.
    - `RE` : Read enable.
    - `RBE` : Read byte enable.
    - `RACE` : Read Address register/latch clock enable.
    - `DOCE` : Output register/latch clock enable.

<br>

## Operational modes

### Read mode
- `asynch_read` : Asynchronous read. No read clock, no read enables, no output registers or latches.
- `write_first` (or `transparent_write`, or `new_data`): In this mode the input data is simultaneously written into memory and stored in the data output. When a collision (read and write at the same address) occurs it behave as the data is first written into memory and then the same data is read. Some RAM architecture are build with a read address buffer to implement this mode.
- `read_first` (or `read_before_write`, or `old_data`): In this mode the data previously stored at the write address appears on the output latches, while the input data is being stored in memory. When a collision (read and write at the same address) occurs it behave as the read operations precede write. Old data is read first and then new data is written into memory.
- `no_change` (or `read_if_nowrite`): In this mode the output latches remain unchanged during a write operation. Data output remains the last read data and is unaffected by a write operation on the same port. The output of the RAM does not change when a collision occurs.

### Output register
- `DO_REG` : A pipeline register can be inserted at the output data bus. The data latency in a read operation increase by one clock cycle. Sometimes a RAM block has its own PIPELINE register/latch availability. 

<br>

## RAM summary sheet

```VHDL
--  RAM type:       [ ] synchronous-read    [ ] asynchronous-read
--
--  Interface type:
--      Clock:      [ ] CLK     [ ] WCLK/RCLK   [ ] INCLK/OUTCLK    [ ] CLK(A,B)
--      Data:       [ ] DI/DO   [ ] DI/DO(A,B)  [ ] DI(A,B)/DO(A,B)
--      Address:    [ ] ADDR    [ ] WA/RA       [ ] WA(A,B)/RA(A,B)
--      Enable:     [ ] WE      [ ] WE/RE       [ ] WE(A,B)/RE(A,B)
--
--  Read mode:      (apply only if synchronous-read)
--                  [ ] old-data (read-first) 
--                  [ ] new-data (write-first)
--                  [ ] no-change
--
--  Generic:
--                  - DO_REG (Additional output register)
```

<br>

## RAM filename convention
To identify the different RAM architecture/description, the VHDL file(s) use some acronyms. Hereafter some examples:
- `ram_sync_sp_rf.vhd` Synchronous RAM, single-port, read-first
- `ram_sync_sdp_sc_wf.vhd` Synchronous RAM, simple dual-port, single-clock, write-first.

<br>

---

## References
1. [Xilinx UG473 7Series Memory Resources](https://www.xilinx.com/support/documentation/user_guides/ug473_7Series_Memory_Resources.pdf)
2. [Synopsys Inferring Microsemi SmartFusion2 RAM Blocks](https://www.microsemi.com/document-portal/doc_view/129966-inferring-microsemi-smartfusion2-ram-blocks-app-note)
3. [Intel Embedded Memory](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/ug/ug_ram_rom.pdf)
4. [Altera Internal Memory (RAM and ROM)](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/ug/ug_ram.pdf)
5. [Lattice Memory Usage Guide for iCE40 Devices](http://www.latticesemi.com/-/media/LatticeSemi/Documents/ApplicationNotes/MP2/FPGA-TN-02002-1-7-Memory-Usage-Guide-for-iCE40-Devices.ashx?document_id=47775)
6. [Imperial College London FPGA Embedded Memory](http://www.ee.ic.ac.uk/pcheung/teaching/ee2_digital/Lecture%2014%20-%20FPGA%20Embedded%20Memory.pdf)
7. [Actel Using Fusion, IGLOO, and ProASIC3 RAM as Multipliers](http://application-notes.digchip.com/056/56-39939.pdf)
8. [Xilinx 7 Series FPGAs Configurable Logic Block](https://www.xilinx.com/support/documentation/user_guides/ug474_7Series_CLB.pdf)
