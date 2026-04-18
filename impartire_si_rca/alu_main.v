`timescale 1ns/1ns

module alu_main (
    input wire clk, reset, start,
    input wire [1:0] opcode, 
    input wire [7:0] A_in, B_in,
    output reg [15:0] result,
    output reg done, busy, error
);
    wire [8:0] as_sum; 
    wire as_done, as_busy;
    
    // Conectare corecta la portul busy
    addsub as_inst (
        .clk(clk), .reset(reset), .start(start && opcode[1]==0), 
        .sub(opcode[0]), .a8(A_in), .b8(B_in), 
        .sum9(as_sum), .done(as_done), .busy(as_busy)
    );

    wire c0, c1, c2, c4, c5, c6, c7, c8, c9, d_busy, d_cout;
    wire [3:0] d_step; wire [7:0] d_q, d_r;
    
    restoring_div_ctrl ctrl (
        .clk(clk), .reset(reset), .start(start && opcode==2'b10), 
        .divisor(B_in), .sub_cout_r(d_cout), .step(d_step), 
        .c0(c0), .c1(c1), .c2(c2), .c4(c4), .c5(c5), .c6(c6), 
        .c7(c7), .c8(c8), .c9(c9), .busy(d_busy)
    );

    restoring_div_datapath dp (
        .clk(clk), .reset(reset), .dividend(A_in), .divisor(B_in),
        .c0(c0), .c1(c1), .c2(c2), .c4(c4), .c5(c5), .c6(c6), .c7(c7),
        .sub_cout_r(d_cout), .step_out(d_step), .q_out(d_q), .r_out(d_r)
    );

    always @(*) begin
        case (opcode)
            2'b00, 2'b01: begin 
                result = {7'd0, as_sum}; 
                done = as_done; 
                busy = as_busy; 
                error = 1'b0; 
            end
            2'b10: begin 
                result = {d_q, d_r}; 
                done = c8; 
                busy = d_busy; 
                error = c9; 
            end
            default: begin result = 16'd0; done = 1'b0; busy = 1'b0; error = 1'b0; end
        endcase
    end
endmodule