`timescale 1ns / 1ps
//HAVE TO CHANGE DEF IN DEBOUNCER
module Input_Module_TB;

reg clk100Mhz;
reg rst;
reg BTNU, BTND, BTNR, BTNL;
wire BTN0_pulse, BTN1_pulse, BTN2_pulse, BTN3_pulse;

Input_Module test (

    .clk100Mhz(clk100Mhz), 
    .rst(rst), 
    .BTNU(BTNU), .BTND(BTND), .BTNR(BTNR), .BTNL(BTNL), 
    .BTN0_pulse(BTN0_pulse), .BTN1_pulse(BTN1_pulse), .BTN2_pulse(BTN2_pulse), .BTN3_pulse(BTN3_pulse) 
     
);

initial begin
    clk100Mhz = 1'b0;
    forever #5 clk100Mhz = ~clk100Mhz;
end

initial begin

    rst = 1'b1;
    BTNU = 1'b0; BTND = 1'b0; BTNR = 1'b0; BTNL = 1'b0;
    #30;
    rst = 1'b0;
    
    #70
    //Long(er) press results in one pulse output good
    BTNU = 1; #200;
    BTNU = 0; #80;
    
    //These dont affect pulse because the press is not long enough (Wont be an issue in practice, a button press will always be much longer)
    BTNR = 1; #60; BTNR = 0; #70;
    BTNR = 1; #60; BTNR = 0; #100;
    
    //Just seeing how many nanoseconds needed to register a pulse
    BTNL = 1; #80; BTNL = 0;
    
    #200;
    
end

endmodule
