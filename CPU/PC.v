module PC(clk, rst, ld, Q, immed);
    input clk, ld, rst;
    input [15:0] immed;
    output [15:0] Q;

    reg [15:0] PC;

    initial begin
        PC = 0;
    end

    always @(posedge clk) begin
        if(rst) PC <= 0;
        else if(ld) PC <= PC + 16'd1; // proxima instrção normal;
        else PC <= PC+immed; // JMPs
    end

    assign Q = PC;

endmodule


