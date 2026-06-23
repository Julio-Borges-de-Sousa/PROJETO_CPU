`timescale 1ns/1ps

module uart_tx (
    input  wire clk,
    input  wire rst,
    input  wire tx_start,       // Gatilho (1 pulso de clock = envia)
    input  wire [7:0] tx_data,  // Byte a ser transmitido (Ex: 8'h41 = 'A')
    output reg  tx_pin         // Fio conectado ao pino físico do módulo TTL
);

    // Divisor de Frequência (1085 ciclos para 115200 bps)
    localparam BAUD_LIMIT = 11'd1084; // Conta de 0 até 1084 (1085 ciclos totais)
    reg [10:0] baud_counter;
    wire baud_tick = (baud_counter == BAUD_LIMIT);

    // Estados da Máquina
    localparam IDLE  = 2'd0,
               START = 2'd1,
               DATA  = 2'd2,
               STOP  = 2'd3;

    reg [1:0] state;
    reg [2:0] bit_idx;
    reg [7:0] shift_reg;

    // Temporizador. Para mudar de estados tem que baud_tick=1
    always @(posedge clk) begin
        if (rst || state == IDLE)
            baud_counter <= 0;
        else if (baud_tick)
            baud_counter <= 0;
        else
            baud_counter <= baud_counter + 1;
    end

    // FSM de Transmissão
    always @(posedge clk) begin
        if (rst) begin
            state    <= IDLE;
            tx_pin   <= 1'b1; // idle
            bit_idx  <= 3'd0;
        end else begin
            case (state)
                IDLE: begin
                    tx_pin   <= 1'b1;
                    if (tx_start) begin
                        shift_reg <= tx_data; // salva o dado que chegou da uart. (nao enviar dados sem delay)
                        state     <= START;
                    end
                end

                START: begin
                    tx_pin <= 1'b0; // Start Bit
                    if (baud_tick) state <= DATA;
                end

                DATA: begin
                    tx_pin <= shift_reg[bit_idx];
                    if (baud_tick) begin
                        if (bit_idx == 3'd7) begin
                            bit_idx <= 0;
                            state   <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end
                end

                STOP: begin
                    tx_pin <= 1'b1; // Stop Bit
                    if (baud_tick) begin
                        state    <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
