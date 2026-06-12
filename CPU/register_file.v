`timescale 1ps/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2026 11:42:41
// Design Name: 
// Module Name: register_file
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module register_file #(parameter N=16)(
    input clk, rst, Rd_wr, POP_sel,
    input [2:0] Rd_sel, Rm_sel, Rn_sel,
    input [N-1:0] Rd,
    output [N-1:0] Rm, Rn,
    input [N-1:0] ULA_Q // SP+1
);

    reg [N-1:0] registers [0:7];

    integer i;
    always @(posedge clk) begin
        // 1. Prioridade Absoluta: RESET
        if(rst) begin
            for(i = 0; i < 7; i = i + 1) begin
                registers[i] <= {N{1'b0}}; // Zera apenas de R0 a R6
            end
            registers[7] <= 16'd1023;      // Restaura o SP para o topo da pilha
        end 
        
        // 2. Operação Normal da CPU (Permite gravação paralela)
        else begin
            // Gravação no registrador de destino
            if(Rd_wr) begin
                registers[Rd_sel] <= Rd;
            end
            
            // Atualização do Stack Pointer simultaneamente (ex: num POP)
            if(POP_sel) begin
                registers[7] <= ULA_Q;
            end
        end
    end

    wire [N-1:0] R0, R1, R2, R3, R4, R5, R6, SP;

    assign R0 = registers [0];
    assign R1 = registers [1];
    assign R2 = registers [2];
    assign R3 = registers [3];
    assign R4 = registers [4];
    assign R5 = registers [5];
    assign R6 = registers [6];
    assign SP = registers [7];
    
    assign Rm = registers[Rm_sel];
    assign Rn = registers[Rn_sel];
endmodule

