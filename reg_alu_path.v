/*
 get rid of this file and integrate stuff into main file
*/

module reg_alu_path(
    input wire clk,
    input wire rst,

    input wire [4:0] source_1, // source addr 1
    input wire [4:0] source_2, // source addr 2
    input wire [4:0] out_addr, // output addr
    input wire [31:0] immediate,

    input wire write_enable,
    input wire imm_sel,
    input wire [3:0] alu_op,

    input wire mem_read,
    input wire mem_write,
    input wire mem_to_reg,

    output wire [31:0] alu_res,
    output wire alu_zero,
    output wire alu_carry,
    output wire alu_overflow,
    output wire alu_sign
);

    wire [31:0] data1;
    wire [31:0] data2;
    wire [31:0] alu_input2; // either an immediate or reg value 

    wire less_than_flag;
    wire equal_flag;
    wire greater_than_flag;
    wire [31:0] mem_data;
    wire [31:0] write_back_data;

    assign write_back_data = mem_to_reg ? mem_data : alu_res; // MUX to decide load mem or alu res // explicit myltiplexer component

    register_file regfile (
        .clk(clk),
        .reset(rst),
        .r_addr1(source_1),
        .r_data1(data1),
        .r_addr2(source_2),
        .r_data2(data2),
        .w_enable(write_enable),
        .w_addr(out_addr),
        .w_data(write_back_data)
    );

    assign alu_input2 = imm_sel ? immediate : data2;

    alu a (
        .in1(data1),
        .in2(alu_input2),
        .control(alu_op),
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
        .read_data(mem_data)
    );
    
endmodule