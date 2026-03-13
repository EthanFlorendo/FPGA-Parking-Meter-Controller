`timescale 1ns/1ps
//HAVE TO CHANGE DEF IN BCD CONTROL
module Output_TB;
    //inputs
    reg clk100Mhz;
    reg rst;
    reg BCDFlag;
    reg [9:0] Count;
    reg flash;
    reg toggle;
    //outputs
    wire [3:0] BCDH, BCDT, BCDO;
    wire [6:0] seg;
    wire dot;
    wire [3:0] an;

    //takes binary numbers from main controller, converts to bcd
    Bin_Bcd converter(.clk(clk100Mhz), .rst(rst), 
    
                      .BCDFlag(BCDFlag),
                      .BIN(Count), .BCDH(BCDH), .BCDT(BCDT), .BCDO(BCDO));

    //takes bcds, switcches between them
    BCD_Control disp(.clk(clk100Mhz), .rst(rst),
                     .BCDH(BCDH), .BCDT(BCDT), .BCDO(BCDO),
                     //logic and timing of flashing passed from controller
                     .flashing(flash), .toggle(toggle),
                     //display
                     .seg(seg), .dot(dot), .an(an));

    initial begin
        clk100Mhz = 1'b0;
        forever #5 clk100Mhz = ~clk100Mhz;
    end

    initial begin
        rst = 1;
        BCDFlag = 0;
        Count = 0;
        flash = 0;
        toggle = 0;
        #50 rst = 0;

        //initialize number
        Count = 123;
        

        // check normal output
        #10 BCDFlag = 1;
        #10 BCDFlag = 0;
        #400;
        
        //when reached 0
        //flash on
        flash = 1;
        toggle = 0;
        #50;
        //flash off
        flash = 1;
        toggle = 1;
        #50;
        
        
        $finish;
    end

endmodule
