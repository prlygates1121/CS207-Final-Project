`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2024 12:06:10 AM
// Design Name: 
// Module Name: timer
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


module timer #(
    parameter PERIOD = 100_000_000 // 1 second
)(
    input wire clk,
    input wire reset,
    input wire halt,
    output reg done
    );
    reg [31:0] count;
    
    always @(posedge clk) begin
        if (reset) begin
            count <= 1'b0;
            done <= 1'b0;
        end else begin
            if (~halt) begin
                // if the max_count has not been reached
                if (count < PERIOD - 1) begin
                    // clear done bit
                    done <= 1'b0;
                    // increment counter
                    count <= count + 1;
                end 
                // if the max_count is reached
                else begin
                    done <= 1'b1;
                    count <= 1'b0;
                end
            end else begin
                done <= 1'b0;
            end
        end
    end
endmodule
