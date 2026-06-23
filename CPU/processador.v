module processador (clk, rst, led, btn, tx_pin_out);
    input clk, rst;

    output [3:0] led;
    output tx_pin_out; 
    input [3:0] btn;

    wire [15:0] din, dout,D,Q_IR;
    wire [15:0] immed;
    wire [3:0] ula_op;
    wire [1:0] Rf_sel, CPSR;
    wire Rd_wr, en, ld, RAM_sel, RAM_we, ULA_B_sel, RAM_sel_addr, POP_sel, CPSR_Write_Enable, LED_ON, LED_sel, IR_load;
    wire [2:0] Rd_sel, Rm_sel, Rn_sel;
    wire [15:0] Q_PC;
    wire [15:0] saida_da_ULA, RM, RN;
    wire [15:0] addr;

    reg [3:0] PIN = 4'b0000;

    MUX_2x1 mux_2x1 (
        .I0 (RN),
        .I1 (immed),
        .sel (RAM_sel),
        .din (din),
        
        .sel2 (RAM_sel_addr),
        .Rm (RM),
        .SPadd (saida_da_ULA),
        .addr (addr)
        
    );

    wire is_uart_addr = (RM == 16'hFFE0) ? 1'b1 : 1'b0;
    wire trigger_uart = RAM_we & is_uart_addr;

    uart_tx my_uart (
        .clk      (clk),
        .rst      (rst),
        .tx_start (trigger_uart),     // Pulso de 1 ciclo gerado pelo STR
        .tx_data  (RN[7:0]),          // Os 8 bits menos significativos do registrador de dados
        .tx_pin   (tx_pin_out)       // Vai pro pino físico da FPGA       
    );


    wire ram_we_real = RAM_we & (~is_uart_addr);

    RAM ram (
        .clk (clk),
        .din (din),
        .addr (addr),
        .we (ram_we_real),
        .dout (dout)
    );

    PC pc (
        .clk(clk),
        .rst(rst),
        .ld (ld),
        .Q (Q_PC),
        .immed (immed)
    );

    ROM rom (
        .addr (Q_PC),
        .dout(D)
    );

    IR ir(
        .clk (clk),
        .rst (rst),
        .D (D),
        .IR_load (IR_load),
        .Q (Q_IR)
    );

    FSM fsm (
        .clk (clk),
        .rst (rst),
        .IR_data (Q_IR),
        .CPSR (CPSR),
        .read (btn),
        .LED_ON (LED_ON),
        .LED_sel (LED_sel),
        .CPSR_Write_Enable (CPSR_Write_Enable),
        .PC_inc (ld),
        .IR_load (IR_load),
        .Immed (immed),
        .RAM_sel (RAM_sel),
        .RAM_we (RAM_we),
        .RAM_sel_addr (RAM_sel_addr),
        .RF_sel (Rf_sel),
        .Rd_sel (Rd_sel),
        .Rd_wr (Rd_wr),
        .Rm_sel (Rm_sel),
        .Rn_sel (Rn_sel),
        .ula_op (ula_op),
        .ULA_B_sel (ULA_B_sel),
        .POP_sel (POP_sel)
    );

    datapath #(16) DATAPATH(
        .clk (clk),
        .rst (rst),
        .ula_op (ula_op),
        .Rd_sel (Rd_sel), 
        .Rm_sel (Rm_sel), 
        .Rn_sel (Rn_sel),
        .dout (dout),
        .CPSR_Write_Enable (CPSR_Write_Enable),
        .immed (immed),
        .Rd_wr (Rd_wr),          // 1 bit: habilita escrita no register file
        .RF_sel (Rf_sel),   
        .saida_da_ula (saida_da_ULA),
        .CPSR (CPSR),
        .RM (RM),
        .RN (RN),
        .ULA_B_sel (ULA_B_sel),
        .POP_sel (POP_sel) // RAM_sel_addr, pois so é 1 no POP

    );

    always @(posedge clk) begin
        if(rst) begin
            PIN <= 0;
        end

        else if(LED_ON) begin
            if(LED_sel)begin
                PIN <= RM[3:0];
            end
            else begin
                PIN <= immed[3:0];
            end
        end
    end

    assign led = PIN;
endmodule

