`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb_semaforo;

    logic clk, rst;
    logic TA, TB, P, R;
    wire [1:0] LA, LB;
    wire on;

    // Instancia del DUT (Device Under Test)
    tt_um_semaforo uut (
        .ui_in  ({4'b0000, R, P, TB, TA}), // mapeo: [3]=R, [2]=P, [1]=TB, [0]=TA
        .uo_out (),                        // conectaremos abajo con LA, LB, on
        .uio_in (8'b0),
        .uio_out(),
        .uio_oe (),
        .ena    (1'b1),    // enable siempre activo
        .clk    (clk),
        .rst_n  (~rst)
    );

    // Extraemos las señales desde uo_out
    wire [7:0] uo_out = uut.uo_out;
    assign LA = uo_out[1:0];
    assign LB = uo_out[3:2];
    assign on = uo_out[4];

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