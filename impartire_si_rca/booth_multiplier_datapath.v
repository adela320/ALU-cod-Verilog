`timescale 1ns/1ns

module booth_multiplier_datapath (
    input wire clk, reset,
    input wire [7:0] multiplier, multiplicand,
    input wire c0, c1, c2, c3, c4, c5, c6,
    output wire [2:0] triplet,
    output wire [3:0] step_out,
    output wire [15:0] prod_out
);
    // Folosim 10 biti pentru A si M pentru a suporta +/- 2M fara overflow
    reg [9:0] A, M; 
    reg [7:0] Q;
    reg q_minus_1;
    reg [3:0] step;

    // Logica combinationala pentru multiplexor si RCA
    // Mux-ul selecteaza intre M  si 2M 
    wire [9:0] mux_m = c4 ? {M[8:0], 1'b0} : M;
    wire [9:0] sum;
    wire cout;

    // RCA-ul pe 10 biti (c3 activeaza scaderea)
    adder_rca #(10) rca_booth (
        .x(A), .y(mux_m), .carry_in(c3), 
        .sum(sum), .carry_out(cout)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            A <= 10'd0; M <= 10'd0; Q <= 8'd0;
            q_minus_1 <= 1'b0; step <= 4'd0;
        end else begin
            if (c0) begin 
                A <= 10'd0; 
                M <= { {2{multiplicand[7]}}, multiplicand };
                q_minus_1 <= 1'b0; 
                step <= 4'd0; 
            end
            if (c1) Q <= multiplier;
            
            if (c2) A <= sum; // incarcare rezultat adunare/scadere

            if (c5) begin 
                // ASR 2: Deplasare la dreapta cu 2 pozitii
                {A, Q, q_minus_1} <= $signed({A, Q, q_minus_1}) >>> 2;
            end
            
            if (c6) step <= step + 1'b1;
        end
    end

    assign triplet = {Q[1:0], q_minus_1};
    assign step_out = step;
    // Rez pe 16 biti din registrele A si Q
    assign prod_out = {A[7:0], Q}; 
endmodule