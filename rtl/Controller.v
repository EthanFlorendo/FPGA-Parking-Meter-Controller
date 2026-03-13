`timescale 1ns / 1ps


module Controller #(

    parameter integer cycles_second = 100000000, 
    parameter integer cycles_halfsecond = 50000000
    )
    (
    //input
    clk100Mhz, rst,
    BTN0_pulse,BTN1_pulse,BTN2_pulse,BTN3_pulse,
    SW1,
    //output
    Count,
    OFLOW, tick, toggle, flash, BCDFlag
    );
    input clk100Mhz; 
    input rst;
    input BTN0_pulse, BTN1_pulse, BTN2_pulse, BTN3_pulse;
    input SW1;
    
    output reg [9:0] Count;
    output reg OFLOW;
    //1 Hz tick
    output reg tick;
    //.5 second toggle
    output reg toggle;
    //flash enable
    output reg flash;
    //when to convert binary to bcd
    output reg BCDFlag;
    
    reg add_count, dec_count; 
    reg [9:0]add_val;
    //div1 counter for 1 second tick, div2 for half second toggle flash
    reg [26:0] div1, div2;
    
    
    
    always @ (posedge clk100Mhz) begin
        // Active high reset
        if(rst) begin
        
            div1 <= 27'd0;
            div2 <= 27'd0;
            toggle <= 0;
            tick <= 0;
            
        end else begin
            // 1 Second counter
            tick <= 1'b0;
            if (div1 == cycles_second - 1) begin
                div1 <= 27'd0;
                tick <= 1'b1;
            end else begin
                div1 <= div1 + 1'b1; 
            end 
            
            // Flashing counter
            if (div2 == cycles_halfsecond - 1) begin
                div2 <= 27'd0;
                toggle <= ~toggle;
            end else begin
                div2 <= div2 + 1'b1;
            end
        end
    end 
    
    //Combinational Controller
    always @ (*) begin
    
        //default values of enables (Not adding time, no value to add, not decrementing, board start flash (in project description) 
        add_count = 1'b0;
        add_val = 10'd0;
        dec_count = 1'b0;
        flash = 1'b1;
        
        
        if(SW1) begin
        
            add_count = 1'b0;
            add_val = 10'd0;
            dec_count = 1'b0;
            flash = 1'b0;
        
        end else begin
        
            //Count should be 0 at start, therefore flash will enable until time is added
            flash = (Count == 10'd0);
            
            //Add time button pulse check
            if(BTN0_pulse) begin
                add_count = 1'b1;
                add_val = 10'd30;
            end else if(BTN1_pulse) begin
                add_count = 1'b1;
                add_val = 10'd120; 
            end else if(BTN2_pulse) begin
                add_count = 1'b1;
                add_val = 10'd180;
            end else if(BTN3_pulse) begin
                add_count = 1'b1;
                add_val = 10'd300;
            end
            
            
            if(tick) begin
                dec_count = 1'b1;
            end
            
        end
    
    end
    
    
    //Sequential datapath
    always @ (posedge clk100Mhz) begin
    
        if(rst) begin
        
            //Reset count, state etc
            Count <= 10'd0;
            OFLOW <= 1'b0;
            //John Kronik in discord asked about what should be done during rst switch high, if TA responds implement accordingly, otherwise our choice (flash, lights on, nothing)
            BCDFlag <= 1'b0;
        end else begin
            //Preset 15s Switch 
            BCDFlag <= 1'b0;
            if(SW1) begin
                Count <= 10'd15;
                OFLOW <= 1'b0;
                BCDFlag <= 1'b1;
            end
            //Pulse read, add_count enabled, adds to count
            else if(add_count) begin
            
                if({1'b0, Count} + {1'b0, add_val} > 11'd999)begin
                    Count <= 10'd999;
                    OFLOW <= 1'b1;
                end else begin
                    Count <= Count + add_val;
                    OFLOW <= 1'b0;
                end
                BCDFlag <= 1'b1;
            end 
            //Timer count down while decrement is enabled and count is not 0
            else if(dec_count) begin
                if(Count == 10'd0)begin
                    Count <= 10'd0;
                end else begin
                    Count <= Count - 1'd1;
                end 
                OFLOW <= 1'b0;
                BCDFlag <= 1'b1;
            end
        end
        
        
            
    end 


endmodule
