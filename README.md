# FPGA-LPLIB_MEM
VHDL design repository with technology-free FPGA memory models such as RAM, ROM, FIFO and buffers.
The models are synthesized for different hardware platform to compare the inferred technology.

## Directories
- `doc/` contains notes and documentation about the digital designs and modules.
- `hdl/` contains the VHDL sources for the FPGA design and testbench.
- `list/` contains *.lst files with the sources path to be compiled in.
- `rundir_riviera/` rundir for Aldec Riviera-PRO, HDL simulator.
- `script_bash/` generic bash script utilities.

## Libraries
- `lib.lplib_mem.lst`
- `lib.lplib_mem_verif.lst`