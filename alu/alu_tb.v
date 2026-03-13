`timescale 1ns / 1ps

module alu_tb;

    // Inputs
    reg [31:0] operand_a;
    reg [31:0] operand_b;
    reg [3:0] alu_control;
    
    // Outputs
    wire [31:0] result;
    wire carry_flag;
    wire sign_flag;
    wire overflow_flag;
    wire zero_flag;
    wire less_than_flag;
    wire equal_flag;
    wire greater_than_flag;
    
    // Instantiate the ALU
    alu uut (
        .in1(operand_a),
        .in2(operand_b),
        .control(alu_control),
        .res(result),
        .carry(carry_flag),
        .sign(sign_flag),
        .overflow(overflow_flag),
        .zero(zero_flag),
        .less_than(less_than_flag),
        .equal(equal_flag),
        .greater_than(greater_than_flag)
    );
    
    // Test counter for tracking progress
    integer test_num;
    integer passed_tests;
    integer failed_tests;
    
    // Test procedure
    initial begin
        test_num = 0;
        passed_tests = 0;
        failed_tests = 0;
        
        $display("Starting ALU Test");
        $display("=================\n");
        
        // Test AND
        test_num = test_num + 1;
        operand_a = 32'hF0F0F0F0;
        operand_b = 32'h0F0F0F0F;
        alu_control = 4'b0000; // AND
        #10;
        assert(result == 32'h00000000) begin
            $display("Test %0d PASSED: AND operation", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: AND - Expected: 00000000, Got: %h", test_num, result);
            failed_tests = failed_tests + 1;
        end
        
        // Test OR
        test_num = test_num + 1;
        alu_control = 4'b0001; // OR
        #10;
        assert(result == 32'hFFFFFFFF) begin
            $display("Test %0d PASSED: OR operation", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: OR - Expected: FFFFFFFF, Got: %h", test_num, result);
            failed_tests = failed_tests + 1;
        end
        
        // Test XOR
        test_num = test_num + 1;
        alu_control = 4'b0010; // XOR
        #10;
        assert(result == 32'hFFFFFFFF) begin
            $display("Test %0d PASSED: XOR operation", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: XOR - Expected: FFFFFFFF, Got: %h", test_num, result);
            failed_tests = failed_tests + 1;
        end
        
        // Test NOT
        test_num = test_num + 1;
        operand_a = 32'hAAAAAAAA;
        alu_control = 4'b0011; // NOT
        #10;
        assert(result == 32'h55555555) begin
            $display("Test %0d PASSED: NOT operation", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: NOT - Expected: 55555555, Got: %h", test_num, result);
            failed_tests = failed_tests + 1;
        end
        
        // Test Shift Left
        test_num = test_num + 1;
        operand_a = 32'h00000001;
        operand_b = 32'h00000004; // Shift by 4
        alu_control = 4'b0100; // SHL
        #10;
        assert(result == 32'h00000010) begin
            $display("Test %0d PASSED: Shift Left operation", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: SHL - Expected: 00000010, Got: %h", test_num, result);
            failed_tests = failed_tests + 1;
        end
        
        // Test Shift Right
        test_num = test_num + 1;
        operand_a = 32'h80000000;
        operand_b = 32'h00000004; // Shift by 4
        alu_control = 4'b0101; // SHR
        #10;
        assert(result == 32'h08000000) begin
            $display("Test %0d PASSED: Shift Right operation", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: SHR - Expected: 08000000, Got: %h", test_num, result);
            failed_tests = failed_tests + 1;
        end
        
        // Test Addition
        test_num = test_num + 1;
        operand_a = 32'd100;
        operand_b = 32'd50;
        alu_control = 4'b0110; // ADD
        #10;
        assert(result == 32'd150 && carry_flag == 1'b0) begin
            $display("Test %0d PASSED: Addition operation", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: ADD - Expected: 150 (carry=0), Got: %d (carry=%b)", 
                     test_num, result, carry_flag);
            failed_tests = failed_tests + 1;
        end
        
        // Test Addition with overflow
        test_num = test_num + 1;
        operand_a = 32'h7FFFFFFF; // Max positive
        operand_b = 32'h00000001;
        alu_control = 4'b0110; // ADD
        #10;
        assert(overflow_flag == 1'b1 && result == 32'h80000000) begin
            $display("Test %0d PASSED: Addition with overflow", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: ADD Overflow - Expected: overflow=1, result=80000000, Got: overflow=%b, result=%h", 
                     test_num, overflow_flag, result);
            failed_tests = failed_tests + 1;
        end
        
        // Test Subtraction
        test_num = test_num + 1;
        operand_a = 32'd100;
        operand_b = 32'd50;
        alu_control = 4'b0111; // SUB
        #10;
        assert(result == 32'd50) begin
            $display("Test %0d PASSED: Subtraction operation", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: SUB - Expected: 50, Got: %d", test_num, result);
            failed_tests = failed_tests + 1;
        end
        
        // Test Multiplication
        test_num = test_num + 1;
        operand_a = 32'd12;
        operand_b = 32'd5;
        alu_control = 4'b1000; // MUL
        #10;
        assert(result == 32'd60) begin
            $display("Test %0d PASSED: Multiplication operation", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: MUL - Expected: 60, Got: %d", test_num, result);
            failed_tests = failed_tests + 1;
        end
        
        // Test Division
        test_num = test_num + 1;
        operand_a = 32'd100;
        operand_b = 32'd4;
        alu_control = 4'b1001; // DIV
        #10;
        assert(result == 32'd25) begin
            $display("Test %0d PASSED: Division operation", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: DIV - Expected: 25, Got: %d", test_num, result);
            failed_tests = failed_tests + 1;
        end
        
        // Test Division by zero
        test_num = test_num + 1;
        operand_a = 32'd100;
        operand_b = 32'd0;
        alu_control = 4'b1001; // DIV
        #10;
        assert(result == 32'd0) begin
            $display("Test %0d PASSED: Division by zero protection", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: DIV by 0 - Expected: 0, Got: %d", test_num, result);
            failed_tests = failed_tests + 1;
        end
        
        // Test Comparison: Less Than
        test_num = test_num + 1;
        operand_a = 32'hFFFFFFFF; // -1 in two's complement
        operand_b = 32'h00000001; // +1
        alu_control = 4'b1010; // CMP
        #10;
        assert(less_than_flag == 1'b1 && equal_flag == 1'b0 && greater_than_flag == 1'b0) begin
            $display("Test %0d PASSED: Comparison (Less Than)", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: CMP (LT) - Expected: LT=1, EQ=0, GT=0, Got: LT=%b, EQ=%b, GT=%b", 
                     test_num, less_than_flag, equal_flag, greater_than_flag);
            failed_tests = failed_tests + 1;
        end
        
        // Test Comparison: Equal
        test_num = test_num + 1;
        operand_a = 32'd42;
        operand_b = 32'd42;
        alu_control = 4'b1010; // CMP
        #10;
        assert(less_than_flag == 1'b0 && equal_flag == 1'b1 && greater_than_flag == 1'b0) begin
            $display("Test %0d PASSED: Comparison (Equal)", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: CMP (EQ) - Expected: LT=0, EQ=1, GT=0, Got: LT=%b, EQ=%b, GT=%b", 
                     test_num, less_than_flag, equal_flag, greater_than_flag);
            failed_tests = failed_tests + 1;
        end
        
        // Test Comparison: Greater Than
        test_num = test_num + 1;
        operand_a = 32'd100;
        operand_b = 32'd50;
        alu_control = 4'b1010; // CMP
        #10;
        assert(less_than_flag == 1'b0 && equal_flag == 1'b0 && greater_than_flag == 1'b1) begin
            $display("Test %0d PASSED: Comparison (Greater Than)", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: CMP (GT) - Expected: LT=0, EQ=0, GT=1, Got: LT=%b, EQ=%b, GT=%b", 
                     test_num, less_than_flag, equal_flag, greater_than_flag);
            failed_tests = failed_tests + 1;
        end
        
        // Test Zero Flag
        test_num = test_num + 1;
        operand_a = 32'd50;
        operand_b = 32'd50;
        alu_control = 4'b0111; // SUB
        #10;
        assert(result == 32'd0 && zero_flag == 1'b1) begin
            $display("Test %0d PASSED: Zero flag detection", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: Zero Flag - Expected: result=0, zero_flag=1, Got: result=%d, zero_flag=%b", 
                     test_num, result, zero_flag);
            failed_tests = failed_tests + 1;
        end
        
        // Test Sign Flag (negative result)
        test_num = test_num + 1;
        operand_a = 32'd10;
        operand_b = 32'd20;
        alu_control = 4'b0111; // SUB (10 - 20 = -10)
        #10;
        assert(sign_flag == 1'b1) begin
            $display("Test %0d PASSED: Sign flag (negative result)", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: Sign Flag - Expected: sign_flag=1, Got: sign_flag=%b", 
                     test_num, sign_flag);
            failed_tests = failed_tests + 1;
        end
        
        // Test Subtraction Overflow
        test_num = test_num + 1;
        operand_a = 32'h80000000; // Most negative number
        operand_b = 32'h00000001; // Positive 1
        alu_control = 4'b0111; // SUB
        #10;
        assert(overflow_flag == 1'b1) begin
            $display("Test %0d PASSED: Subtraction overflow", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: SUB Overflow - Expected: overflow=1, Got: overflow=%b", 
                     test_num, overflow_flag);
            failed_tests = failed_tests + 1;
        end
        
        // Print summary
        $display("\n=================");
        $display("Test Summary:");
        $display("  Total Tests: %0d", test_num);
        $display("  Passed: %0d", passed_tests);
        $display("  Failed: %0d", failed_tests);
        
        if (failed_tests == 0) begin
            $display("\n*** ALL TESTS PASSED! ***");
        end else begin
            $display("\n*** SOME TESTS FAILED ***");
        end
        
        $display("=================");
        $finish;
    end

endmodule