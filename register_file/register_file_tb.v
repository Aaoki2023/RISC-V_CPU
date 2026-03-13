`timescale 1ns / 1ps

module register_file_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [4:0] read_addr1;
    reg [4:0] read_addr2;
    reg write_enable;
    reg [4:0] write_addr;
    reg [31:0] write_data;
    
    // Outputs
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    
    // Test tracking
    integer test_num;
    integer passed_tests;
    integer failed_tests;
    
    // Instantiate the register file
    register_file uut (
        .clk(clk),
        .reset(rst),
        .r_addr1(read_addr1),
        .r_data1(read_data1),
        .r_addr2(read_addr2),
        .r_data2(read_data2),
        .w_enable(write_enable),
        .w_addr(write_addr),
        .w_data(write_data)
    );
    
    // Clock generation - 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test procedure
    initial begin
        test_num = 0;
        passed_tests = 0;
        failed_tests = 0;
        
        $display("Starting Register File Test");
        $display("============================\n");
        
        // Initialize signals
        rst = 0;
        read_addr1 = 0;
        read_addr2 = 0;
        write_enable = 0;
        write_addr = 0;
        write_data = 0;
        
        // Test 1: Reset
        test_num = test_num + 1;
        rst = 1;
        #10;
        rst = 0;
        #10;
        
        // Read register 5 (should be 0 after reset)
        read_addr1 = 5'd5;
        #10;
        assert(read_data1 == 32'd0) begin
            $display("Test %0d PASSED: Reset clears registers", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: Reset - Expected: 0, Got: %d", test_num, read_data1);
            failed_tests = failed_tests + 1;
        end
        
        // Test 2: Write to register 1
        test_num = test_num + 1;
        write_enable = 1;
        write_addr = 5'd1;
        write_data = 32'hDEADBEEF;
        #10; // Wait for clock edge
        write_enable = 0;
        #1;  // Small delay for combinational read
        
        read_addr1 = 5'd1;
        #1;
        assert(read_data1 == 32'hDEADBEEF) begin
            $display("Test %0d PASSED: Write and read register 1", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: Write/Read r1 - Expected: DEADBEEF, Got: %h", test_num, read_data1);
            failed_tests = failed_tests + 1;
        end
        
        // Test 3: Write to register 15
        test_num = test_num + 1;
        write_enable = 1;
        write_addr = 5'd15;
        write_data = 32'hCAFEBABE;
        #10;
        write_enable = 0;
        #1;
        
        read_addr1 = 5'd15;
        #1;
        assert(read_data1 == 32'hCAFEBABE) begin
            $display("Test %0d PASSED: Write and read register 15", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: Write/Read r15 - Expected: CAFEBABE, Got: %h", test_num, read_data1);
            failed_tests = failed_tests + 1;
        end
        
        // Test 4: Read two registers simultaneously
        test_num = test_num + 1;
        read_addr1 = 5'd1;
        read_addr2 = 5'd15;
        #1;
        assert(read_data1 == 32'hDEADBEEF && read_data2 == 32'hCAFEBABE) begin
            $display("Test %0d PASSED: Simultaneous dual read", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: Dual Read - Expected: DEADBEEF, CAFEBABE, Got: %h, %h", 
                     test_num, read_data1, read_data2);
            failed_tests = failed_tests + 1;
        end
        
        // // Test 5: Register 0 hardwired to zero (write attempt)
        // test_num = test_num + 1;
        // write_enable = 1;
        // write_addr = 5'd0;
        // write_data = 32'hFFFFFFFF;
        // #10;
        // write_enable = 0;
        // #1;
        
        // read_addr1 = 5'd0;
        // #1;
        // assert(read_data1 == 32'd0) begin
        //     $display("Test %0d PASSED: Register 0 hardwired to zero", test_num);
        //     passed_tests = passed_tests + 1;
        // end else begin
        //     $display("Test %0d FAILED: r0 protection - Expected: 0, Got: %h", test_num, read_data1);
        //     failed_tests = failed_tests + 1;
        // end
        
        // Test 6: Write without write_enable
        test_num = test_num + 1;
        write_enable = 0;  // Disabled
        write_addr = 5'd5;
        write_data = 32'h12345678;
        #10;
        #1;
        
        read_addr1 = 5'd5;
        #1;
        assert(read_data1 == 32'd0) begin  // Should still be 0 from reset
            $display("Test %0d PASSED: Write enable protection", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: Write enable - Expected: 0, Got: %h", test_num, read_data1);
            failed_tests = failed_tests + 1;
        end
        
        // Test 7: Overwrite a register
        test_num = test_num + 1;
        // First write
        write_enable = 1;
        write_addr = 5'd7;
        write_data = 32'h11111111;
        #10;
        // Second write (overwrite)
        write_data = 32'h22222222;
        #10;
        write_enable = 0;
        #1;
        
        read_addr1 = 5'd7;
        #1;
        assert(read_data1 == 32'h22222222) begin
            $display("Test %0d PASSED: Overwrite register", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: Overwrite - Expected: 22222222, Got: %h", test_num, read_data1);
            failed_tests = failed_tests + 1;
        end
        
        // Test 8: Write and read in same cycle (read should get new value)
        test_num = test_num + 1;
        write_enable = 1;
        write_addr = 5'd10;
        write_data = 32'hABCDEF00;
        read_addr1 = 5'd10;
        #10;  // Clock edge writes
        write_enable = 0;
        #1;   // Combinational read happens
        assert(read_data1 == 32'hABCDEF00) begin
            $display("Test %0d PASSED: Write-then-read same cycle", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: Same-cycle write/read - Expected: ABCDEF00, Got: %h", 
                     test_num, read_data1);
            failed_tests = failed_tests + 1;
        end
        
        // Test 9: Multiple sequential writes
        test_num = test_num + 1;
        write_enable = 1;
        for (integer i = 1; i < 10; i = i + 1) begin
            write_addr = i;
            write_data = i * 100;
            #10;
        end
        write_enable = 0;
        #1;
        
        // Verify a few
        read_addr1 = 5'd3;
        read_addr2 = 5'd7;
        #1;
        assert(read_data1 == 32'd300 && read_data2 == 32'd700) begin
            $display("Test %0d PASSED: Sequential writes", test_num);
            passed_tests = passed_tests + 1;
        end else begin
            $display("Test %0d FAILED: Sequential writes - Expected: 300, 700, Got: %d, %d", 
                     test_num, read_data1, read_data2);
            failed_tests = failed_tests + 1;
        end
        
        // Print summary
        #10;
        $display("\n============================");
        $display("Test Summary:");
        $display("  Total Tests: %0d", test_num);
        $display("  Passed: %0d", passed_tests);
        $display("  Failed: %0d", failed_tests);
        
        if (failed_tests == 0) begin
            $display("\n*** ALL TESTS PASSED! ***");
        end else begin
            $display("\n*** SOME TESTS FAILED ***");
        end
        
        $display("============================");
        $finish;
    end

endmodule