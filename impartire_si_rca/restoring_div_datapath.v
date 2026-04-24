`timescale 1ns/1ns
module restoring_div_datapath (
    input wire clk, reset,
    input wire [7:0] dividend, divisor,
    input wire c0, c1, c2, c4, c5, c6, c7,
    output wire sub_cout_r,
    output wire [3:0] step_out,
    output wire [7:0] q_out, r_out
);
    reg [8:0] A, M, A_pre_sub, sub_sum_r;
    reg [7:0] Q;
    reg [3:0] step;
    reg cout_r;

    // Instantiere RCA pentru scadere 
    wire [8:0] s_sum;
    wire s_cout;
    adder_rca #(9) rca_inst (.x(A), .y(M), .carry_in(1'b1), .sum(s_sum), .carry_out(s_cout));

    always @(posedge clk) begin
        if (c0) begin A <= 9'd0; Q <= dividend; M <= {1'b0, divisor}; step <= 0; end 
        if (c1) begin A <= {A[7:0], Q[7]}; Q <= {Q[6:0], 1'b0}; end // shift 
        if (c2) A_pre_sub <= {A[7:0], Q[7]}; // latch pre-sub 
        if (c4) begin sub_sum_r <= s_sum; cout_r <= s_cout; end 
        if (c5) begin A <= sub_sum_r; Q[0] <= 1'b1; end // accept sub 
        if (c6) begin A <= A_pre_sub; Q[0] <= 1'b0; end // restore 
        if (c7) step <= step + 1'b1; // next step 
    end

    assign sub_cout_r = cout_r;
    assign step_out = step;
    assign q_out = Q;
    assign r_out = A[7:0];
endmodule
