module forwarding_unit(
    input [4:0] ID_EX_rs1,
    input [4:0] ID_EX_rs2,
    input [4:0] EX_MEM_rd,
    input EX_MEM_reg_write,
    input [4:0] MEM_WB_rd,
    input MEM_WB_reg_write,
    output reg [1:0] forwardA, // 00 = ID_EX, 10 = EX_MEM, 01 = MEM_WB
    output reg [1:0] forwardB
);

    always @(*) begin
        // default
        forwardA = 2'b00;
        forwardB = 2'b00;

        // Operand A
        if (EX_MEM_reg_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1))
            forwardA = 2'b10; // EX hazard (1 instruction ago)
        else if (MEM_WB_reg_write && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs1))
            forwardA = 2'b01; // MEM hazard (2 instructions ago)
        else
            forwardA = 2'b00; // No hazard

        // Operand B
        if (EX_MEM_reg_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2))
            forwardB = 2'b10; // EX hazard
        else if (MEM_WB_reg_write && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs2))
            forwardB = 2'b01; // MEM hazard
        else
            forwardB = 2'b00; // No hazard
    end
endmodule