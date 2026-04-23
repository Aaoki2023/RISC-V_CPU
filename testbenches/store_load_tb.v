`timescale 1ns / 1ps

module store_load_tb;

    /*
    Use program_hw_byte.hex

    Basic store and load functionalities for bytes, halfwords, and words.
    */

    reg clk;
    reg rst;

    wire [31:0] pc;
    wire [31:0] instruction;
    wire [31:0] alu_result;

    integer errors;

    main cpu (
        .clk(clk),
        .rst(rst),
        .pc_out(pc),
        .instr(instruction),
        .alu_res(alu_result)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        errors = 0;

        // Reset
        rst = 1;
        #20;
        rst = 0;

        // Run program
        repeat (20) @(posedge clk);

        $display("\n========================================");
        $display("BYTE TESTS");
        $display("========================================");

        // LB sign extend
        if (cpu.REGFILE.registers[3] !== 32'hFFFFFFFF) begin
            $display("LB FAIL: x3 = 0x%h (expected FFFFFFFF)", cpu.REGFILE.registers[3]);
            errors = errors + 1;
        end else begin
            $display("LB PASS");
        end

        // LBU zero extend
        if (cpu.REGFILE.registers[4] !== 32'h000000FF) begin
            $display("LBU FAIL: x4 = 0x%h (expected 000000FF)", cpu.REGFILE.registers[4]);
            errors = errors + 1;
        end else begin
            $display("LBU PASS");
        end


        $display("\n========================================");
        $display("HALFWORD TESTS");
        $display("========================================");

        // LH sign extend
        if (cpu.REGFILE.registers[6] !== 32'hFFFF8000) begin
            $display("LH FAIL: x5 = 0x%h (expected FFFF8000)", cpu.REGFILE.registers[5]);
            errors = errors + 1;
        end else begin
            $display("LH PASS");
        end

        // LHU zero extend
        if (cpu.REGFILE.registers[7] !== 32'h00008000) begin
            $display("LHU FAIL: x6 = 0x%h (expected 00008000)", cpu.REGFILE.registers[6]);
            errors = errors + 1;
        end else begin
            $display("LHU PASS");
        end

        $display("\n========================================");
        $display("WORD TESTS");
        $display("========================================");

        // SW/LW test
        if (cpu.REGFILE.registers[5] !== 32'h12345678) begin
            $display("WORD FAIL: x5 = 0x%h (expected 12345678)", cpu.REGFILE.registers[5]);
            errors = errors + 1;
        end else begin
            $display("WORD PASS: x5 = 0x%h", cpu.REGFILE.registers[5]);
        end

        $display("\n========================================");
        $display("SUMMARY");
        $display("========================================");

        if (errors == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("%0d TESTS FAILED", errors);
        end

        $finish;
    end

endmodule