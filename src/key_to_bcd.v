`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2024 08:05:45 PM
// Design Name: 
// Module Name: key_to_bcd
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


module key_to_bcd(
    input clk,
    input reset,
    input [7:0] key_val,
    output [3:0] key_bcd
    );
    reg [3:0] key_bcd_reg;
    always @(posedge clk) begin
        if (reset) begin
            key_bcd_reg <= 4'h0;
        end else begin
            case (key_val)
                8'h16:  key_bcd_reg <= 4'h1;
                8'h1E:  key_bcd_reg <= 4'h2;
                8'h26:  key_bcd_reg <= 4'h3;
                8'h25:  key_bcd_reg <= 4'h4;
                8'h2E:  key_bcd_reg <= 4'h5;
                8'h36:  key_bcd_reg <= 4'h6;
                8'h3D:  key_bcd_reg <= 4'h7;
                8'h3E:  key_bcd_reg <= 4'h8;
                8'h46:  key_bcd_reg <= 4'h9;
                8'h45:  key_bcd_reg <= 4'h0;
            endcase
        end
    end
    assign key_bcd = key_bcd_reg;
endmodule
