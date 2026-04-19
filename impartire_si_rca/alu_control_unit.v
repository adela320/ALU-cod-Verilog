`timescale 1ns/1ns

module alu_control_unit (
    input wire clk, reset, start,
    input wire [1:0] opcode,
    input wire [7:0] divisor_in,
    input wire d_sub_cout,
    input wire [3:0] step,
    input wire [2:0] triplet,
    output reg d_c0, d_c1, d_c2, d_c4, d_c5, d_c6, d_c7, d_c8, d_c9,
    output reg m_c0, m_c1, m_c2, m_c3, m_c4, m_c5, m_c6, m_c7, m_c8,
    output reg add_en, busy, done
);
    parameter IDLE=0, ADD_SUB=1, DIV_INIT=2, DIV_SHIFT=3, DIV_SUB=4, DIV_FIX=5, 
              MUL_INIT=6, MUL_CALC=7, MUL_SHIFT=8, DONE=9;
    reg [3:0] st, next_st;

    always @(posedge clk or posedge reset) st <= reset ? IDLE : next_st;

    always @(*) begin
        {d_c0, d_c1, d_c2, d_c4, d_c5, d_c6, d_c7, d_c8, d_c9} = 9'b0;
        {m_c0, m_c1, m_c2, m_c3, m_c4, m_c5, m_c6, m_c7, m_c8} = 9'b0;
        add_en = 0; busy = 1; done = 0; next_st = st;

        case (st)
            IDLE: begin
                busy = 0;
                if (start) begin
                    if (opcode[1] == 0) next_st = ADD_SUB;
                    else if (opcode == 2'b10) begin
                        if (divisor_in == 8'd0) begin d_c9 = 1'b1; next_st = DONE; end // DIV0
                        else next_st = DIV_INIT;
                    end
                    else next_st = MUL_INIT;
                end
            end

            ADD_SUB: begin add_en = 1'b1; next_st = DONE; end

            // Logica Diviziune
            DIV_INIT: begin d_c0 = 1'b1; next_st = DIV_SHIFT; end
            DIV_SHIFT: begin 
                d_c1 = 1'b1; // Shift
                d_c2 = 1'b1; // Latch pre-sub 
                next_st = DIV_SUB; 
            end
            DIV_SUB: begin d_c4 = 1'b1; next_st = DIV_FIX; end // Latch RCA
            DIV_FIX: begin
                if (d_sub_cout) d_c5 = 1'b1; else d_c6 = 1'b1; // Accept sau Restore
                d_c7 = 1'b1; next_st = (step == 4'd7) ? DONE : DIV_SHIFT;
            end

            // Logica Booth MUL
            MUL_INIT: begin m_c0 = 1'b1; m_c1 = 1'b1; next_st = MUL_CALC; end
            MUL_CALC: begin
                m_c2 = 1'b1;
                case (triplet)
                    3'b001, 3'b010: begin m_c3 = 0; m_c4 = 0; end // +M
                    3'b011:         begin m_c3 = 0; m_c4 = 1; end // +2M
                    3'b100:         begin m_c3 = 1; m_c4 = 1; end // -2M
                    3'b101, 3'b110: begin m_c3 = 1; m_c4 = 0; end // -M
                    default:        begin m_c2 = 0; end
                endcase
                next_st = MUL_SHIFT;
            end
            MUL_SHIFT: begin m_c5 = 1'b1; m_c6 = 1'b1; next_st = (step == 4'd3) ? DONE : MUL_CALC; end
            DONE: begin 
                d_c8 = 1'b1; 
                m_c7 = 1'b1; 
                m_c8 = 1'b1; 
                
                if (opcode == 2'b10 && divisor_in == 8'd0) d_c9 = 1'b1; 
                
                done = 1'b1; 
                busy = 0; 
                next_st = IDLE; 
            end
            default: next_st = IDLE;
        endcase
    end
endmodule