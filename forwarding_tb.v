`timescale 1ns / 1ps

module forwarding_tb;

    reg clk;
    reg rst;
    
    wire [31:0] pc;
    wire [31:0] instr;
    wire [31:0] alu_res;
    
    integer errors;
    integer cycle_count;
    
    main cpu (
        .clk(clk),
        .rst(rst),
        .pc_out(pc),
        .instr(instr),
        .alu_res(alu_res)
    );
    
    // Clock: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        $display("\n========================================");
        $display("  FORWARDING UNIT TEST");
        $display("========================================\n");
        
        errors = 0;
        cycle_count = 0;
        
        // Reset
        rst = 1;
        #20;
        rst = 0;
        
        // Monitor forwarding signals for first 20 cycles
        $display("Monitoring Forwarding Signals:\n");
        $display("Cycle | forwardA | forwardB | ID/EX_rs1 | ID/EX_rs2 | EX/MEM_rd | MEM/WB_rd | Instruction");
        $display("------|----------|----------|-----------|-----------|-----------|-----------|-------------");
        
        repeat(20) begin
            @(posedge clk);
            #1;  // Let signals settle
            
            $display("%5d |    %2b    |    %2b    |    %2d     |    %2d     |    %2d     |    %2d     | %h",
                     cycle_count,
                     cpu.forwardA,
                     cpu.forwardB,
                     cpu.ID_EX_rs1,
                     cpu.ID_EX_rs2,
                     cpu.EX_MEM_rd,
                     cpu.MEM_WB_rd,
                     cpu.IF_ID_instr);
            
            cycle_count = cycle_count + 1;
        end
        
        $display("\n========================================");
        $display("REGISTER VALUE VERIFICATION");
        $display("========================================\n");
        
        // Test 1: EX/MEM Forwarding
        $display("Test 1: EX/MEM Forwarding (RAW 1 cycle apart)");
        if (cpu.REGFILE.registers[1] !== 32'd10) begin
            $display("x1 = %d (expected 10)", cpu.REGFILE.registers[1]);
            errors = errors + 1;
        end else begin
            $display("x1 = %d", cpu.REGFILE.registers[1]);
        end
        
        if (cpu.REGFILE.registers[2] !== 32'd15) begin
            $display("x2 = %d (expected 15) - EX/MEM forwarding FAILED!", cpu.REGFILE.registers[2]);
            $display("   This means: addi x2, x1, 5 didn't get x1=10 forwarded from EX/MEM");
            errors = errors + 1;
        end else begin
            $display("x2 = %d - EX/MEM forwarding works!", cpu.REGFILE.registers[2]);
        end
        
        // Test 2: MEM/WB Forwarding
        $display("\nTest 2: MEM/WB Forwarding (RAW 2 cycles apart)");
        if (cpu.REGFILE.registers[3] !== 32'd20) begin
            $display("x3 = %d (expected 20)", cpu.REGFILE.registers[3]);
            errors = errors + 1;
        end else begin
            $display("x3 = %d", cpu.REGFILE.registers[3]);
        end
        
        if (cpu.REGFILE.registers[4] !== 32'd28) begin
            $display("x4 = %d (expected 28) - MEM/WB forwarding FAILED!", cpu.REGFILE.registers[4]);
            $display("   This means: addi x4, x3, 8 didn't get x3=20 forwarded from MEM/WB");
            errors = errors + 1;
        end else begin
            $display("x4 = %d - MEM/WB forwarding works!", cpu.REGFILE.registers[4]);
        end
        
        // Test 3: Back-to-Back Dependencies
        $display("\nTest 3: Back-to-Back Dependencies");
        if (cpu.REGFILE.registers[5] !== 32'd100) begin
            $display("x5 = %d (expected 100)", cpu.REGFILE.registers[5]);
            errors = errors + 1;
        end else begin
            $display("x5 = %d", cpu.REGFILE.registers[5]);
        end
        
        if (cpu.REGFILE.registers[6] !== 32'd200) begin
            $display("x6 = %d (expected 200) - Dual EX/MEM forwarding FAILED!", cpu.REGFILE.registers[6]);
            $display("   This means: add x6, x5, x5 didn't forward both operands");
            errors = errors + 1;
        end else begin
            $display("x6 = %d - Dual EX/MEM forwarding works!", cpu.REGFILE.registers[6]);
        end
        
        if (cpu.REGFILE.registers[7] !== 32'd100) begin
            $display("x7 = %d (expected 100) - Mixed forwarding FAILED!", cpu.REGFILE.registers[7]);
            $display("   This means: sub x7, x6, x5 didn't forward correctly");
            $display("   (x6 should come from EX/MEM, x5 from MEM/WB)");
            errors = errors + 1;
        end else begin
            $display("x7 = %d - Mixed forwarding works!", cpu.REGFILE.registers[7]);
        end
        
        // Test 4: Multiple Forwarding Paths
        $display("\nTest 4: Multiple Forwarding Paths");
        if (cpu.REGFILE.registers[8] !== 32'd50) begin
            $display("x8 = %d (expected 50)", cpu.REGFILE.registers[8]);
            errors = errors + 1;
        end else begin
            $display("x8 = %d", cpu.REGFILE.registers[8]);
        end
        
        if (cpu.REGFILE.registers[9] !== 32'd30) begin
            $display("x9 = %d (expected 30)", cpu.REGFILE.registers[9]);
            errors = errors + 1;
        end else begin
            $display("x9 = %d", cpu.REGFILE.registers[9]);
        end
        
        if (cpu.REGFILE.registers[10] !== 32'd80) begin
            $display("x10 = %d (expected 80) - Dual forwarding FAILED!", cpu.REGFILE.registers[10]);
            errors = errors + 1;
        end else begin
            $display("x10 = %d - Dual EX/MEM forwarding works!", cpu.REGFILE.registers[10]);
        end
        
        if (cpu.REGFILE.registers[11] !== 32'd30) begin
            $display("x11 = %d (expected 30) - Mixed forwarding FAILED!", cpu.REGFILE.registers[11]);
            errors = errors + 1;
        end else begin
            $display("x11 = %d - Mixed forwarding works!", cpu.REGFILE.registers[11]);
        end
        
        // Summary
        $display("\n========================================");
        $display("FORWARDING UNIT TEST SUMMARY");
        $display("========================================");
        
        if (errors == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("%0d TEST(S) FAILED", errors);
        end
        
        $display("========================================\n");
        
        $finish;
    end
    
    initial begin
        #3000;
        $display("\n❌ Timeout!");
        $finish;
    end

endmodule