`timescale 1ns / 1ps

module top_rx(
    input Rx,
    input clk,
    input reset,
    output [7:0]RxD,
    output rx_done
    );
    
    baudrate_generator f0(clk,reset,sample_tick);
    Rx f1(Rx,clk,reset,sample_tick,RxD,rx_done);
endmodule
