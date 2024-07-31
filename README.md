# LC3-CPU
## Overview
The LC3-CPU simulates the basic functionalities of a CPU, including instruction execution and memory management. Instructions for the CPU can be directly written into the RAM module.sv file.

## Features
- Basic Arithmetic Operations:
    - The CPU supports basic arithmetic operations, such as addition, and more advanced operations.
- Modular Design:
    - The design includes key components like multiplexers (Muxes), tristate buffers, ALU, register files, RAM, and registers, making it easy to expand and modify.

The instruction for the CPU can be written directly into the RAM module inside the module.sv file.
The current memory features a calculator of two values:
'''
AND R0 R0 #0   ; Clear R0
AND R1 R1 #0   ; Clear R1
AND R2 R2 #0   ; Clear R2
LD  R0 NUM1    ; Load value from NUM1 into R0
LD  R1 NUM2    ; Load value from NUM2 into R1
ADD R2 R1 R0   ; Add R1 and R0, store result in R2

NUM1 .FILL x000A ; First number (10)
NUM2 .FILL x0005 ; Second number (5)
'''
![image](https://github.com/user-attachments/assets/7e3503f3-4ade-479e-a54e-9c34c37719b5)

In the image above, we observe that the LD command takes a longer time compared to the other commands. This is because LD involves a two-step process: first, adding the PC value, and then fetching the data from memory at the specified address to load into the register.

## File Descriptions
module.sv: Contains the core components of the CPU, such as the Muxes, tristate buffers, ALU, register file, RAM, and registers.
logic.sv: Includes the logic necessary for implementing branch (BR) instructions, including the BR COMP and NZP logic.
FSM.sv: Features the finite state machine responsible for controlling all the control inputs.
main.sv: Combines all components.

## Getting Started
1. Clone the Repository:
'''
bash
Copy code
git clone https://github.com/yourusername/LC3-CPU.git
'''
2. Compile and Run: Use your preferred System Verilog simulation tool to compile and simulate the main.sv file.

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request.
