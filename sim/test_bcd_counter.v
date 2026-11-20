`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2024 04:06:04 PM
// Design Name: 
// Module Name: test_bcd_counter
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

module  test_bcd_counter ();
	reg clk=0;
	always #5 clk = ~clk;  // Create clock with period=10

	// A testbench
	reg reset;
    reg [23:0] reset_val;
    wire [7:0] hh;
    wire [7:0] mm;
    wire [7:0] ss;
    initial reset_val = 24'h04_01_00;
    bcd_counter #(.COUNT_DOWN(1)) system_time_counter (
        .clk(clk),
        .reset(reset),
        .reset_val(reset_val),
        .ena(1'b1),
        .hh(hh),
        .mm(mm),
        .ss(ss)
    );
	initial begin
		reset = 1;
        #18 reset = 0;
        #300000 $finish;
	end

endmodule
