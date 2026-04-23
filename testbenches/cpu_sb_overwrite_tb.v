`timescale 1ns / 1ps

module cpu_tb_sb_overwrite;


    /*
    use program_byte_overwrite.hex

    Checks that you can overwrite the lower byte of a halfword without corrupting the upper byte
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

        repeat (20) @(posedge clk);

        $display("\n========================================");
        $display("BYTE + HALFWORD OVERWRITE TEST");
        $display("========================================");

        // LH overwritten byte + sign extend
        if (cpu.REGFILE.registers[4] !== 32'hFFFF80AA) begin
            $display("LH FAIL: x4 = 0x%h (expected FFFF80AA)", cpu.REGFILE.registers[4]);
            errors = errors + 1;
        end else begin
            $display("LH PASS");
        end

        // LHU overwritten byte, zero extend
        if (cpu.REGFILE.registers[5] !== 32'h000080AA) begin
            $display("LHU FAIL: x5 = 0x%h (expected 000080AA)", cpu.REGFILE.registers[5]);
            errors = errors + 1;
        end else begin
            $display("LHU PASS");
        end


        $display("\n========================================");
        $display("RESULT");
        $display("========================================");

        if (errors == 0) begin
            $display("ALL TESTS PASSED");
        end else begin
            $display("%0d TESTS FAILED", errors);
        end

        $finish;
    end

endmodule