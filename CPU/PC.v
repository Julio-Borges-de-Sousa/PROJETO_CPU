module PC(clk, rst, ld, Q, immed);
    input clk, ld, rst;
    input [15:0] immed;
    output [15:0] Q;

    reg [15:0] PC;

    always @(posedge clk) begin
        if(rst) PC <= 0;
        else if(ld) PC <= PC + immed; 
    end

    assign Q = PC;
endmodule

