`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb_semaforo;

    logic clk, rst, TA, TB, P, R;
    logic [1:0] LA, LB;
    logic on;

    semaforo_maquina uut (
        .clk(clk),
        .rst(rst),
        .TA(TA),
        .TB(TB),
        .P(P),
        .R(R),
        .LA(LA),
        .LB(LB),
        .on(on)
    );

    // Generador de reloj
    initial clk = 0;
    always #5 clk = ~clk;

    // Estímulos
    initial begin
        rst = 1; TA=0; TB=0; P=0; R=0;
        #20 rst=0;

        TA=1; TB=0; #100;
        TA=0; #100;
        TB=1; #100;
        TB=0; #100;

        P=1; #10; P=0; #50;
        R=1; #10; R=0;

        #200 $finish;
    end

    // Dump VCD
    initial begin
        $dumpfile("semaforo.vcd");
        $dumpvars(0, tb_semaforo);
    end

endmodule
