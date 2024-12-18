`timescale 1ns / 1ps

module baudrate_generator
   #(parameter BAUD_RATE = 9600) (
    input clk,
    input reset,
    output reg sample_tick
    );
    
    localparam MAX_COUNTER = (100000000/(16*BAUD_RATE));
    //localparam MAX_COUNTER = 651;
    
    reg [31:0]counter;
    
    always@(posedge clk) begin
        if(reset) begin
            sample_tick <= 0;
            counter <= 0;
        end
        else begin
            sample_tick <= 0;
            counter <= counter + 1;
            if(counter == MAX_COUNTER) begin
                counter <= 0;
                sample_tick <= 1;
            end
        end
    end    
endmodule
