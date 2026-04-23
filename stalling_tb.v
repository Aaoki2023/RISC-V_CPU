`timescale 1ns/1ps

module main_tb;

    reg clk;
    reg rst;

    wire [31:0] pc_out;
    wire [31:0] instr;
    wire [31:0] alu_res;

    // Instantiate cpu
    main cpu (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .instr(instr),
        .alu_res(alu_res)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;

        #10;
        rst = 0;

        // Run simulation long enough
        #400;

        $display("\n==== FINAL REGISTER STATE ====");
        $display("x5 = %d", cpu.REGFILE.registers[5]);
        $display("x6 = %d", cpu.REGFILE.registers[6]);
        $display("x7 = %d", cpu.REGFILE.registers[7]);
        $display("x9 = %d", cpu.REGFILE.registers[9]);

        $finish;
    end

    // Monitor pipeline behavior
    always @(posedge clk) begin
        $display("--------------------------------------------------");
        $display("PC = %h | instr = %h", pc_out, instr);

        $display("ID/EX.rs1 = %d rs2 = %d rd = %d",
            cpu.ID_EX_rs1, cpu.ID_EX_rs2, cpu.ID_EX_rd);

        $display("EX/MEM.rd = %d | MEM/WB.rd = %d",
            cpu.EX_MEM_rd, cpu.MEM_WB_rd);

        $display("forwardA = %b | forwardB = %b",
            cpu.forwardA, cpu.forwardB);

        $display("ALU result = %d", alu_res);
    end

endmodule