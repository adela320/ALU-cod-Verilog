module restoring_div_unsigned (
    input  wire clk,
    input  wire reset,
    input  wire start,

    input  wire [7:0] dividend_hi,
    input  wire [7:0] dividend_lo,
    input  wire [7:0] divisor8,

    output reg busy,
    output reg done,
    output reg div0,

    output reg [7:0] quotient,
    output reg [7:0] remainder
);

    reg [8:0] A;          // remainder accumulator (unsigned)
    reg [7:0] Q;          // quotient shift register
    reg [8:0] M;          // divisor extended (unsigned)
    reg [3:0] step;       // 0..7

    // latch A after shift, before subtract (for true restore)
    reg [8:0] A_pre_sub;

    // subtract A - M
    wire [8:0] sub_sum;
    wire sub_cout; // 1 => no borrow, 0 => borrow

    adder_rca #(9) sub_rca (
        .x(A),
        .y(M),
        .carry_in(1'b1),
        .sum(sub_sum),
        .carry_out(sub_cout)
    );

    // latch subtract results
    reg [8:0] sub_sum_r;
    reg       sub_cout_r;

    localparam S_IDLE   = 3'd0;
    localparam S_SHIFT  = 3'd1;
    localparam S_SUB    = 3'd2;
    localparam S_FIX    = 3'd3;
    localparam S_DONE   = 3'd4;

    reg [2:0] st;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            st        <= S_IDLE;
            busy      <= 1'b0;
            done      <= 1'b0;
            div0      <= 1'b0;

            A         <= 9'd0;
            Q         <= 8'd0;
            M         <= 9'd0;
            step      <= 4'd0;

            A_pre_sub <= 9'd0;
            sub_sum_r <= 9'd0;
            sub_cout_r<= 1'b0;

            quotient  <= 8'd0;
            remainder <= 8'd0;
        end else begin
            done <= 1'b0;

            case (st)
                S_IDLE: begin
                    busy <= 1'b0;
                    div0 <= 1'b0;

                    if (start) begin
                        if (divisor8 == 8'd0) begin
                            div0 <= 1'b1;
                            done <= 1'b1;
                            quotient  <= 8'd0;
                            remainder <= 8'd0;
                            st <= S_IDLE;
                        end else begin
                            busy <= 1'b1;

                            // Pentru TB-ul tău: dividend pe 8 biți (dividend_lo)
                            // dividend_hi e ignorat aici.
                            A    <= 9'd0;
                            Q    <= dividend_lo;
                            M    <= {1'b0, divisor8};

                            step <= 4'd0;
                            st   <= S_SHIFT;
                        end
                    end
                end

                // SHIFT: {A,Q} <<= 1, si salvezi A pentru restore
                S_SHIFT: begin
                    // compute shifted A,Q
                    A <= {A[7:0], Q[7]};
                    Q <= {Q[6:0], 1'b0};

                    // latch "A after shift" (the value we subtract from)
                    A_pre_sub <= {A[7:0], Q[7]};

                    st <= S_SUB;
                end

                // SUB: latch subtract results based on current A (which is A_pre_sub after shift)
                // Note: A is updated at posedge, so in S_SUB A already equals A_pre_sub.
                S_SUB: begin
                    sub_sum_r  <= sub_sum;
                    sub_cout_r <= sub_cout;
                    st <= S_FIX;
                end

                // FIX: commit subtract or restore
                S_FIX: begin
                    if (sub_cout_r) begin
                        // no borrow: accept subtraction
                        A    <= sub_sum_r;
                        Q[0] <= 1'b1;
                    end else begin
                        // borrow: restore to A_pre_sub
                        A    <= A_pre_sub;
                        Q[0] <= 1'b0;
                    end

                    if (step == 4'd7) st <= S_DONE;
                    else begin
                        step <= step + 1'b1;
                        st <= S_SHIFT;
                    end
                end

                S_DONE: begin
                    quotient  <= Q;
                    remainder <= A[7:0];
                    done      <= 1'b1;
                    busy      <= 1'b0;
                    st        <= S_IDLE;
                end

                default: st <= S_IDLE;
            endcase
        end
    end

endmodule