`timescale 1ns/1ns

module alu_main (
    input wire clk, reset, start,
    input wire [1:0] opcode,
    input wire [7:0] A, B,
    output wire [15:0] result,
    output wire done, busy, error
);
    wire d_c0, d_c1, d_c2, d_c4, d_c5, d_c6, d_c7, d_c8, d_c9;
    wire m_c0, m_c1, m_c2, m_c3, m_c4, m_c5, m_c6, m_c7, m_c8;
    wire d_cout, add_en; wire [3:0] step; wire [2:0] triplet;

    alu_control_unit ctrl (
        .clk(clk), .reset(reset), .start(start), .opcode(opcode), .divisor_in(B),
        .d_sub_cout(d_cout), .step(step), .triplet(triplet),
        .d_c0(d_c0), .d_c1(d_c1), .d_c2(d_c2), .d_c4(d_c4), .d_c5(d_c5), .d_c6(d_c6), .d_c7(d_c7), .d_c8(d_c8), .d_c9(d_c9),
        .m_c0(m_c0), .m_c1(m_c1), .m_c2(m_c2), .m_c3(m_c3), .m_c4(m_c4), .m_c5(m_c5), .m_c6(m_c6), .m_c7(m_c7), .m_c8(m_c8),
        .add_en(add_en), .busy(busy), .done(done)
    );

    alu_datapath dp (
        .clk(clk), .reset(reset), .opcode(opcode), .A_in(A), .B_in(B),
        .d_c0(d_c0), .d_c1(d_c1), .d_c2(d_c2), .d_c4(d_c4), .d_c5(d_c5), .d_c6(d_c6), .d_c7(d_c7),
        .m_c0(m_c0), .m_c1(m_c1), .m_c2(m_c2), .m_c3(m_c3), .m_c4(m_c4), .m_c5(m_c5), .m_c6(m_c6),
        .add_en(add_en), .d_sub_cout(d_cout), .step_out(step), .triplet_out(triplet), .result_out(result)
    );

    assign error = d_c9;
endmodule