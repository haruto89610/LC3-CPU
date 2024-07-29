# LC3-CPU
A CPU using the LC-3 ISA is programmed using System Verilog.

The instruction for the CPU can be written directly into the RAM module inside the module.sv file.

The module.sv file features the basic building blocks for the CPU, including the Muxes, Tristate buffers, ALU, Register file, RAM, and Registers.
The logic.sv file includes the logic required for the BR COMP and NZP logic required for the BR instruction.

So far, the ADD, AND, NOT, LEA, LD, LDR, LDI, STI, and BR instructions have been tested.
