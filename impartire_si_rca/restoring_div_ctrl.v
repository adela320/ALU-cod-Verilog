`timescale 1ns/1ns

module restoring_div_ctrl (
    input wire clk, reset, start,
    input wire [7:0] divisor,
    input wire sub_cout_r,
    input wire [3:0] step,
    output reg c0, c1, c2, c4, c5, c6, c7, c8, c9,
    output reg busy
);
    // def starile
    parameter IDLE  = 3'd0;
    parameter SHIFT = 3'd1;
    parameter SUB   = 3'd2;
    parameter FIX   = 3'd3;
    parameter DONE  = 3'd4;

    reg [2:0] st, next_st;

    // registrul de stare
    always @(posedge clk or posedge reset) begin
        if (reset) st <= IDLE;
        else st <= next_st;
    end

    // Logica de control (Combinational)
    always @(*) begin
        c0=0; c1=0; c2=0; c4=0; c5=0; c6=0; c7=0; c8=0; c9=0;
        busy = 1'b1;
        next_st = st;

        case (st)
            IDLE: begin
                busy = 1'b0;
                if (start) begin
                    if (divisor == 8'd0) begin
                        next_st = DONE;
                        c9 = 1'b1; // Eroare DIV0 
                    end else begin
                        next_st = SHIFT;
                        c0 = 1'b1; // Initializare
                    end
                end
            end

            SHIFT: begin
                c1 = 1'b1;  
                c2 = 1'b1; 
                next_st = SUB;
            end

            SUB: begin
                c4 = 1'b1;  
                next_st = FIX;
            end

            FIX: begin
                if (sub_cout_r) c5 = 1'b1; // accepta scaderea 
                else            c6 = 1'b1; // Restaurare 
                c7 = 1'b1; // increment step (cnt)
                
                if (step == 4'd7) next_st = DONE;
                else              next_st = SHIFT;
            end

            DONE: begin
                c8 = 1'b1; // finalizare 
                busy = 1'b0;
                if (divisor == 8'd0) c9 = 1'b1; 
                next_st = IDLE;
            end

            default: next_st = IDLE;
        endcase
    end
endmodule