`timescale 1ns/1ns

module addsub_tb;

    reg clk, reset, start, sub;
    reg [7:0] a8, b8;

    wire busy, done;
    wire [8:0] sum9;

    addsub dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .sub(sub),
        .a8(a8),
        .b8(b8),
        .busy(busy),
        .done(done),
        .sum9(sum9)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task do_reset;
        begin
            reset = 1;
            start = 0;
            sub = 0;
            a8 = 0;
            b8 = 0;
            @(posedge clk); #1;
            reset = 0;
            @(posedge clk); #1;
        end
    endtask

    task run_addsub;
        input do_sub;
        input [7:0] a;
        input [7:0] b;
        input [8:0] expected;
        begin
            sub = do_sub;
            a8  = a;
            b8  = b;

            start = 1;
            @(posedge clk); #1;
            start = 0;

            wait (done == 1'b1);
            #1;

            if (sum9 === expected)
                $display("PASS %s: a=%0d b=%0d => sum9=%0d",
                         do_sub ? "SUB" : "ADD", a, b, sum9);
            else
                $display("FAIL %s: a=%0d b=%0d => got %0d expected %0d",
                         do_sub ? "SUB" : "ADD", a, b, sum9, expected);

            @(posedge clk); #1;
        end
    endtask

    initial begin
        $display("=== addsub TB START ===");
        do_reset();

        // 7 - 4 = 3
        run_addsub(1'b1, 8'd7, 8'd4, 9'd3);

        // 7 + 4 = 11
        run_addsub(1'b0, 8'd7, 8'd4, 9'd11);

        // 250 + 10 = 260 (9-bit)
        run_addsub(1'b0, 8'd250, 8'd10, 9'd260);

        $display("=== addsub TB DONE ===");
        #20 $stop;
    end

endmodule