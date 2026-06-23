module IR (
    input clk,
    input rst,
    input IR_load,
    input [15:0] D,
    output reg [15:0] Q
);

    always @(posedge clk) begin
        if(rst)begin
            Q <= 0;
        end else if(IR_load) Q <= D;
    end
    
endmodule