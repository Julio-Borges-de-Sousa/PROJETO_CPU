module ROM (addr, dout);
    input [15:0] addr;
    output [15:0] dout;

    reg [15:0] ROM [0:1024];

    initial begin
        ROM[0] = 16'H1800;
        ROM[1] = 16'H1901;
        ROM[2] = 16'H1A00;
        ROM[3] = 16'H1B00;
        ROM[4] = 16'HF001;
        ROM[5] = 16'H0007;
        ROM[6] = 16'H0823;
        ROM[7] = 16'H0805;
        ROM[8] = 16'H0FEC;
        ROM[9] = 16'HF042;
        ROM[10] = 16'H4244;
        ROM[11] = 16'HF001;
        ROM[12] = 16'H000F;
        ROM[13] = 16'H0FF7;
        ROM[14] = 16'H0FD4;
        ROM[15] = 16'H1A00;
        ROM[16] = 16'HF042;
        ROM[17] = 16'H0FC8;
    end

    assign dout = ROM[addr];

endmodule


/*

ROM[0] = 16'H1807;
ROM[1] = 16'H1908;
ROM[2] = 16'H0007;
ROM[3] = 16'H080A;
ROM[4] = 16'H1B05;
ROM[5] = 16'H1C07;


*/