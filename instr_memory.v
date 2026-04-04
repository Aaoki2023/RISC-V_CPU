// module instr_memory (
//     input wire [31:0] pc,
//     output wire [31:0] instr
// );
    
//     // Memory array: 256 instructions (1KB of instruction memory)
//     // Each entry is 32 bits (one instruction)
//     reg [31:0] mem [0:255];
    
//     // Word-aligned access: PC/4 gives word index
//     // (PC is byte address, instructions are 4 bytes)
//     assign instruction = mem[pc[31:2]];
    
//     // Initialize with a simple RISC-V program
//     initial begin
//         // Initialize all to NOP (addi x0, x0, 0)
//         integer i;
//         for (i = 0; i < 256; i = i + 1) begin
//             mem[i] = 32'h00000013;  // NOP
//         end
        
//         // ====================================
//         // Sample Program: Simple arithmetic
//         // ====================================
        
//         // Instruction 0 (PC=0): addi x1, x0, 10
//         // x1 = 0 + 10 = 10
//         mem[0] = 32'h00A00093;
//         // Breakdown: 000000001010_00000_000_00001_0010011
//         //            imm[11:0]    rs1   fn3  rd    opcode
        
//         // Instruction 1 (PC=4): addi x2, x0, 20
//         // x2 = 0 + 20 = 20
//         mem[1] = 32'h01400113;
//         // Breakdown: 000000010100_00000_000_00010_0010011
        
//         // Instruction 2 (PC=8): add x3, x1, x2
//         // x3 = x1 + x2 = 10 + 20 = 30
//         mem[2] = 32'h002081B3;
//         // Breakdown: 0000000_00010_00001_000_00011_0110011
//         //            funct7  rs2   rs1   fn3  rd    opcode
        
//         // Instruction 3 (PC=12): sub x4, x3, x1
//         // x4 = x3 - x1 = 30 - 10 = 20
//         mem[3] = 32'h40118233;
//         // Breakdown: 0100000_00001_00011_000_00100_0110011
        
//         // Instruction 4 (PC=16): and x5, x1, x2
//         // x5 = x1 & x2 = 10 & 20 = 0
//         mem[4] = 32'h0020F2B3;
//         // Breakdown: 0000000_00010_00001_111_00101_0110011
        
//         // Instruction 5 (PC=20): or x6, x1, x2
//         // x6 = x1 | x2 = 10 | 20 = 30
//         mem[5] = 32'h0020E333;
//         // Breakdown: 0000000_00010_00001_110_00110_0110011
        
//         // Instruction 6 (PC=24): xor x7, x3, x4
//         // x7 = x3 ^ x4 = 30 ^ 20 = 10
//         mem[6] = 32'h004183B3;
//         // Breakdown: 0000000_00100_00011_100_00111_0110011
        
//         // Instruction 7 (PC=28): slli x8, x1, 2
//         // x8 = x1 << 2 = 10 << 2 = 40
//         mem[7] = 32'h00209413;
//         // Breakdown: 0000000_00010_00001_001_01000_0010011
        
//         // Instruction 8 (PC=32): srli x9, x2, 1
//         // x9 = x2 >> 1 = 20 >> 1 = 10
//         mem[8] = 32'h0011D493;
//         // Breakdown: 0000000_00001_00010_101_01001_0010011
        
//         // Instruction 9 (PC=36): addi x10, x3, -5
//         // x10 = x3 + (-5) = 30 - 5 = 25
//         mem[9] = 32'hFFB18513;
//         // Breakdown: 111111111011_00011_000_01010_0010011
        
//         // Instruction 10 (PC=40): lui x11, 0x12345
//         // x11 = 0x12345000
//         mem[10] = 32'h123455B7;
//         // Breakdown: 00010010001101000101_01011_0110111
//         //            imm[31:12]           rd    opcode
        
//         // Instruction 11 (PC=44): andi x12, x11, 0xFF
//         // x12 = x11 & 0xFF = 0x12345000 & 0xFF = 0x00
//         mem[11] = 32'h0FF5F613;
//         // Breakdown: 000011111111_01011_111_01100_0010011
        
//         // Instruction 12 (PC=48): ori x13, x1, 0xF0
//         // x13 = x1 | 0xF0 = 10 | 240 = 250
//         mem[12] = 32'h0F00E693;
//         // Breakdown: 000011110000_00001_110_01101_0010011
        
//         // Instruction 13 (PC=52): xori x14, x2, 0xFF
//         // x14 = x2 ^ 0xFF = 20 ^ 255 = 235
//         mem[13] = 32'h0FF14713;
//         // Breakdown: 000011111111_00010_100_01110_0010011
        
//         // Instructions 14-15: More arithmetic for testing
//         // Instruction 14 (PC=56): add x15, x10, x13
//         // x15 = x10 + x13 = 25 + 250 = 275
//         mem[14] = 32'h00D507B3;
        
//         // Instruction 15 (PC=60): sub x16, x15, x14
//         // x16 = x15 - x14 = 275 - 235 = 40
//         mem[15] = 32'h40E78833;
        
//         // Rest are NOPs (already initialized)
        
//         $display("Instruction Memory Initialized");
//         $display("Sample Program:");
//         $display("  0: addi x1, x0, 10      # x1 = 10");
//         $display("  1: addi x2, x0, 20      # x2 = 20");
//         $display("  2: add  x3, x1, x2      # x3 = 30");
//         $display("  3: sub  x4, x3, x1      # x4 = 20");
//         $display("  4: and  x5, x1, x2      # x5 = 0");
//         $display("  5: or   x6, x1, x2      # x6 = 30");
//         $display("  6: xor  x7, x3, x4      # x7 = 10");
//         $display("  7: slli x8, x1, 2       # x8 = 40");
//         $display("  8: srli x9, x2, 1       # x9 = 10");
//         $display("  9: addi x10, x3, -5     # x10 = 25");
//         $display(" 10: lui  x11, 0x12345    # x11 = 0x12345000");
//         $display(" 11: andi x12, x11, 0xFF  # x12 = 0x00");
//         $display(" 12: ori  x13, x1, 0xF0   # x13 = 250");
//         $display(" 13: xori x14, x2, 0xFF   # x14 = 235");
//         $display(" 14: add  x15, x10, x13   # x15 = 275");
//         $display(" 15: sub  x16, x15, x14   # x16 = 40");
//     end


// endmodule

// need to split read and write so read is on first half clock and write is on second half clock

module instr_memory (
    input wire clk,
    
    input wire [31:0] pc,    // PC idx
    output reg [31:0] instr,    
    
    input wire write_enable,
    input wire [31:0] write_addr,   // Word address
    input wire [31:0] write_data    // Instruction to write
);

    reg [31:0] mem [0:1023];
    
    assign instr = mem[pc[11:2]];
    
    always @(posedge clk) begin
        if (write_enable) begin
            mem[write_addr[9:0]] <= write_data;
            
        end
    end
    
    // default program at initialization
    initial begin

        integer i;
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'h00000013;

        $readmemh("program.hex", mem); // streamline your risc-v to hex so that way you know what your hex is doing
        $display("mem[0] = %h", mem[0]);
    end

endmodule