module instr_decode(
    input wire [31:0] instr,

    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [4:0] rd,

    output reg [31:0] imm,

    output reg reg_write,
    output reg alu_src,
    output reg [3:0] alu_control,

    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,

    output reg [1:0] mem_size,     // 00=byte, 01=half, 10=word
    output reg mem_unsigned        // 1=unsigned load, 0=signed load
);

    /*
    Reg-Imm instr
    opcode [6:0]
    rd [11:7]
    funct3 [14:12]
    rs1 [19:15]
    imm [31:20]
    

    Reg-Reg instr
    opcode [6:0]
    rd [11:7]
    funct3 [14:12]
    rs1 [19:15]
    rs2 [24:20]
    funct7[31:25]
    */

    wire [6:0] opcode = instr[6:0];
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    assign rd = instr[11:7];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];

    // op codes
    localparam AND = 4'b0000;
    localparam OR = 4'b0001;
    localparam XOR = 4'b0010;
    localparam SHL = 4'b0100;
    localparam SHR = 4'b0101;
    localparam ADD = 4'b0110;
    localparam SUB = 4'b0111;
    localparam SRA = 4'b1011;
    localparam PASS_B = 4'b1000;
    
    // risc-v op codes
    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE = 7'b0010011;
    localparam OP_LUI = 7'b0110111; // load upper imm so that way you can have a 32 bit immediate

    localparam LOAD = 7'b0000011;
    localparam STORE = 7'b0100011;

    localparam MEM_BYTE = 2'b00;
    localparam MEM_HALF = 2'b01;
    localparam MEM_WORD = 2'b10;

    always @(*) begin
        reg_write = 0;
        alu_src = 0;
        alu_control = ADD;
        imm = 32'b0;
        mem_read = 0;
        mem_write = 0;
        mem_to_reg = 0;
        mem_size = MEM_WORD;
        mem_unsigned = 0;  

        case (opcode)

            // register - register functions
            R_TYPE: begin
                reg_write = 1;
                alu_src = 0; // want to uyse a reg

                case (funct3)

                    3'b000: begin // sub or add
                        if (funct7 == 7'b0000000)
                            alu_control = ADD;
                        else if (funct7 == 7'b0100000)
                            alu_control = SUB;
                        else
                            alu_control = ADD;
                    end

                    3'b111: alu_control = AND;
                    3'b110: alu_control = OR;
                    3'b100: alu_control = XOR;
                    3'b001: alu_control = SHL;
                    3'b101: begin
                        if (funct7 == 7'b0000000)
                            alu_control = SHR;  // SRL
                        else if (funct7 == 7'b0100000)
                            alu_control = SRA;  // you need a new ALU op
                    end
                    default: alu_control = ADD;

                endcase
            end

            // register - immediate functions
            I_TYPE: begin
                reg_write = 1;
                alu_src = 1;

                imm = {{20{instr[31]}}, instr[31:20]};

                case (funct3)
                    3'b000: alu_control = ADD;
                    3'b111: alu_control = AND;
                    3'b110: alu_control = OR;
                    3'b100: alu_control = XOR;
                    3'b001: begin // SLLI
                        alu_control = SHL;
                        imm = {27'b0, instr[24:20]};
                    end
                    3'b101: begin
                        imm = {27'b0, instr[24:20]};

                        if (funct7 == 7'b0000000)
                            alu_control = SHR;   // SRLI
                        else if (funct7 == 7'b0100000)
                            alu_control = SRA;   // SRAI
                                        end
                    default: alu_control = ADD;
                    
                endcase
            end

            LOAD: begin
                reg_write = 1;
                alu_src = 1;

                alu_control = ADD;
                mem_read = 1;
                mem_to_reg = 1;

                imm = {{20{instr[31]}}, instr[31:20]};

                case (funct3)
                    3'b000: begin  // LB
                        mem_size = MEM_BYTE;
                        mem_unsigned = 0;
                    end
                    3'b001: begin  // LH
                        mem_size = MEM_HALF;
                        mem_unsigned = 0;
                    end
                    3'b010: begin  // LW
                        mem_size = MEM_WORD;
                        mem_unsigned = 0;  //
                    end
                    3'b100: begin  // LBU
                        mem_size = MEM_BYTE;
                        mem_unsigned = 1;
                    end
                    3'b101: begin  // LHU
                        mem_size = MEM_HALF;
                        mem_unsigned = 1;
                    end
                    default: begin  
                        mem_size = MEM_WORD;
                        mem_unsigned = 0;
                    end
                endcase
            end

            STORE: begin
                reg_write = 0;
                alu_src = 1;

                alu_control = ADD;
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 1;

                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};

                case (funct3)
                    3'b000: begin  // SB
                        mem_size = MEM_BYTE;
                    end
                    3'b001: begin  // SH
                        mem_size = MEM_HALF;
                    end
                    3'b010: begin  // SW
                        mem_size = MEM_WORD;
                    end
                    default: begin 
                        mem_size = MEM_WORD;
                    end
                endcase
            end

            OP_LUI: begin
                reg_write = 1;
                alu_src = 1;
                alu_control = PASS_B;
                imm = {instr[31:12], 12'b0};
            end

            default: begin
                reg_write = 0;
                alu_src = 0;
                alu_control = ADD;
            end

        endcase
    end

endmodule