`timescale 1ns / 1ps

/**
Ignore the load and store tests in this file, I ran out of registers to use so they won't pass
I moved them to the cpu_tb.v testbench instead so that way I would have enough registers.
*/

module cpu_tb_old;

    // Inputs
    reg clk;
    reg rst;
    
    // Outputs
    wire [31:0] pc;
    wire [31:0] instruction;
    wire [31:0] alu_result;
    
    // Expected register values after execution
    reg [31:0] expected_regs [0:31];
    
    integer i;
    integer errors;
    
    main cpu (
        .clk(clk),
        .rst(rst),
        .pc_out(pc),
        .instr(instruction),
        .alu_res(alu_result)
    );
    
    initial begin
        clk = 0;
        forever #41.67 clk = ~clk;
    end
    initial begin
        
        // x0 is always 0
        expected_regs[0] = 32'd0;
        
        expected_regs[1]  = 32'd30;           // addi x1, x0, 10
        expected_regs[2]  = 32'd20;           // addi x2, x0, 20
        expected_regs[3]  = 32'd30;           // add x3, x1, x2 (10+20)
        expected_regs[4]  = 32'd20;           // sub x4, x3, x1 (30-10)
        expected_regs[5]  = 32'd0;            // and x5, x1, x2 (10&20)
        expected_regs[6]  = 32'd30;           // or x6, x1, x2 (10|20)
        expected_regs[7]  = 32'd10;           // xor x7, x3, x4 (30^20)
        expected_regs[8]  = 32'd40;           // slli x8, x1, 2 (10<<2)
        expected_regs[9]  = 32'd10;           // srli x9, x2, 1 (20>>1)
        expected_regs[10] = 32'd25;           // addi x10, x3, -5 (30-5)
        expected_regs[11] = 32'h12345000;     // lui x11, 0x12345
        expected_regs[12] = 32'h00000000;     // andi x12, x11, 0xFF
        expected_regs[13] = 32'd250;          // ori x13, x1, 0xF0 (10|240)
        expected_regs[14] = 32'd235;          // xori x14, x2, 0xFF (20^255)
        expected_regs[15] = 32'd275;          // add x15, x10, x13 (25+250)
        expected_regs[16] = 32'd40;           // sub x16, x15, x14 (275-235)
        // expected_regs[17] = 32'd42;           // Will store and load 42
        // expected_regs[18] = 32'd100;          // Base address for array
        // expected_regs[19] = 32'd11;           // Array element 0
        // expected_regs[20] = 32'd22;           // Array element 1
        // expected_regs[21] = 32'd33;           // Array element 2
        // expected_regs[22] = 32'd11;           // Loaded from mem[0]
        // expected_regs[23] = 32'd22;           // Loaded from mem[4]
        // expected_regs[24] = 32'd33;           // Loaded from mem[8] test something larger than 42

        expected_regs[17] = 32'hdeadaeef;     // Built value
        expected_regs[18] = 32'h00000000;     // Base address
        expected_regs[19] = 32'h12345678;     // Loaded (32-bit test!)
        expected_regs[20] = 32'hFFFFFFFF;     // All bits set
        expected_regs[21] = 32'hFFFFFFFF;     // Loaded
        expected_regs[22] = 32'h80000000;     // MSB set
        expected_regs[23] = 32'h80000000;     // Loaded
        
        // Byte/halfword tests (final values after overwrites)
        expected_regs[24] = 32'd200;          // Base address (halfword tests)
        expected_regs[25] = 32'h00001234;     // LHU result
        expected_regs[26] = 32'h00008000;     // LHU of 0x8000 (zero-extended)
        expected_regs[27] = 32'hFFFFFFFF;     // LH of 0xFFFF (sign-extended)
        expected_regs[28] = 32'h0000FFFF;     // LHU of 0xFFFF (zero-extended)
        expected_regs[29] = 32'hFFFFFFFF;     // LB of 0xFF (sign-extended)
        expected_regs[30] = 32'h000000FF;     // LBU of 0xFF (zero-extended)
        expected_regs[31] = 32'hFFFF8000;     // LH of 0x8000 (sign-extended)

        // Registers 25-31
        for (i = 25; i < 32; i = i + 1) begin
            expected_regs[i] = 32'd0;
        end
        
        // reset the CPU
        rst = 1;
        $display("Resetting CPU");
        #15;
        rst = 0;
        #5;
        $display("Reset complete \n");
        
        $display("Executing instructions...\\n");
        $display("Cycle | PC  | Instruction | ALU Result");
        $display("------|-----|-------------|------------");
        for (i = 0; i < 70; i = i + 1) begin
            @(posedge clk);
            #1;
            $display("%5d | %3d | 0x%h | %10d", i, pc, instruction, alu_result);
        end
        
        // Check all registers
        $display("Checking Register Values\n");
        errors = 0;
        
        for (i = 0; i < 17; i = i + 1) begin
            if (cpu.REGFILE.registers[i] !== expected_regs[i]) begin
                $display("ERROR: x%0d = %d (0x%h), Expected: %d (0x%h)", 
                         i, 
                         $signed(cpu.REGFILE.registers[i]),
                         cpu.REGFILE.registers[i],
                         $signed(expected_regs[i]),
                         expected_regs[i]);
                errors = errors + 1;
            end else begin
                $display("x%0d = %d (0x%h)", 
                         i, 
                         $signed(cpu.REGFILE.registers[i]),
                         cpu.REGFILE.registers[i]);
            end
        end

        // // Check x17-x24
        // for (i = 17; i <= 31; i = i + 1) begin
        //     if (cpu.REGFILE.registers[i] !== expected_regs[i]) begin
        //         $display("ERROR: x%0d = %d (0x%h), Expected: %d (0x%h)", 
        //                  i, 
        //                  $signed(cpu.REGFILE.registers[i]),
        //                  cpu.REGFILE.registers[i],
        //                  $signed(expected_regs[i]),
        //                  expected_regs[i]);
        //         errors = errors + 1;
        //     end else begin
        //         $display("x%0d = %d (0x%h)", 
        //                  i, 
        //                  $signed(cpu.REGFILE.registers[i]),
        //                  cpu.REGFILE.registers[i]);
        //     end
        // end
        

        // ========================================
        // Test 2: 32-bit Word Load/Store
        // ========================================
        $display("========================================");
        $display("Test 2: 32-bit Word Load/Store");
        $display("========================================\n");
        
        errors = 0;

        if (cpu.REGFILE.registers[25] == expected_regs[25]) begin
            $display("x25: 0x%h", cpu.REGFILE.registers[25]);
        end
        
        // Critical 32-bit test
        if (cpu.REGFILE.registers[19] !== 32'h12345678) begin
            $display("CRITICAL: x19 = 0x%h, Expected: 0x12345678", 
                     cpu.REGFILE.registers[19]);
            $display("   32-bit word load/store NOT working!");
            errors = errors + 1;
        end else begin
            $display("x19 = 0x12345678 - All 32 bits work!");
        end
        
        // Other word tests
        for (i = 17; i <= 23; i = i + 1) begin
            if (i == 19) continue; // Already checked above
            
            if (cpu.REGFILE.registers[i] !== expected_regs[i]) begin
                $display("ERROR: x%0d = 0x%h, Expected: 0x%h", 
                         i, cpu.REGFILE.registers[i], expected_regs[i]);
                errors = errors + 1;
            end else begin
                $display("x%0d = 0x%h", i, cpu.REGFILE.registers[i]);
            end
        end
        
        if (errors == 0) begin
            $display("\nWord load/store tests PASSED\n");
        end else begin
            $display("\nWord load/store tests FAILED: %0d errors\n", errors);
        end
        
        // ========================================
        // Test 3: Byte Load/Store & Extensions
        // ========================================
        $display("========================================");
        $display("Test 3: Byte Load/Store & Sign Extension");
        $display("========================================\n");
        
        errors = 0;
        
        // LB sign extension (0xFF → 0xFFFFFFFF)
        if (cpu.REGFILE.registers[29] !== 32'hFFFFFFFF) begin
            $display("ERROR: x29 = 0x%h, Expected: 0xFFFFFFFF", 
                     cpu.REGFILE.registers[29]);
            $display("   LB sign extension NOT working!");
            errors = errors + 1;
        end else begin
            $display("x29 = 0xFFFFFFFF - LB sign extension works (0xFF → -1)");
        end
        
        // LBU zero extension (0xFF → 0x000000FF)
        if (cpu.REGFILE.registers[30] !== 32'h000000FF) begin
            $display("ERROR: x30 = 0x%h, Expected: 0x000000FF", 
                     cpu.REGFILE.registers[30]);
            $display("   LBU zero extension NOT working!");
            errors = errors + 1;
        end else begin
            $display("x30 = 0x000000FF - LBU zero extension works (0xFF → 255)");
        end
        
        if (errors == 0) begin
            $display("\nByte load/store tests PASSED\n");
        end else begin
            $display("\nByte load/store tests FAILED: %0d errors\n", errors);
        end
        
        // ========================================
        // Test 4: Halfword Load/Store & Extensions
        // ========================================
        $display("========================================");
        $display("Test 4: Halfword Load/Store & Sign Extension");
        $display("========================================\n");
        
        errors = 0;
        
        // LH sign extension (0x8000 → 0xFFFF8000)
        if (cpu.REGFILE.registers[31] !== 32'hFFFF8000) begin
            $display("ERROR: x31 = 0x%h, Expected: 0xFFFF8000", 
                     cpu.REGFILE.registers[31]);
            $display("   LH sign extension NOT working!");
            errors = errors + 1;
        end else begin
            $display("x31 = 0xFFFF8000 - LH sign extension works (0x8000 -> -32768)");
        end
        
        // LHU zero extension (0x8000 → 0x00008000)
        if (cpu.REGFILE.registers[26] !== 32'h00008000) begin
            $display("ERROR: x26 = 0x%h, Expected: 0x00008000", 
                     cpu.REGFILE.registers[26]);
            $display("   LHU zero extension NOT working!");
            errors = errors + 1;
        end else begin
            $display("x26 = 0x00008000 - LHU zero extension works (0x8000 -> 32768)");
        end
        
        // LH sign extension (0xFFFF → 0xFFFFFFFF)
        if (cpu.REGFILE.registers[27] !== 32'hFFFFFFFF) begin
            $display("ERROR: x27 = 0x%h, Expected: 0xFFFFFFFF", 
                     cpu.REGFILE.registers[27]);
            $display("   LH sign extension (0xFFFF) NOT working!");
            errors = errors + 1;
        end else begin
            $display("x27 = 0xFFFFFFFF - LH sign extension works (0xFFFF -> -1)");
        end
        
        // LHU zero extension (0xFFFF → 0x0000FFFF)
        if (cpu.REGFILE.registers[28] !== 32'h0000FFFF) begin
            $display("ERROR: x28 = 0x%h, Expected: 0x0000FFFF", 
                     cpu.REGFILE.registers[28]);
            $display("   LHU zero extension (0xFFFF) NOT working!");
            errors = errors + 1;
        end else begin
            $display("x28 = 0x0000FFFF - LHU zero extension works (0xFFFF -> 65535)");
        end
        
        if (errors == 0) begin
            $display("\nHalfword load/store tests PASSED\n");
        end else begin
            $display("\nHalfword load/store tests FAILED: %0d errors\n", errors);
        end
        
        $display("  Test Summary");
        $display("Total Registers Checked: 32");
        $display("Errors Found: %0d", errors);
        
        if (errors == 0) begin
            $display("\nEverything works!");
        end else begin
            $display("%0d register(s) have incorrect values", errors);
        end
        
        
        // Check x0 is hardwired to 0
        if (cpu.REGFILE.registers[0] === 32'd0) begin
            $display("x0 is hardwired to zero");
        end else begin
            $display("ERROR: x0 is not zero! x0 = %d", cpu.REGFILE.registers[0]);
        end
        
        // Check that no unwritten registers were corrupted
        // $display("\nChecking unwritten registers (x17-x31)...");
        // for (i = 25; i < 32; i = i + 1) begin
        //     if (cpu.REGFILE.registers[i] !== 32'd0) begin
        //         $display("x%0d was corrupted (value = %d)", i, cpu.REGFILE.registers[i]);
        //     end
        // end
        // $display("No corrupted registers");
        
        // // Check final PC value
        // $display("\nFinal PC: %d (0x%h)", pc, pc);
        // if (pc == 32'd108) begin  
        //     $display("PC works");
        // end else begin
        //     $display("Expected PC=64, got PC=%d", pc);
        // end
        
        
        $finish;
    end

    
    // timeout
    initial begin
        #10000;
        $display("\nRuntime timeout");
        $finish;
    end

endmodule