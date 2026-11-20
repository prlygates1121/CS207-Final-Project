`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2024 04:37:42 PM
// Design Name: 
// Module Name: tube_display
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


module tube_display(
    input clk,
    input reset,
    input display_ena,
    input [63:0] tube_content,
    output reg [7:0] tube_ena,
    output reg [7:0] left_tube_content,
    output reg [7:0] right_tube_content
    );

    always @(posedge clk) begin
        if (reset) begin
            tube_ena <= 8'b0001_0001;
            left_tube_content <= 8'b1001_1110;
            right_tube_content <= 8'b1001_1110;
        end else if (display_ena) begin
            case (tube_ena)
                8'b0001_0001: begin
                    left_tube_content <= tube_content[47:40];
                    right_tube_content <= tube_content[15:8];
                    tube_ena <= 8'b0010_0010;
                end
                8'b0010_0010: begin
                    left_tube_content <= tube_content[55:48];
                    right_tube_content <= tube_content[23:16];
                    tube_ena <= 8'b0100_0100;
                end
                8'b0100_0100: begin
                    left_tube_content <= tube_content[63:56];
                    right_tube_content <= tube_content[31:24];
                    tube_ena <= 8'b1000_1000;
                end
                8'b1000_1000: begin
                    left_tube_content <= tube_content[39:32];
                    right_tube_content <= tube_content[7:0];
                    tube_ena <= 8'b0001_0001;
                end
                // by default, display "E" on both tubes
                default: begin
                    left_tube_content <= 8'b1001_1110;
                    right_tube_content <= 8'b1001_1110;
                    tube_ena <= 8'b0001_0001;
                end
            endcase
        end
    end
endmodule
