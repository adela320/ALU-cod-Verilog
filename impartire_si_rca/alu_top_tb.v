`timescale 1ns/1ns

module alu_top_tb;
    reg clk, reset, start;
    reg [1:0] opcode;
    reg [7:0] A, B;
    wire [15:0] result;
    wire done, busy, error;

    alu_main dut (clk, reset, start, opcode, A, B, result, done, busy, error);

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1; start = 0; #50 reset = 0;

        // Test ADD: 10 + 5 = 15
        A = 10; B = 5; opcode = 2'b00; start = 1; #10 start = 0;
        wait(done); $display("ADD: %d + %d = %d", A, B, result[8:0]);

        // Testt DIV: 100 / 7 = 14 R 2
        #50; A = 100; B = 7; opcode = 2'b10; start = 1; #10 start = 0;
        wait(done); $display("DIV: %d / %d = Q:%d R:%d", A, B, result[15:8], result[7:0]);

        // Test BOOTH: 10 * -5 = -50
        #50; A = 10; B = -5; opcode = 2'b11; start = 1; #10 start = 0;
        wait(done); $display("BOOTH: %d * %d = %d", $signed(A), $signed(B), $signed(result));
        
        // Test DIV: 100 / 0 = EROARE
        #50; 
        A = 100; B = 0; opcode = 2'b10; start = 1; #10 start = 0;
        wait(done);
        
        if (error) 
            $display("DIV %d / %d = EROARE: DIV0 detectat!", A, B);
        else 
            $display("DIV %d / %d = Q:%d R:%d", A, B, result[15:8], result[7:0]);

        #100 $stop;
    end
endmodule