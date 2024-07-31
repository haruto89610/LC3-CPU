# LC3-CPU
A CPU using the LC-3 ISA is programmed using System Verilog.

The instruction for the CPU can be written directly into the RAM module inside the module.sv file.
The current memory features a calculator of two values:
  - AND R0 R0 #0
  - AND R1 R1 #0
  - AND R2 R2 #0
  - LD  R0 NUM1
  - LD  R1 NUM2
  - ADD R2 R1 R0
  - NUM1 x000A
  - NUM2 x0005

![image](https://github.com/user-attachments/assets/7e3503f3-4ade-479e-a54e-9c34c37719b5)


The module.sv file features the basic building blocks for the CPU, including the Muxes, Tristate buffers, ALU, Register file, RAM, and Registers.
The logic.sv file includes the logic required for the BR COMP and NZP logic required for the BR instruction.
