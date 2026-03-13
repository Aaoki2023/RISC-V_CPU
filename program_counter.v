module program_counter (
    input wire clk,
    input wire rst,
    input wire [31:0] pc_nxt,
    output reg [31:0] curr
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            curr <= 32'b0;
        end else begin
            curr <= pc_nxt;
        end
    end
    
endmodule