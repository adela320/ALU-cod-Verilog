`timescale 1ns/1ns

module booth_multiplier_tb;
    reg clk, reset, start;
    reg [7:0] A_in, B_in;
    wire [15:0] product;
    wire busy, c7, c8;

    // Conexiuni interne pentru vizualizare
    wire c0, c1, c2, c3, c4, c5, c6;
    wire [2:0] triplet;
    wire [3:0] step;

    booth_multiplier_ctrl ctrl (
        .clk(clk), .reset(reset), .start(start), 
        .triplet(triplet), .step(step), 
        .c0(c0), .c1(c1), .c2(c2), .c3(c3), .c4(c4), 
        .c5(c5), .c6(c6), .c7(c7), .c8(c8), .busy(busy)
    );

    booth_multiplier_datapath dp (
        .clk(clk), .reset(reset), .multiplier(A_in), .multiplicand(B_in),
        .c0(c0), .c1(c1), .c2(c2), .c3(c3), .c4(c4), .c5(c5), .c6(c6),
        .triplet(triplet), .step_out(step), .prod_out(product)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Reset robust
        reset = 1; start = 0; A_in = 0; B_in = 0;
        #50 reset = 0;
        @(posedge clk);

        // TEST 1: 10 * -5 = -50
        A_in = 8'd10; B_in = -8'd5;
        start = 1;
        @(posedge clk);
        start = 0; // Coboram start imediat
        
        // Wait cu timeout pentru a preveni blocarea simularii
        fork : timeout_block
            begin
                wait(c7 == 1'b1);
                $display("[BOOTH SUCCESS] %d * %d = %d", $signed(A_in), $signed(B_in), $signed(product));
                disable timeout_block;
            end
            begin
                #2000;
                $display("[BOOTH ERROR] Simulation Timeout! Check FSM states.");
                $stop;
            end
        join

        #100 $stop;
    end
endmodule