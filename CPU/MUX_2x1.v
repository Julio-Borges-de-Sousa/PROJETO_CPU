module MUX_2x1 (I0, I1, sel, din, sel2, Rm, SPadd, addr);
    input [15:0] I0, I1, Rm, SPadd;
    output reg [15:0] din, addr;
    input sel, sel2;

    always @(*) begin
        case(sel)
            0: din = I0; // din = Rn
            1: din = I1; // din = immed
        endcase
    end

    always @(*) begin
        case(sel2)
            0: addr = Rm; // addr = Rm
            1: addr = SPadd; // addr = (SP+1)
        endcase
    end

endmodule
