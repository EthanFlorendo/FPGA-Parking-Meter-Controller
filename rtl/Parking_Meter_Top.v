module Parking_Meter_Top(clk100Mhz,rst,BTNU,BTND,BTNR,BTNL,SW1,seg,dot,an,stop,OFLOW);
    //inputs
    input clk100Mhz, rst;
    //buttons and switches
    input BTNU,BTND,BTNR,BTNL, SW1;
    //outputs
    //display outputs
    output [6:0] seg;
    output dot;
    //output stop for left 7dig anodes
    output [3:0] an, stop;
    //>999 led
    output OFLOW;

    //debounced buttons
    wire BTN0_pulse,BTN1_pulse,BTN2_pulse,BTN3_pulse;
    //3 bcd counter
    wire [9:0] Count;
    wire OFLOW, tick, toggle, flash;
    wire [3:0] BCDH, BCDT, BCDO;
    wire BCDFlag;
    
    //stops left leds from turning on
    assign stop[3:0] = 4'b1111;

    //debounces the buttons, makes sure only detects positive clock edge

    Input_Module IM(.clk100Mhz(clk100Mhz), .rst(rst),
                    //input buttons
                    .BTNU(BTNU), .BTND(BTND), .BTNR(BTNR), .BTNL(BTNL),
                    //debounced button + edge
                    .BTN0_pulse(BTN0_pulse), .BTN1_pulse(BTN1_pulse), 
                    .BTN2_pulse(BTN2_pulse), .BTN3_pulse(BTN3_pulse));
                       
    //main logic
    Controller ctrl(.clk100Mhz(clk100Mhz), .rst(rst),
                    .BTN0_pulse(BTN0_pulse), .BTN1_pulse(BTN1_pulse),
                    .BTN2_pulse(BTN2_pulse), .BTN3_pulse(BTN3_pulse),
                    .SW1(SW1), .Count(Count), .OFLOW(OFLOW),
                    .tick(tick), .toggle(toggle), .flash(flash),
                    .BCDFlag(BCDFlag)
                    );
                    
                    
    //takes binary numbers from main controller, converts to bcd
    Bin_Bcd conv(.clk(clk100Mhz), .rst(rst), 
    
                      .BCDFlag(BCDFlag),
                      .BIN(Count), .BCDH(BCDH), .BCDT(BCDT), .BCDO(BCDO));

    //takes bcds, switcches between them
    BCD_Control disp(.clk(clk100Mhz), .rst(rst),
                     .BCDH(BCDH), .BCDT(BCDT), .BCDO(BCDO),
                     //logic and timing of flashing passed from controller
                     .flashing(flash), .toggle(toggle),
                     //display
                     .seg(seg), .dot(dot), .an(an));
endmodule
