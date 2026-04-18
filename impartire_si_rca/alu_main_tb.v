`timescale 1ns/1ns

module alu_main_tb;
    // Semnale pentru conectarea la DUT (Device Under Test)
    reg clk, reset, start;
    reg [1:0] opcode;
    reg [7:0] A_in, B_in;
    wire [15:0] result;
    wire done, busy, error;

    // Instan?ierea modulului principal ALU
    alu_main dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .opcode(opcode),
        .A_in(A_in),
        .B_in(B_in),
        .result(result),
        .done(done),
        .busy(busy),
        .error(error)
    );

    // Generarea semnalului de ceas (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Task pentru resetarea sistemului
    task do_reset;
        begin
            reset = 1;
            start = 0;
            A_in = 0; B_in = 0; opcode = 0;
            #20 reset = 0;
            @(posedge clk);
        end
    endtask

    // Task pentru rularea unei opera?ii
    task run_op;
        input [1:0] op;
        input [7:0] a;
        input [7:0] b;
        begin
            opcode = op;
            A_in = a;
            B_in = b;
            start = 1;
            @(posedge clk);
            #1 start = 0;
            
            // A?teapt? finalizarea opera?iei
            wait(done == 1'b1);
            
            case (op)
                2'b00: $display("[ADD] %d + %d = %d", a, b, result[8:0]);
                2'b01: $display("[SUB] %d - %d = %d (9-bit signed)", a, b, result[8:0]);
                2'b10: begin
                    if (error) 
                        $display("[DIV] %d / %d => EROARE: DIV0 detected!", a, b);
                    else
                        $display("[DIV] %d / %d => Cat: %d, Rest: %d", a, b, result[15:8], result[7:0]);
                end
            endcase
            @(posedge clk);
        end
    endtask

    // Scenariul de testare
    initial begin
        $display("=== INCEPERE TESTE ALU ===");
        do_reset();

        // Teste Adunare (opcode 00) [cite: 35]
        run_op(2'b00, 8'd10, 8'd5);   // 10 + 5 = 15
        run_op(2'b00, 8'd250, 8'd10); // 250 + 10 = 260 [cite: 36]

        // Teste Scadere (opcode 01) [cite: 34]
        run_op(2'b01, 8'd20, 8'd7);   // 20 - 7 = 13
        run_op(2'b01, 8'd5, 8'd10);   // 5 - 10 = -5 (va afisa valoarea in complement fata de 2)

        // Teste Impartire (opcode 10) [cite: 54-55]
        run_op(2'b10, 8'd100, 8'd7);  // 100 / 7 = 14 R 2
        run_op(2'b10, 8'd7, 8'd4);    // 7 / 4 = 1 R 3
        
        // Test Eroare Impartire la Zero [cite: 56]
        run_op(2'b10, 8'd50, 8'd0);   // Div0 test

        $display("=== TESTE FINALIZATE ===");
        #50 $stop;
    end
endmodule