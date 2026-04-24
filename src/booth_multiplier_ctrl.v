`timescale 1ns/1ns

module booth_multiplier_ctrl (
    input wire clk, reset, start,
    input wire [2:0] triplet,
    input wire [3:0] step,
    output reg c0, c1, c2, c3, c4, c5, c6, c7, c8,
    output reg busy
);
    parameter IDLE=3'd0, INIT=3'd1, CALC=3'd2, SHIFT=3'd3, DONE=3'd4;
    reg [2:0] st, next_st;

    always @(posedge clk or posedge reset) st <= reset ? IDLE : next_st;

    always @(*) begin
        {c0, c1, c2, c3, c4, c5, c6, c7, c8} = 9'b0;
        busy = 1'b1; next_st = st;

        case (st)
            IDLE: begin busy = 0; if (start) next_st = INIT; end
            INIT: begin c0 = 1; c1 = 1; next_st = CALC; end
            CALC: begin
                case (triplet) // selectie operatie
                    3'b001, 3'b010: begin c2 = 1; end               // +M
                    3'b011:         begin c2 = 1; c4 = 1; end       // +2M
                    3'b100:         begin c2 = 1; c3 = 1; c4 = 1; end // -2M
                    3'b101, 3'b110: begin c2 = 1; c3 = 1; end       // -M
                    default:        begin c2 = 0; end               // 0
                endcase
                next_st = SHIFT;
            end
            SHIFT: begin
                c5 = 1; c6 = 1; 
                if (step == 4'd3) next_st = DONE;
                else next_st = CALC;
            end
            DONE: begin c7 = 1; c8 = 1; busy = 0; next_st = IDLE; end
            default: next_st = IDLE;
        endcase
    end
endmodule
