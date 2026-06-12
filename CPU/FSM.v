`timescale 1ps/1ps

module FSM(IR_data, immed, Rf_sel, Rd_sel, Rd_wr, Rm_sel, Rn_sel, LED_sel, read, ula_op, ld, LED_ON, CPSR_Write_Enable,CPSR, RAM_sel, RAM_sel_addr, RAM_we, ULA_B_sel, POP_sel);
    input [15:0] IR_data;
    input [1:0] CPSR;
    input [3:0] read;
    output reg [15:0] immed;
    output reg [3:0] ula_op;
    output reg [1:0] Rf_sel;
    output reg Rd_wr, LED_ON, LED_sel;
    output reg [2:0] Rd_sel, Rm_sel, Rn_sel;
    output reg ld, CPSR_Write_Enable;
    output reg RAM_sel, RAM_we, ULA_B_sel, RAM_sel_addr;
    output reg POP_sel;

    wire [3:0] OPCODE;
    wire OPCODE_TYPE;
    wire [2:0] Rd, Rm, Rn;
    wire [15:0] immed_de_8bits, immed_de_5bits, immed_de_9bits, immed_de_8bits_dividido, help;

    wire [7:0] immed_de_8bits_dividido2;
    assign help[7:5] = IR_data[10:8];
    assign help[4:0] = IR_data[4:0];

    assign OPCODE = IR_data[15:12];
    assign OPCODE_TYPE = IR_data[11];
    assign Rd = IR_data[10:8];
    assign Rm = IR_data[7:5];
    assign Rn = IR_data[4:2];
    
    assign immed_de_8bits = (IR_data & 16'd255 & (~{16{IR_data[7]}})) | ( ( (IR_data & 16'd255) | 16'd65280 ) & ({16{IR_data[7]}}) );
    assign immed_de_5bits = {11'd0, IR_data[4:0]};
    assign immed_de_9bits = ( (IR_data>>2) & 16'd511 & (~{16{IR_data[8]}})) | ( ( ((IR_data>>2) & 16'd511) | 16'd65024 ) & ({16{IR_data[8]}}) );
    assign immed_de_8bits_dividido = ( help & 16'd255 & (~{16{help[7]}})) | ( ( ( help & 16'd255) | 16'd65280 ) & ({16{help[7]}}) );
    assign immed_de_8bits_dividido2[7:5] = IR_data[10:8];
    assign immed_de_8bits_dividido2[4:0] = IR_data[4:0];

    initial begin
        ld = 1;
    end
    
    always @* begin

        Rd_wr = 0;
        ula_op = 0;
        Rf_sel = 0;
        Rd_sel = 0;
        Rm_sel = 0;
        Rn_sel = 0;
        immed = 0;
        RAM_we = 0;
        POP_sel = 0;
        ld = 1;
        RAM_sel = 0;
        RAM_sel_addr = 0;
        ULA_B_sel = 1;
        CPSR_Write_Enable = 0;
        LED_ON = 0;
        LED_sel = 0;

        if( ( (IR_data[15:12] >= 4) && (IR_data[15:12] <= 14) ) )begin  // EXE_ULA

            Rd_wr = 1;
            ula_op = IR_data[15:12];
            Rf_sel = 3;
            Rd_sel = Rd;
            Rm_sel = Rm;
            Rn_sel = Rn;
            immed = immed_de_5bits;
            RAM_we = 0;
            POP_sel = 0;

            if((IR_data[15:12] == 11) || (IR_data[15:12] == 12)) ULA_B_sel = 0;
            else ULA_B_sel = 1;

        end else if( (IR_data[15:11] == 0) && (IR_data[1:0] == 3) ) begin // CMP

            Rm_sel = Rm;
            Rn_sel = Rn;
            ula_op = 0;
            CPSR_Write_Enable = 1;
            RAM_we = 0;
            Rd_wr = 0;
            POP_sel = 0;
            ULA_B_sel = 1;

        end else if(IR_data == 0) begin // NOP

            Rd_wr = 0;
            ula_op = 0;
            Rf_sel = 0;
            Rd_sel = 0;
            Rm_sel = 0;
            Rn_sel = 0;
            immed = 0;
            RAM_we = 0;
            POP_sel = 0;

        end else begin

            case(OPCODE)

                0: begin 

                    case(OPCODE_TYPE)

                        0: begin
                            
                            if(IR_data[1:0] == 1) begin // PUSH Rn, R7 == SP
                                // STR[R7], Rn
                                Rm_sel = 7;
                                Rn_sel = Rn;
                                RAM_we = 1;
                                RAM_sel = 0;
                                RAM_sel_addr = 0;

                                // SUB R7, R7, #1
                                Rf_sel = 3;
                                Rd_wr = 1;
                                ula_op = 5;
                                Rd_sel = 7;
                                immed = 1;
                                ULA_B_sel = 0;
                                POP_sel = 0;
                            end else if (IR_data[1:0] == 2) begin // POP Rn, R7 == SP

                                // LDR Rd, [ (R7+1) ]
                                RAM_sel_addr = 1;
                                ula_op = 4;
                                POP_sel = 1;
                                Rf_sel = 1;
                                Rd_wr = 1;
                                Rd_sel = Rd;
                                immed = 1;
                                ULA_B_sel = 0;
                                Rm_sel = 7;

                            end

                        end

                        1: begin
                            POP_sel = 0;
                            
                            if(IR_data[1:0] == 0) begin 
                                immed = immed_de_9bits; // JMP 
                                Rd_wr = 0;
                                RAM_we = 0;
                                ld = 0;
                            end
                            else if ( (IR_data[1:0] == 1) && (CPSR[1:0] == 2) ) begin 
                                immed = immed_de_9bits; // JEQ 
                                Rd_wr = 0;
                                RAM_we = 0;
                                ld = 0;
                            end
                            else if ( (IR_data[1:0] == 2) && (CPSR[1:0] == 0) ) begin 
                                immed = immed_de_9bits; // JLT
                                Rd_wr = 0;
                                RAM_we = 0;
                                ld = 0;
                            end 
                            else if ( (IR_data[1:0] == 3) && (CPSR[1:0] == 1) ) begin 
                                immed = immed_de_9bits; // JGT
                                Rd_wr = 0;
                                RAM_we = 0;
                                ld = 0;
                            end
                        end

                    endcase
                end

                1: begin // MOV

                    Rd_wr = 1;
                    Rd_sel = Rd;
                    POP_sel = 0;
                    RAM_we = 0;

                    case(OPCODE_TYPE) 
                        0:begin // MOV Rd, Rm
                            Rm_sel = Rm;
                            Rf_sel = 0;
                        end

                        1:begin // MOV Rd, #immed
                            Rf_sel = 2; 
                            immed = immed_de_8bits;
                        end

                    endcase
                end

                2: begin // STR
                    Rd_wr = 0;
                    Rm_sel = Rm;
                    Rn_sel = Rn;
                    RAM_we = 1;
                    RAM_sel_addr = 0;
                    POP_sel = 0;

                    case(OPCODE_TYPE) 
                        0:begin // STR [Rm], Rn
                            RAM_sel = 0;
                        end

                        1:begin // STR [Rm], #immed
                        
                            immed = immed_de_8bits_dividido;
                            RAM_sel = 1;
                        end
                    endcase

                end

                3:begin 
                    //LDR Rd, [Rm]
                    Rd_wr = 1;
                    RAM_we = 0;
                    Rf_sel = 1;
                    Rd_sel = Rd; // já esta recebendo de dout
                    Rm_sel = Rm;
                    RAM_sel_addr = 0;
                    POP_sel = 0;

                end

                15: begin 

                    if( (OPCODE_TYPE == 0) && (IR_data[1:0] == 2)) begin // OUT Rm
                        Rm_sel = Rm;
                        LED_ON = 1;
                        LED_sel = 1;
                    end
                    else if(OPCODE_TYPE == 1)begin // OUT immed
                        immed = immed_de_8bits_dividido2;
                        LED_ON = 1;
                        LED_sel = 0;
                    end
                    else if((OPCODE_TYPE == 0) && (IR_data[1:0] == 1)) begin // IN Rd
                        Rd_wr = 1;
                        Rd_sel = Rd;
                        POP_sel = 0;
                        RAM_we = 0;
                        Rf_sel = 2; 
                        immed = {12'd0, read};
                    end

                end

                default: begin
                    Rd_wr = 0;
                    ula_op = 0;
                    Rf_sel = 0;
                    Rd_sel = 0;
                    Rm_sel = 0;
                    Rn_sel = 0;
                    immed = 0;
                    RAM_we = 0;
                    POP_sel = 0;               
                end

            endcase
        end

    end

endmodule

// 0 menor
// 1 maior
// 2 igual
/*



*/