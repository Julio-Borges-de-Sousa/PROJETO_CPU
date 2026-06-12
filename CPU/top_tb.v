
`timescale 1ps/1ps

module top_level_tb;

    reg clk, rst;

    processador dut (
        .clk (clk),
        .rst (rst)
    );

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        #10

        rst = 0;

        forever begin
            clk = ~clk;
            #5;
        end
    end

    initial begin
        $dumpfile("ondas.vcd");
        $dumpvars(0, top_level_tb);

        #10000 $finish;
    end

endmodule