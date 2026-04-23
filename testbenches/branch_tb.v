`timescale 1ns / 1ps

module branch_jump_tb;

    /*
    Use program_branch.hex

    Checks all of our branching and jumping functionality.
    */

    reg clk;
    reg rst;

    wire [31:0] pc;
    wire [31:0] instr;

    integer i;
    integer errors;

    main cpu (
        .clk(clk),
        .rst(rst),
        .pc_out(pc),
        .instr(instr),
        .alu_res()
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        #20;
        rst = 0;

        $display("Starting Branch/Jump Test\n");

        // Run enough cycles
        for (i = 0; i < 40; i = i + 1) begin
            @(posedge clk);
            #1;
            $display("x1=%d", cpu.REGFILE.registers[1]);
            $display("Cycle %0d | PC=%0d | Instr=0x%h", i, pc, instr);
        end

        errors = 0;

        $display("\n========================================");
        $display("SUMMARY");
        $display("========================================");

        // BEQ skip check
        if (cpu.REGFILE.registers[4] != 0) begin
            $display("x4 = 0x%h", cpu.REGFILE.registers[4]);
            $display("BEQ FAILED: x4 should be 0");
            errors++;
        end else $display("BEQ PASS");

        // BNE skip check
        if (cpu.REGFILE.registers[6] != 0) begin
            $display("BNE FAILED: x6 should be 0");
            errors++;
        end else $display("BNE PASS");

        // BLT not taken
        if (cpu.REGFILE.registers[8] != 5) begin
            $display("BLT FAILED: x8 should be 5");
            errors++;
        end else $display("BLT PASS");

        // BGE taken
        if (cpu.REGFILE.registers[9] != 0) begin
            $display("BGE FAILED: x9 should be 0");
            errors++;
        end else $display("BGE PASS");

        // JAL skip
        if (cpu.REGFILE.registers[10] != 0) begin
            $display("x10 = 0x%h", cpu.REGFILE.registers[10]);
            $display("JAL FAILED: x10 should be 0");
            errors++;
        end else $display("JAL PASS");

        // Post-JAL execution
        if (cpu.REGFILE.registers[11] != 73) begin
            $display("JAL FLOW FAILED: x11 should be 73");
            errors++;
        end else $display("JAL FLOW PASS");

        // JALR skip
        if (cpu.REGFILE.registers[12] == 10) begin
            $display("JALR FAILED: x12 should NOT be 10");
            errors++;
        end else $display("JALR PASS");

        // AUIPC check (just zeros)
        if (cpu.REGFILE.registers[14] == 0) begin
            $display("AUIPC FAILED");
            errors++;
        end else $display("AUIPC PASS");

        $display("\n========================================");

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d TESTS FAILED", errors);

        $finish;
    end

endmodule