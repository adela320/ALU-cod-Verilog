`timescale 1ns/1ns

module restoring_div_unsigned_tb;

    reg clk, reset, start;
    reg [7:0] dividend_hi, dividend_lo, divisor8;

    wire busy, done, div0;
    wire [7:0] quotient, remainder;

    restoring_div_unsigned dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .dividend_hi(dividend_hi),
        .dividend_lo(dividend_lo),
        .divisor8(divisor8),
        .busy(busy),
        .done(done),
        .div0(div0),
        .quotient(quotient),
        .remainder(remainder)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task do_reset;
        begin
            reset = 1;
            start = 0;
            dividend_hi = 0;
            dividend_lo = 0;
            divisor8 = 0;
            @(posedge clk); #1;
            reset = 0;
            @(posedge clk); #1;
        end
    endtask

    task run_div;
        input [15:0] dividend16;
        input [7:0]  div8;
        input [7:0]  exp_q;
        input [7:0]  exp_r;
        begin
            dividend_hi = dividend16[15:8];
            dividend_lo = dividend16[7:0];
            divisor8    = div8;

            start = 1;
            @(posedge clk); #1;
            start = 0;

            // done
            wait (done == 1'b1);
            #1;

            if (div8 == 0) begin
                if (div0 === 1'b1)
                    $display("PASS DIV0: %0d / 0 => div0=1 (q=%0d r=%0d)", dividend16, quotient, remainder);
                else
                    $display("FAIL DIV0: %0d / 0 => div0=0 (q=%0d r=%0d)", dividend16, quotient, remainder);
            end else begin
                if (div0 !== 1'b0)
                    $display("FAIL DIV: %0d / %0d => div0 should be 0, got 1", dividend16, div8);
                else if (quotient === exp_q && remainder === exp_r)
                    $display("PASS DIV: %0d / %0d => q=%0d r=%0d", dividend16, div8, quotient, remainder);
                else
                    $display("FAIL DIV: %0d / %0d => got q=%0d r=%0d expected q=%0d r=%0d",
                             dividend16, div8, quotient, remainder, exp_q, exp_r);
            end

            // un ciclu între teste
            @(posedge clk); #1;
        end
    endtask

    initial begin
        $display("=== restoring_div_unsigned TB START ===");
        do_reset();

        // 7 / 4 = 1 r 3
        run_div(16'd7, 8'd4, 8'd1, 8'd3);

        // 100 / 7 = 14 r 2
        run_div(16'd100, 8'd7, 8'd14, 8'd2);

        // 7 / 0 => div0=1, q=r=0
        run_div(16'd7, 8'd0, 8'd0, 8'd0);

        $display("=== restoring_div_unsigned TB DONE ===");
        #20 $stop;
    end

endmodule