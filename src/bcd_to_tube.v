`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2024 04:11:46 PM
// Design Name: 
// Module Name: bcd_to_tube
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


module bcd_to_tube(
    input [3:0] bcd,
    output [7:0] tube_content
    );

    assign tube_content =
        (bcd == 4'b0000) ? 8'b1111_1100 :   //"0" : abcdef_ _  
        (bcd == 4'b0001) ? 8'b0110_0000 :   //"1":  _bc_ _ _ _ _ _
        (bcd == 4'b0010) ? 8'b1101_1010 :   //"2": ab_de_g_ 
        (bcd == 4'b0011) ? 8'b1111_0010 :   //"3":  abcd_ _ g _
        (bcd == 4'b0100) ? 8'b0110_0110 :   //"4": _bc _ _fg_
        (bcd == 4'b0101) ? 8'b1011_0110 :   //"5": a_cd_fg_
        (bcd == 4'b0110) ? 8'b1011_1110 :   //"6": a_cdefg_
        (bcd == 4'b0111) ? 8'b1110_0000 :   //"7": abc_ _ _ _ _
        (bcd == 4'b1000) ? 8'b1111_1110 :   //"8": abcdefg_
        (bcd == 4'b1001) ? 8'b1110_0110 :   //"9": abc_ _ fg_
        8'b1001_1110;                       //"E": a_ _ defg_

endmodule
