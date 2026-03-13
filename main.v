module main(
    input wire clk,
    input wire rst,

    output wire [31:0] pc_out,
    output wire [31:0] instr,
    output wire [31:0] alu_res
);

    wire [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    assign pc_out = pc;

    // wire [31:0] instr;

    // assign instr_out = instr;

    wire [4:0] rs1, rs2, rd;
    wire [31:0] imm;
    wire reg_write;
    wire alu_src;
    wire [3:0] alu_control;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire [1:0] mem_size;
    wire mem_unsigned;

    // wire [31:0] alu_res;
    wire alu_zero, alu_carry, alu_overflow, alu_sign;
    wire [31:0] data1;
    wire [31:0] data2;
    wire [31:0] alu_input2; // either an immediate or reg value 

    wire less_than_flag;
    wire equal_flag;
    wire greater_than_flag;
    wire [31:0] mem_data;
    wire [31:0] write_back_data;
    

    program_counter PC (
        .clk(clk),
        .rst(rst),
        .pc_nxt(pc_next),
        .curr(pc)
    );

    // next seq instr, use the temp pc_plus_4 to save time down the line for log jumps
    assign pc_plus_4 = pc+4;
    assign pc_next = pc_plus_4;

    instr_memory IMEM (
        .pc(pc),
        .instr(instr),
        .write_enable(1'b0),
        .write_addr(32'b0),
        .write_data(32'b0)
    );

    instr_decode DECODE (
        .instr(instr),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm(imm),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_control(alu_control),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .mem_size(mem_size),
        .mem_unsigned(mem_unsigned)
    );

    // reg_alu_path DATAPATH (
    //     .clk(clk),
    //     .rst(rst),
    //     .source_1(rs1),
    //     .source_2(rs2),
    //     .out_addr(rd),
    //     .immediate(imm),
    //     .write_enable(reg_write),
    //     .imm_sel(alu_src),
    //     .alu_op(alu_control),
    //     .mem_read(mem_read),
    //     .mem_write(mem_write),
    //     .mem_to_reg(mem_to_reg),
    //     .alu_res(alu_res),
    //     .alu_zero(alu_zero),
    //     .alu_carry(alu_carry),
    //     .alu_overflow(alu_overflow),
    //     .alu_sign(alu_sign)
    // );

    register_file REGFILE (
        .clk(clk),
        .reset(rst),
        .r_addr1(rs1),
        .r_addr2(rs2),
        .r_data1(data1),
        .r_data2(data2),
        .w_enable(reg_write),
        .w_addr(rd),
        .w_data(write_back_data)
    );

    assign alu_input2 = alu_src ? imm : data2;

    alu A (
        .in1(data1),
        .in2(alu_input2),
        .control(alu_control),
        .res(alu_res),
        .carry(alu_carry),
        .sign(alu_sign),
        .overflow(alu_overflow),
        .zero(alu_zero),
        .less_than(less_than_flag),
        .greater_than(greater_than_flag),
        .equal(equal_flag)
    );

    data_mem DMEM (
        .clk(clk),
        .addr(alu_res),
        .write_data(data2),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_size(mem_size),
        .mem_unsigned(mem_unsigned),
        .read_data(mem_data)
    );

    assign write_back_data = mem_to_reg ? mem_data : alu_res;

endmodule