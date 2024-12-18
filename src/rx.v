`timescale 1ns / 1ps

module rx
  #(parameter DATA_BIT = 8,
    parameter STOP_BIT = 1,
    parameter SB_TICK = 16,  //stop bit tick
    parameter BAUD_RATE = 9600)
    (
    input RxD,
    input clk,
    input reset,
    input sample_tick,
    output [DATA_BIT-1:0]data_out, //8 data bit
    output reg rx_done   
    );
    
    localparam IDLE = 2'b00;
    localparam START = 2'b01;
    localparam DATA = 2'b10;
    localparam STOP = 2'b11;
    
    reg [3:0]sample_counter,sample_counter_next;
    reg [3:0]bit_counter,bit_counter_next;
    reg [1:0]present_state = IDLE;
    reg [1:0]next_state = IDLE;
    reg [DATA_BIT-1:0] data_temp,data_temp_next;

    always@(posedge clk) begin
        if(reset) begin
            bit_counter <= 0;
            sample_counter <= 0;
            data_temp <= 0;
            present_state <= IDLE;
        end
        
        else begin
            present_state <= next_state;
            bit_counter <= bit_counter_next;
            sample_counter <= sample_counter_next;
            data_temp <= data_temp_next;
        end
    end
    
    always @* begin
        next_state <= present_state;
        rx_done <= 0;
        sample_counter_next <= sample_counter;
        bit_counter_next <= bit_counter;
        data_temp_next <= data_temp;

        case(present_state)
            IDLE: 
                  if(~RxD) begin
                      next_state <= START;
                      present_state <= START;
                      sample_counter_next <= 0;
                      sample_counter <= 0;
                  end
                  
            START: begin
                   if(sample_tick) begin
                      if(sample_counter == 7) begin
                          sample_counter_next <= 0;
                          bit_counter_next <= 0; 
                          next_state <= DATA;
                      end    
                      else
                          sample_counter_next <= sample_counter + 1;     
                   end
                   end
                   
            DATA: begin
                  if(sample_tick) begin
                      if(sample_counter == 15) begin
                          sample_counter_next <= 0;
                          data_temp_next <= {RxD,data_temp[DATA_BIT-1:1]};
                          if(bit_counter == DATA_BIT - 1)
                              next_state <= STOP;
                          else 
                              bit_counter_next <= bit_counter + 1;
                      end  
                      else
                          sample_counter_next <= sample_counter + 1;
                  end      
                  end
            STOP: begin
                  if(sample_tick) begin
                      if(sample_counter == SB_TICK - 1) begin
                          next_state <= IDLE;
                          rx_done <= 1;
                      end
                      
                      else
                          sample_counter_next <= sample_counter + 1;
                  end                  
                  end
        endcase
    end
    
    assign data_out = data_temp;
endmodule
