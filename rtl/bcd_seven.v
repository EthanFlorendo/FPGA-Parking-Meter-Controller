`timescale 1ns / 1ps


//given file from lecture, takes bcd, outputs onto seven segment display
module bcd_seven(bcd,segs_with_dp);
input [3:0]bcd;
output[7:0]segs_with_dp;

reg   [6:0]seven;

always @(*)
begin
    case(bcd)
    4'b0000: seven = 7'b0111111;
    4'b0001: seven = 7'b0000110;
    4'b0010: seven = 7'b1011011;
    4'b0011: seven = 7'b1001111;
    4'b0100: seven = 7'b1100110;
    4'b0101: seven = 7'b1101101;
    4'b0110: seven = 7'b1111101;
    4'b0111: seven = 7'b0000111;
    4'b1000: seven = 7'b1111111;
    4'b1001: seven = 7'b1101111;
    default: seven = 7'b0000000;
    endcase
end

//changed to ~ as polarity is opposite
assign segs_with_dp = {1,~seven};
endmodule
