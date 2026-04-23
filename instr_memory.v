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
    
    always @(negedge clk) begin
        if (write_enable) begin
            mem[write_addr[9:0]] <= write_data;
            
        end
    end
    
    // default program at initialization
    initial begin

        integer i;
        for (i = 0; i < 1024; i = i + 1)
            mem[i] = 32'h00000013;

        $readmemh("./testbenches/hex_files/program_hw_byte.hex", mem); // streamline your risc-v to hex so that way you know what your hex is doing
        $display("mem[0] = %h", mem[0]);
    end

endmodule

// check to make sure you can read from two SBRAM in parallel for register file and data memory stages - yes
// add the MUX for the last data hazard (at the very bottom of her ntoes)
// make your tests more complete
// try uploading to upduino, see if you can get your hands on an oscilliscope or multimeter