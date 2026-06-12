`timescale 1ps/1ps

module ula(A, B, op, Q);
 
    input [15:0] A;
    input [15:0] B;
    input [3:0] op;
    output reg [15:0] Q;

    wire [15:0] soma = A+B;
    wire [15:0] sub = A-B;
    wire [15:0] mul = A*B;
    wire [15:0] SHR = A >> B;
    wire [15:0] SHL = A << B;
    wire [15:0] AND = (A & B);
    wire [15:0] OR = (A | B);
    wire [15:0] NOT = ~A;
    wire [15:0] XOR = A ^ B; 
    wire GT = (A > B);
    wire IGUAL = (A == B);

    // ROR:
    wire [15:0] ROR;
    wire [15:0] A_AUX;
    wire [15:0] B_AUX;
    wire [15:0] C;
    assign A_AUX = (A >> 1);
    assign B_AUX = (A & 16'd1);
    assign C = (A_AUX & 16'd32767);
    assign ROR = A_AUX | (B_AUX << 16'd15);

    // ROL:
    wire [15:0] ROL;
    wire [15:0] A_AUX2;
    wire [15:0] B_AUX2;
    wire [15:0] C2;
    assign A_AUX2 = (A << 1);
    assign B_AUX2 = (A & 16'd32768);
    assign C2 = (A_AUX2 & 16'd65534);
    assign ROL = A_AUX2 | (B_AUX2 >> 16'd15);

    always @* begin
        Q = 16'd0; 

        case(op)
            0: begin
                Q[0] = GT;
                Q[1] = IGUAL;
                Q[15:2] = 14'd0; 
            end
            4: Q = soma;
            5: Q = sub;
            6: Q = mul;
            7: Q = AND;
            8: Q = OR;
            9: Q = NOT;
            10: Q = XOR;
            11: Q = SHR;
            12: Q = SHL;
            13: Q = ROR;
            14: Q = ROL;
            
            default: Q = 16'd0; 
        endcase
    end

endmodule
// 32767: em 16 bits o MSB é 0 e todos os outros são 1;
