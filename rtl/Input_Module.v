`timescale 1ns / 1ps

module Input_Module(clk100Mhz, rst, BTNU ,BTND ,BTNR ,BTNL ,BTN0_pulse,BTN1_pulse,BTN2_pulse,BTN3_pulse);
    input clk100Mhz, rst;
    input BTNU,BTND,BTNR,BTNL;

    output reg BTN0_pulse,BTN1_pulse,BTN2_pulse,BTN3_pulse;

    wire BTN0, BTN1, BTN2, BTN3;
    
    debouncer btnu(.clk100Mhz(clk100Mhz), .rst(rst), .i_sig(BTNU), .o_sig_debounced(BTN0));
    debouncer btnd(.clk100Mhz(clk100Mhz), .rst(rst), .i_sig(BTND), .o_sig_debounced(BTN1));
    debouncer btnr(.clk100Mhz(clk100Mhz), .rst(rst), .i_sig(BTNR), .o_sig_debounced(BTN2));
    debouncer btnl(.clk100Mhz(clk100Mhz), .rst(rst), .i_sig(BTNL), .o_sig_debounced(BTN3));
    
    reg BTN0_prev, BTN1_prev, BTN2_prev, BTN3_prev;
    
    always @ (posedge clk100Mhz) begin
    
        if(rst) begin
        
            BTN0_prev <= 0;
            BTN1_prev <= 0;
            BTN2_prev <= 0;
            BTN3_prev <= 0;
            
            BTN0_pulse <= 0;
            BTN1_pulse <= 0;
            BTN2_pulse <= 0;
            BTN3_pulse <= 0;
        
        end else begin
        
            //Creates single pulse on button press
            //Logic: Current BTN == 1, Prev button == 0 (Detects rising edge, 0 --> 1) BTNx_pulse is 1 for the duration of the current cycle. 
            BTN0_pulse <= BTN0 & ~BTN0_prev;
            BTN1_pulse <= BTN1 & ~BTN1_prev;
            BTN2_pulse <= BTN2 & ~BTN2_prev;
            BTN3_pulse <= BTN3 & ~BTN3_prev;
            
            //Update prev
            BTN0_prev <= BTN0;
            BTN1_prev <= BTN1;
            BTN2_prev <= BTN2;
            BTN3_prev <= BTN3;
        
        end

    end
    
    

endmodule
