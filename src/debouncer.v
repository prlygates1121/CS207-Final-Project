`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2024 05:10:46 PM
// Design Name: 
// Module Name: debouncer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module debouncer(
    input clk,
    input PB,  // "PB" is the glitchy, asynchronous to clk, active high push-button signal

    // from which we make three outputs, all synchronous to the clock
    output reg PB_state,  // 1 as long as the push-button is active (i.e. pushed down)
    output PB_down,  // 1 for one clock cycle when the push-button goes down (i.e. just pushed)
    output PB_up   // 1 for one clock cycle when the push-button goes up (i.e. just released)
);

// First use two flip-flops to synchronize the PB signal the "clk" clock domain
reg PB_sync_0;  always @(posedge clk) PB_sync_0 <= PB;
reg PB_sync_1;  always @(posedge clk) PB_sync_1 <= PB_sync_0; // PB_sync_1 is now synchronous to "clk", it is the stabler version of PB

// Next declare a 21-bit counter
reg [20:0] PB_cnt;

// When the push-button is pushed or released, we increment the counter
// The counter has to be maxed out before we decide that the push-button state has changed

wire PB_idle = (PB_state == PB_sync_1);
wire PB_cnt_max = &PB_cnt;	// true when all bits of PB_cnt are 1's

always @(posedge clk) begin
    if (PB_idle) begin
        PB_cnt <= 0;  // nothing's going on
    end else begin
        PB_cnt <= PB_cnt + 21'd1;  // something's going on, increment the counter
        if (PB_cnt_max)
            PB_state <= ~PB_state;  // if the counter is maxed out (2.097152 ms passed), PB changed!
    end
end

assign PB_down = ~PB_idle & PB_cnt_max & ~PB_state;
assign PB_up   = ~PB_idle & PB_cnt_max &  PB_state;
endmodule
