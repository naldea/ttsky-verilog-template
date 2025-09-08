`timescale 1ns / 1ps

// Aplicación Sistemas Digitales PUC 2025-1 - Naomi Aldea
// ----------------------------
// Semáforo con contador integrado (Verilog-2001 compatible)
// ----------------------------

module tt_um_semaforo (
    input  wire [7:0] ui_in,    // Entradas dedicadas
    output wire [7:0] uo_out,   // Salidas dedicadas
    input  wire [7:0] uio_in,   // IOs (entrada, no usados)
    output wire [7:0] uio_out,  // IOs (salida, no usados)
    output wire [7:0] uio_oe,   // IOs (dirección, no usados)
    input  wire       ena,      // siempre 1 cuando está encendido (ignorar)
    input  wire       clk,      // reloj global
    input  wire       rst_n     // reset global activo en bajo
);

    // =====================
    // Mapeo de señales
    // =====================
    wire rst = ~rst_n;   // convertimos a reset activo en alto
    wire TA  = ui_in[0];
    wire TB  = ui_in[1];
    wire P   = ui_in[2];
    wire R   = ui_in[3];
    // ui_in[7:4] quedan sin usar

    reg [1:0] LA, LB;  // semáforos
    reg on;            // señal de fin de contador
    reg En;            // habilita contador
    reg M;             // modo: normal o desfile
    reg [2:0] state, next_state;

    // =====================
    // Definición de estados
    // =====================
    localparam S0       = 3'd0;
    localparam S1       = 3'd1;
    localparam S2       = 3'd2;
    localparam S3       = 3'd3;
    localparam S_PARADE = 3'd4;

    // =====================
    // Registro de estado
    // =====================
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

    // =====================
    // Registro de modo
    // =====================
    always @(posedge clk or posedge rst) begin
        if (rst)
            M <= 1;   // modo normal
        else if (P)
            M <= 0;   // desfile
        else if (R)
            M <= 1;   // salir desfile
    end

    // =====================
    // Lógica de transición
    // =====================
    always @(*) begin
        next_state = state;
        case (state)
            S0: begin
                if (!TA && M) next_state = S1;
                else if (!M) next_state = S_PARADE;
            end
            S1: if (on) next_state = S2;
            S2: begin
                if (!TB && M) next_state = S3;
                else if (!M) next_state = S_PARADE;
            end
            S3: if (on) next_state = S0;
            S_PARADE: if (R) next_state = S0;
            default: next_state = S0;
        endcase
    end

    // =====================
    // Lógica de salidas
    // =====================
    always @(*) begin
        En = (state == S1 || state == S3); // habilita contador en amarillos
        case (state)
            S0: begin LA=2'b10; LB=2'b00; end
            S1: begin LA=2'b01; LB=2'b00; end
            S2: begin LA=2'b00; LB=2'b10; end
            S3: begin LA=2'b00; LB=2'b01; end
            S_PARADE: begin LA=2'b00; LB=2'b10; end
            default: begin LA=2'b00; LB=2'b00; end
        endcase
    end

    // =====================
    // Contador integrado
    // =====================
    parameter WIDTH = 8;
    parameter VALUE = 20;
    reg [WIDTH-1:0] Q;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Q  <= 0;
            on <= 0;
        end else if (!En) begin
            Q  <= 0;
            on <= 0;
        end else if (Q >= VALUE) begin
            Q  <= VALUE;
            on <= 1;
        end else begin
            Q  <= Q + 1;
            on <= 0;
        end
    end

    // =====================
    // Asignación a salidas TT
    // =====================
    assign uo_out[1:0] = LA;    // LA[1:0]
    assign uo_out[3:2] = LB;    // LB[1:0]
    assign uo_out[4]   = En;    // En
    assign uo_out[5]   = on;    // fin de contador
    assign uo_out[7:6] = 2'b00; // no usados

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

endmodule
