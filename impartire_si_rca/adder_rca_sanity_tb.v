`timescale 1ns/1ns

module adder_rca_sanity_tb;
    reg  [8:0] x, y;
    reg        carry_in;
    wire [8:0] sum;
    wire       carry_out;

    adder_rca #(9) dut (
        .x(x),
        .y(y),
        .carry_in(carry_in),
        .sum(sum),
        .carry_out(carry_out)
    );

    initial begin
        // 7 - 4 = 3
        x = 9'd7; y = 9'd4; carry_in = 1'b1;
        #1;
        $display("7-4 => sum=%0d carry_out=%b (expected 3, cout=1)", sum, carry_out);

        // 3 - 4 = -1 => in 9-bit two's complement = 511, carry_out=0 (borrow)
        x = 9'd3; y = 9'd4; carry_in = 1'b1;
        #1;
        $display("3-4 => sum=%0d carry_out=%b (expected 511, cout=0)", sum, carry_out);

        $stop;
    end
endmodule