`timescale 1ns / 1ps

module Controller_TB;

    reg clk100Mhz, rst;
    reg BTN0_pulse, BTN1_pulse, BTN2_pulse, BTN3_pulse; 
    reg SW1; 
    
    wire [9:0] Count; 
    wire OFLOW, tick, toggle, flash;
    
    
    initial begin
        clk100Mhz = 0;
        forever #5 clk100Mhz = ~clk100Mhz; 
    end
    
    Controller #(
        .cycles_second(10), 
        .cycles_halfsecond(5)
    ) dut (
        .clk100Mhz(clk100Mhz), .rst(rst), 
        .BTN0_pulse(BTN0_pulse), .BTN1_pulse(BTN1_pulse), .BTN2_pulse(BTN2_pulse), .BTN3_pulse(BTN3_pulse), 
        .SW1(SW1), 
        .Count(Count), 
        .OFLOW(OFLOW), 
        .tick(tick), .toggle(toggle), .flash(flash)
    );
    
    
    initial begin
    
    rst = 1; 
    BTN0_pulse = 0; BTN1_pulse = 0; BTN2_pulse = 0; BTN3_pulse = 0;
    SW1 = 0;
    #30;
    rst = 0;
    
    //Count should be 0, flash should be high for 40ns
    #30;
    
    BTN3_pulse = 1;
    #10;
    BTN3_pulse = 0;
    #50;
    
    //add 30
    BTN0_pulse = 1;
    #10;
    BTN0_pulse = 0;
    #200;
    
    BTN1_pulse = 1;
    #10;
    BTN1_pulse = 0;
    #50;
    
    BTN2_pulse = 1;
    #10;
    BTN2_pulse = 0;
    #50;
    
    BTN3_pulse = 1;
    #10;
    BTN3_pulse = 0;
    #50;
    
    BTN3_pulse = 1;
    #10;
    BTN3_pulse = 0;
    #50;
    
    SW1 = 1; 
    #100;
    SW1 = 0;
    
    end
    
    
    
endmodule
