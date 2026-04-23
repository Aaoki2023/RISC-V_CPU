# RISC-V Processor

Fully functional 5-stage pipelined RISC-V processor implementing RV32I base ISA written in Verilog.

### Architecture Overview
This is a 5 stage pipeline: Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB). Each stage is separated by pipeline registers that act as flip-flops, holding values necessary for each stage updating on the clock edge. This allows up to 5 instructions to be processed simultaneously. The IF stage fetches instruction from memory; ID stage decodes instructions and reads from the register file; EX stage performs ALU operations, computes branch/jump targets, and makes branch decisions; MEM stage handles load/store operations; and WB stage selects the appropriate result to write back to the register file.

### Hazard Handling
Data Hazards are resolved through two methods - forwarding and stalling. A forwarding unit that can detect dependencies and forward results from the EX/MEM or MEM/WB pipeline registers directly to the ALU inputs. The forwarding logic prioritizes hte most recent result (EX/MEM over MEM/WB). Stalling occurs when the EX stage require data acquried during the prior instruction's MEM stage. A stall control signal monitors this dependence and will force all subsequent stages to stall one stage in order to allow the MEM stage to resolve and pass the information to the EX stage.

Control Hazards from branches and jumpes are handled by making branch decision logic in the EX stage and flushing the IF/ID and ID/EX pipeline registers when a branch is taken. This results in a 2 cycle penalty for branches. 

### Supported Instructions
R-Type:
* ADD
* SUB
* AND
* OR
* XOR
* SLL
* SRL

I-TYPE:
* ADDI
* ANDI
* ORI
* XORI
* SLLI
* SRLI

Load/Store:
* LB
* LH
* LW
* LBU
* LHU
* SB
* SH
* SW

Branches/Jumps:
* BEQ
* BNE
* BLT
* BGE
* BLTU
* BGEU
* JAL
* JALR

Upper Imm:
* LUI
* AUIPC

### Files
* main.v - Top level pipelined processor
* decode.v - Instruction decoder with signal generation
* forwarding_unit.v - Data forwarding logic
* register_file.v - 32-entry register file
* alu.v - ALU
* data_mem.v - Data memory component
* instr_mem.v - Instruction memory (read-only)
* program_counter.v - program counter

### TestBenches
Several testbenches found in the testbenches folder are included to test the processor. Each testbench includes a header that explains the purpose of the testbench as well as the corresponding hex file, containing the machine code for that testbench. In order to run a testbench, have the instr_mem read in from the hex file, then run apio test [testbench name].v. For example, when running the the forwarding_tb.v, replace the line in instr_mem $readmemh("./testbenches/hex_files/program_branch.hex", mem);  with the test_forwarding.hex. Then run apio test testbenches/forwarding_tb.v.

### Author
Alex Aoki
