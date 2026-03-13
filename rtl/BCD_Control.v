`timescale 1ns / 1ps
`define CTUPPER 16 //16 when on hardware, 1 when simulating
`define CTLOWER 15 //15 when on hardware, 1 when simulating
module BCD_Control(clk,rst,BCDH,BCDT,BCDO,flashing,toggle,seg,dot,an);
    //inputs
    input clk, rst;
    input [3:0] BCDH,BCDT,BCDO;
    //inputs from controller, flashing bit, and toggle for time control
    input flashing, toggle;      
    
    //seven segment and dot, will be obtained from bcd_seven module
    output [6:0] seg;  
    output  dot;
    
    //anode, switch between each display
    output reg [3:0] an;
    
    //counter for 1kHz
    reg [18:0] counter = 0;
    //records currect BCD, passes it to bcd_seven
    reg [3:0] digit;

always @(posedge clk) begin
    //synchronous reset
    if (rst) begin  
            //reset clock counting to switch between, make digit 0, anode 1111 to not display any
            counter       <= 0;
            digit         <= 4'b0000;
            an            <= 4'b1111;
        end
    else begin
        //counter of 1kHz
        counter <= counter + 1;
        //flashing on, toggle on, will display nothing .5s
        if (flashing && toggle) begin
            an   <= 4'b1111;
        end 
        //flashing on, toggle off, will display a zero .5s
        else if (flashing && ~toggle) begin
            digit <= 4'b0000;
            an   <= 4'b0000;
        end
        else begin
            //checks bits 17 and 16 of counter, approximately 250 Hz to switch between each digit
            case (counter[`CTUPPER:`CTLOWER])
                //turn on anode for ones, display BCD for ones
                2'b00: begin 
                    digit <= BCDO; 
                    an <= 4'b1110;   
                end 
                //turn on anode for tens, display BCD for tens
                2'b01: begin 
                    digit <= BCDT; 
                    an <= 4'b1101; 
                end
                //turn on anode for hundreds, display BCD for hundreds
                2'b10: begin 
                    digit <= BCDH; 
                    an <= 4'b1011; 
                end
                //do not use thousands place, placeholder
                2'b11: begin 
                    an <= 4'b1111; 
                end
            endcase
        end
    end
end
//instantiate bcd_seven with digit as bcd, output of segments and dot
bcd_seven seg_decoder(.bcd(digit),.segs_with_dp({dot,seg}));

endmodule
