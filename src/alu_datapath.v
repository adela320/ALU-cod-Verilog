`timescale 1ns/1ns

module alu_datapath (
    input wire clk, reset,
    input wire [1:0] opcode,
    input wire [7:0] A_in, B_in,
    input wire d_c0, d_c1, d_c2, d_c4, d_c5, d_c6, d_c7,
    input wire m_c0, m_c1, m_c2, m_c3, m_c4, m_c5, m_c6,
    input wire add_en,
    output wire d_sub_cout,
    output wire [3:0] step_out,
    output wire [2:0] triplet_out,
    output wire [15:0] result_out
);
    // Registre pe 9 biti conform schemei tale
    reg [8:0] A, M, A_pre_sub, sub_sum_r;
    reg [7:0] Q;
    reg q_minus_1, cout_r;
    reg [3:0] step;

    // RCA pe 9 biti
    wire [8:0] rca_sum;
    wire rca_cout;
    reg  [8:0] rca_y;
    reg        rca_cin;

    adder_rca #(9) rca_inst (
        .x(A), .y(rca_y), .carry_in(rca_cin), 
        .sum(rca_sum), .carry_out(rca_cout)
    );

    // Selectie operanzi
    always @(*) begin
        rca_y = 9'd0; rca_cin = 1'b0;
        case (opcode)
            2'b00, 2'b01: begin rca_y = {1'b0, B_in}; rca_cin = opcode[0]; end // add/sub
            2'b10:        begin rca_y = M; rca_cin = 1'b1; end                // DIV (A-M)
            2'b11: begin // Booth Radix-4
                rca_cin = m_c3; // m_c3 activeaza scaderea in RCA
                rca_y = m_c4 ? {M[7:0], 1'b0} : M; // c4 alege intre M si 2M
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin A<=0; Q<=0; M<=0; q_minus_1<=0; step<=0; end
        else begin
            // Initializari
            if (d_c0) begin A<=9'd0; Q<=A_in; M<={1'b0, B_in}; step<=0; end
            if (m_c0) begin A<=9'd0; M<={B_in[7], B_in}; q_minus_1<=0; step<=0; end
            if (m_c1) Q<=A_in;
            if (opcode[1] == 0 && !add_en) begin A<={1'b0, A_in}; Q<=0; end

            // Shiftari
            if (d_c1) begin A <= {A[7:0], Q[7]}; Q <= {Q[6:0], 1'b0}; end 
            if (m_c5) {A, Q, q_minus_1} <= $signed({A, Q, q_minus_1}) >>> 2; 

            // Division
            if (d_c2) A_pre_sub <= {A[7:0], Q[7]};
            if (d_c4) begin sub_sum_r <= rca_sum; cout_r <= rca_cout; end 
            if (d_c5) begin A <= sub_sum_r; Q[0] <= 1'b1; end // Accept
            if (d_c6) begin A <= A_pre_sub; Q[0] <= 1'b0; end // Restore

            // Operatii add/sub/mul
            if (add_en || m_c2) A <= rca_sum;
            
            if (d_c7 || m_c6) step <= step + 1'b1;
        end
    end

    assign d_sub_cout = cout_r;
    assign step_out = step;
    assign triplet_out = {Q[1:0], q_minus_1};

    // Rezultat Final
    assign result_out = (opcode == 2'b10) ? {Q, A[7:0]} : // DIV: Q, R
                        (opcode == 2'b11) ? {A[7:0], Q} : // MUL: 16-bit
                                            {7'd0, A[8:0]}; // ADD/SUB
endmodule