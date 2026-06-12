`timescale 1ps/1ps

module datapath #(parameter N=16)(
    input clk, rst, CPSR_Write_Enable,
    input [3:0] ula_op,
    input [2:0] Rd_sel, Rm_sel, Rn_sel,
    input [N-1:0] dout,
    input [N-1:0] immed,
    input Rd_wr,          // 1 bit: habilita escrita no register file
    input [1:0] RF_sel,    // 2 bits: seleciona entre 4 entradas do mux
    output [N-1:0] saida_da_ula,
    output [N-1:0] RM, RN,
    output reg[1:0] CPSR,
    input ULA_B_sel,
    input POP_sel
);

    wire [N-1:0] Rm, Rn;        // saídas do register file
    wire [N-1:0] ula_result;    // saída da ULA
    wire [N-1:0] D_BUS;         // saída do mux → entrada Rd do register file

    wire [N-1:0] B;

    mux_4x1 #(.N(N)) mux_Rm (
        .I0(Rm),
        .I1(dout),
        .I2(immed),
        .I3(ula_result),
        .sel(RF_sel),
        .Q(D_BUS)
    );

    register_file #(.N(N)) reg_file (
        .clk(clk),
        .rst(rst),
        .Rd_wr(Rd_wr),
        .Rd_sel(Rd_sel),
        .Rm_sel(Rm_sel),
        .Rn_sel(Rn_sel),
        .Rd(D_BUS),
        .Rm(Rm),
        .Rn(Rn),
        .POP_sel (POP_sel),
        .ULA_Q (ula_result)
    );

    assign B = (Rn & {16{ULA_B_sel}}) | (immed & ~{16{ULA_B_sel}});

    ula inst_ula (
        .A(Rm),
        .B(B),
        .op(ula_op),
        .Q(ula_result)
    );

    assign saida_da_ula = ula_result;
    assign RM = Rm;
    assign RN = Rn;

    always @(posedge clk) begin
        
        if (rst == 1'b1) begin
            CPSR <= 0; 
        end
        
        else if (CPSR_Write_Enable == 1'b1) begin
            CPSR <= ula_result[1:0];
        end
        
    end

endmodule


