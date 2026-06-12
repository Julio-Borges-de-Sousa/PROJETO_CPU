module RAM (
    input clk,
    input we,                  // Write Enable
    input [15:0] addr,         // Endereço
    input [15:0] din,          // Dado de entrada (para gravar)
    output [15:0] dout         // Dado de saída (para ler)
);

    reg [15:0] memoria [0:1023]; 

    always @(posedge clk) begin
        if (we == 1'b1) begin
            memoria[addr] <= din;
        end
    end

    assign dout = memoria[addr];

endmodule

