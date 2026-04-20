`timescale 1ns/1ns

//Pentru numere fara semn (Unsigned); folosit la testarea restoring division

module addsub (
    input  wire clk, reset, start, sub,
    input  wire [7:0] a8, b8,
    output reg busy, done,
    output reg [8:0] sum9
);
    
    wire [8:0] a9 = {1'b0, a8}; //Extensie cu 0
    wire [8:0] b9 = {1'b0, b8}; //Extensie cu 0
    wire [8:0] r_sum;
    wire r_cout;

    adder_rca #(9) rca (
        .x(a9), .y(b9), .carry_in(sub), 
        .sum(r_sum), .carry_out(r_cout)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            busy <= 0; done <= 0; sum9 <= 0;
        end else begin
            done <= 0;
            if (start && !busy) begin
                busy <= 1;
                sum9 <= r_sum;
                done <= 1;
                busy <= 0;
            end
        end
    end
endmodule