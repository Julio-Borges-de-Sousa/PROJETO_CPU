`timescale 1ps/1ps

module mux_4x1 #(parameter N = 16) (
    input [N-1:0] I0,
    input [N-1:0] I1,
    input [N-1:0] I2,
    input [N-1:0] I3,
    input [1:0] sel,     
    output reg [N-1:0] Q
);

always @(*) begin
  case(sel)
    2'b00: Q = I0; // Rm
    2'b01: Q = I1; // dout
    2'b10: Q = I2; // immed
    2'b11: Q = I3; // Saida da ULA
  endcase
end   

endmodule
