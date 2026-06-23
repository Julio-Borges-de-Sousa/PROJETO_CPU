`timescale 1ps/1ps

module FSM #(parameter N=16)(
    input                clk,
    input                rst,
    input       [N-1:0]  IR_data,
    input       [1:0]    CPSR,
    input       [3:0]    read,
    output reg           LED_ON, 
    output reg           LED_sel,
    output reg           CPSR_Write_Enable,
    output reg           PC_inc,
    output reg           IR_load,
    output reg  [N-1:0]  Immed,
    output reg           RAM_sel,
    output reg           RAM_we,
    output reg           RAM_sel_addr,
    output reg  [1:0]    RF_sel,
    output reg  [2:0]    Rd_sel,
    output reg           Rd_wr ,
    output reg  [2:0]    Rm_sel,
    output reg  [2:0]    Rn_sel,
    output reg  [3:0]    ula_op,
    output reg           ULA_B_sel,
    output reg           POP_sel
    );


localparam  init        = 4'd0,
            fetch       = 4'd1,
            decode      = 4'd2,
            exec_nop    = 4'd3,
            exec_halt   = 4'd4,
            exec_mov    = 4'd5,
            exec_load   = 4'd6,
            exec_store  = 4'd7,
            exec_ula    = 4'd8,
            exec_push   = 4'd9,
            exec_pop    = 4'd10,
            exec_cmp    = 4'd11,
            exec_JMPs   = 4'd12,
            exec_ES     = 4'd13,
            wb_load     = 4'd14;
            
              
reg [3:0] ps, ns = init;   

always @(posedge clk or posedge rst)begin
    if(rst)
        ps <= init;
    else
        ps <= ns;
end

always @(*)begin
    ns = ps;
    case(ps)
        init:   ns = fetch;
        fetch:  ns = decode;        
        decode: begin
            if(IR_data == 16'h0000)
                ns = exec_nop;
            else if(IR_data == 16'hFFFF)
                ns = exec_halt;
            else begin
                case(IR_data[15:12])
                    4'b0000: begin
                       if( (IR_data[11]) && ( (IR_data[1:0] == 0) 
                       || ((IR_data[1:0] == 1) && (CPSR[1:0] == 2)) 
                       || ((IR_data[1:0] == 2) && (CPSR[1:0] == 0))
                       || ((IR_data[1:0] == 3) && (CPSR[1:0] == 1))
                       )) ns = exec_JMPs;
                       else if( (IR_data[11]) == 0)begin
                            if( (IR_data[1:0]) == 2'b01) ns = exec_push;
                            else if ( (IR_data[1:0]) == 2'b10) ns = exec_pop;
                            else if ( (IR_data[1:0]) == 2'b11) ns = exec_cmp;
                       end
                       else ns = fetch;
                    end
                    4'b0001: ns = exec_mov;
                    4'b0010: ns = exec_store;
                    4'b0011: ns = exec_load;
                    4'b0100,
                    4'b0101,
                    4'b0110,
                    4'b0111,
                    4'b1000,
                    4'b1001,
                    4'b1010,
                    4'b1011,
                    4'b1100,
                    4'b1101,
                    4'b1110: ns = exec_ula;
                    4'b1111: ns = exec_ES;
                    default: ns = exec_nop;                    
                endcase
            end
        end
        exec_nop   : ns = fetch;
        exec_halt  : ns = exec_halt;
        exec_mov   : ns = fetch;
        exec_store : ns = fetch;
        exec_ula   : ns = fetch; 
        exec_push  : ns = fetch;
        exec_ES    : ns = fetch;
        exec_cmp   : ns = fetch;
        exec_JMPs  : ns = fetch;
        default: ns = init;
    endcase
end

always @(*)begin
    PC_inc  = 0; 
    IR_load = 0;
    Immed   = 16'h0000;
    RAM_sel = 0;
    RAM_we  = 0;
    RF_sel  = 2'b00;
    Rd_sel  = 3'b000;
    Rd_wr   = 0;
    Rm_sel  = 3'b000;
    Rn_sel  = 4'b0000;
    ula_op  = 4'b0000;
    LED_ON  = 0;
    LED_sel = 0;
    CPSR_Write_Enable = 0;
    RAM_sel_addr  = 0;
    ULA_B_sel = 0;
    POP_sel = 0;

    case(ps)
        fetch: begin
            PC_inc = 1; 
            IR_load  = 1;
            Immed = 1;
        end
        exec_mov: begin
            Immed   = {8'h00, IR_data[7:0]};
            Rm_sel  = IR_data[7:5];
            Rd_sel  = IR_data[10:8];
            RF_sel  = {IR_data[11], 1'b0};
            Rd_wr   = 1'b1;
        end
        exec_ula: begin
            Rd_wr = 1;
            ula_op = IR_data[15:12];
            RF_sel = 3;
            Rd_sel = IR_data[10:8];
            Rm_sel = IR_data[7:5];
            Rn_sel = IR_data[4:2];
            Immed = {11'd0, IR_data[4:0]};

            if((IR_data[15:12] == 11) || (IR_data[15:12] == 12)) ULA_B_sel = 0;
            else ULA_B_sel = 1;
        end
        exec_ES: begin
            if((IR_data[11] == 0) && (IR_data[1:0] == 1)) begin // IN Rd
                Rd_wr = 1;
                Rd_sel = IR_data[10:8];
                RF_sel = 2; 
                Immed = {12'd0, read};
            end else begin
                Rm_sel = IR_data[7:5];
                LED_ON = 1;
                LED_sel = ~IR_data[11];
                Immed = {IR_data[10:8], IR_data[4:0]};
            end
        end
        exec_JMPs: begin
            PC_inc = 1; 
            Immed = {{7{IR_data[10]}}, IR_data[10:2]};
        end
        exec_store: begin
            Rm_sel = IR_data[7:5];
            Rn_sel = IR_data[4:2];
            RAM_we = 1;
            RAM_sel = IR_data[11];
            Immed = {IR_data[10:8],IR_data[4:0]};
        end
        exec_load: begin
            Rm_sel = IR_data[7:5];
        end
        exec_push: begin
            // STR[R7], Rn
            Rm_sel = 7;
            Rn_sel = IR_data[4:2];
            RAM_we = 1;

            // SUB R7, R7, #1
            RF_sel = 3;
            Rd_wr = 1;
            ula_op = 5;
            Rd_sel = 7;
            Immed = 1;
        end
        exec_pop: begin
            Rm_sel = 7;
            ula_op = 4;           // ULA faz ADD (R7 + 1)
            RAM_sel_addr = 1;     // Joga a saída da ULA pro endereço da RAM
            Immed = 1;            // Soma 1
            ULA_B_sel = 0;
            
            Rd_wr = 0;
            POP_sel = 0;
        end
        exec_cmp: begin
            Rm_sel = IR_data[7:5];
            Rn_sel = IR_data[4:2];
            CPSR_Write_Enable = 1;
            ULA_B_sel = 1;
        end
        wb_load: begin
            RF_sel = 1;             
            Rd_sel = IR_data[10:8]; 
            Rd_wr = 1;               
            
            if (IR_data[15:12] == 4'b0000 && IR_data[11] == 0 && IR_data[1:0] == 2'b10) begin
                Rm_sel = 7;
                ula_op = 4;
                Immed = 1;
                ULA_B_sel = 0;
                
                POP_sel = 1;        
            end
        end

        default: ;
    endcase    
end

endmodule

// 0 menor
// 1 maior
// 2 igual
/*



*/