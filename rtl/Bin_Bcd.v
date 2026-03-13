`timescale 1ns / 1ps

module Bin_Bcd(clk,rst,BCDFlag,BIN,BCDH,BCDT,BCDO);
    //inputs
    input clk, rst;
    //flag to start bcd conversion
    input BCDFlag;
    input [9:0] BIN;
    
    //3 bcd digits to output onto the 7 segments
    output reg [3:0] BCDH, BCDT, BCDO;

    //full 22 bits for shift register 4 + 4 + 4 BCD and 10 input
    reg [21:0] working_reg;
    //counts to 10, for the amount to shift
    reg [3:0] count;
    //FSM states, 4, one for each
    reg [1:0] state;

    always @(posedge clk) begin
        //synchronous reset
        if (rst) begin
            state <= 2'b00;
            count <= 0;
        end 
        //FSM
        else begin
            case (state)
            //Initialization
            2'b00: begin
                //flag from controller, if says to convert,  + or -, will convert
                if (BCDFlag) begin
                    //full bits to be shifted and input BIN
                    working_reg <= {12'b0000_0000_0000,BIN};
                    
                    //init count as 0, start state
                    count   <= 0;
                    state   <= 2'b01;
                end
            end
            //adjusting or adding
            2'b01: begin
                //Had to check every case, using three ifs would work, but would use blocking statements, which would be in the wrong block
                //Using 3 to check only would cause race conditions
                
                //check and add Hundreds, Tens,Ones
                if(working_reg[21:18] > 4 && working_reg[17:14] > 4 && working_reg[13:10] > 4) begin
                    working_reg <= working_reg + 22'b00_0011_0011_0011_00_0000_0000;
                end
                
                //check two of the Hundreds, Tens Ones,
                else if(working_reg[21:18] <= 4 && working_reg[17:14] > 4 && working_reg[13:10] > 4) begin
                    working_reg <= working_reg + 22'b00_0000_0011_0011_00_0000_0000;
                end
                else if(working_reg[21:18] > 4 && working_reg[17:14] <= 4 && working_reg[13:10] > 4) begin
                    working_reg <= working_reg + 22'b00_0011_0000_0011_00_0000_0000;
                end
                else if(working_reg[21:18] > 4 && working_reg[17:14] > 4 && working_reg[13:10] <= 4) begin
                    working_reg <= working_reg + 22'b00_0011_0011_0000_00_0000_0000;
                end
                
                //check a singular Hundreds, Tens, Ones
                else if(working_reg[21:18] > 4 && working_reg[17:14] <= 4 && working_reg[13:10] <= 4) begin
                    working_reg <= working_reg + 22'b00_0011_0000_0000_00_0000_0000;
                end
                else if(working_reg[21:18] <= 4 && working_reg[17:14] > 4 && working_reg[13:10] <= 4) begin
                    working_reg <= working_reg + 22'b00_0000_0011_0000_00_0000_0000;
                end
                else if(working_reg[21:18] <= 4 && working_reg[17:14] <= 4 && working_reg[13:10] > 4) begin
                    working_reg <= working_reg + 22'b00_0000_0000_0011_00_0000_0000;
                end
                //No change
                else begin
                    working_reg <= working_reg;
                end 
                
                //move on to shifing state
                state <= 2'b10;
            end

            //shifting
            2'b10: begin
                //shift reg by 1
                working_reg <= working_reg << 1;
                //incremetn count for number of shifts
                count <= count + 1;
                
                //will stop if shifted 10 times, continue if not 10
                if (count == 4'd9) begin
                    state <= 2'b11;
                end
                else begin
                    state <= 2'b01;
                end
            end
            //completion
            2'b11: begin
                //make 3 BCDs for each of the 4 sections shifted and added
                BCDH <= working_reg[21:18];
                BCDT <= working_reg[17:14];
                BCDO <= working_reg[13:10];
                state <= 2'b00;
            end
            default: begin
                state <= 2'b00;
            end
            endcase
        end
    end

endmodule
