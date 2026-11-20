`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2024 09:19:06 PM
// Design Name: 
// Module Name: bcd_counter
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


module bcd_counter #(
    parameter COUNT_DOWN = 0
)(
    input clk,
    input reset,
    input [23:0] reset_val,
    input ena,
    output [7:0] hh,
    output [7:0] mm,
    output [7:0] ss
); 
    wire up_min, up_hr;
    wire secmax, minmax;
    
    sixty #(
        .COUNT_DOWN(COUNT_DOWN)
    ) seconds(
        .clk(clk), 
        .reset(reset),
        .reset_val(reset_val[7:0]),
        .ena(ena), 
        .max2(secmax), 
        .q(ss)
    );

    sixty #(
        .COUNT_DOWN(COUNT_DOWN)
    ) minutes(
        .clk(clk), 
        .reset(reset), 
        .reset_val(reset_val[15:8]),
        .ena(up_min), 
        .max2(minmax), 
        .q(mm)
    );

    twelve #(
        .COUNT_DOWN(COUNT_DOWN)
    ) hours(
        .clk(clk), 
        .reset(reset), 
        .reset_val(reset_val[23:16]),
        .ena(up_hr), 
        .q(hh)
    );
    
    assign up_min = ena & secmax;
    assign up_hr = ena & up_min & minmax;
    
endmodule

module twelve #(
    parameter COUNT_DOWN = 0
) (
    input clk,
    input reset,
    input [7:0] reset_val,
    input ena,
    output max2,
    output [7:0] q
);
    wire max1, ena2;
    wire [3:0] overflow_val_ones;
    wire [3:0] overflow_val_tens;

    /*
    * Q: When will the ones place of the hours overflow?
    * A:
    *   If COUNT_DOWN == 0:
    *                         when hours == X9
    *   If COUNT_DOWN == 1:
    *                         when hours == X0
    */  
    assign max1 = (q[3:0] == (COUNT_DOWN ? 4'h0 : 4'h9));

    /* Q: When will the tens place of the hours overflow?
    *  A: If COUNT_DOWN == 0:
    *                         when hours == 99
    *     If COUNT_DOWN == 1:
    *                         no overflow
    */
    assign max2 = COUNT_DOWN ? 1'b0 : (max1 & (q[7:4] == 4'h9)); 

    /* Q: When should I increment the tens place of the hours?                 
    *  A: When ones place overflows and ena == 1
    */
    assign ena2 = ena & max1; 

    assign overflow_val_ones = COUNT_DOWN ? 4'h9 : 4'h0;
    assign overflow_val_tens = 4'h0;

    // con_ones is the ones place of the hours
    bcd_counter_one #(
        .COUNT_DOWN(COUNT_DOWN)
    ) con_ones(
        .clk(clk), 
        .reset(reset), 
        .reset_val(reset_val[3:0]), 
        .ena(ena), 
        .overflow_condition(max1),
        .overflow_val(overflow_val_ones),
        .out(q[3:0])
    );

    // con_tens is the tens place of the hours
    bcd_counter_one #(
        .COUNT_DOWN(COUNT_DOWN)
    ) con_tens(
        .clk(clk), 
        .reset(reset), 
        .reset_val(reset_val[7:4]), 
        .ena(ena2), 
        .overflow_condition(max2),
        .overflow_val(overflow_val_tens),
        .out(q[7:4])
    );

endmodule
    
module sixty #(
    parameter COUNT_DOWN = 0
) (
    input clk,
    input reset,
    input [7:0] reset_val,
    input ena,
    output max2,
    output [7:0] q
);
    wire ena2, max1;
    wire [3:0] overflow_val_ones;
    wire [3:0] overflow_val_tens;

    /* Q: When will the ones place of the minutes/seconds overflow?                        
    *  A: 
    *       If COUNT_DOWN == 0:
    *                            when minutes/seconds is X9
    *       If COUNT_DOWN == 1:
    *                            when minutes/seconds is X0
    */
    assign max1 = (q[3:0] == (COUNT_DOWN ? 4'h0 : 4'h9));

    /* Q: When will the tens place of the minutes/seconds overflow?
    *  A: If COUNT_DOWN == 0:
    *                         when minutes/seconds is 59
    *     If COUNT_DOWN == 1:
    *                         when minutes/seconds is 00
    */
    assign max2 = max1 & (q[7:4] == (COUNT_DOWN ? 4'h0 : 4'h5));

    /* Q: When should I increment the tens place of the minutes/seconds? 
    *  A: When ones place overflows and ena == 1
    */
    assign ena2 = ena & max1;

    assign overflow_val_ones = COUNT_DOWN ? 4'h9 : 4'h0;
    assign overflow_val_tens = COUNT_DOWN ? 4'h5 : 4'h0;
    
    bcd_counter_one #(
        .COUNT_DOWN(COUNT_DOWN)
    ) con_ones(
        .clk(clk),
        .reset(reset), 
        .reset_val(reset_val[3:0]), 
        .ena(ena), 
        .overflow_condition(max1),
        .overflow_val(overflow_val_ones),
        .out(q[3:0])
    );

    bcd_counter_one #(
        .COUNT_DOWN(COUNT_DOWN)
    ) con_tens(
        .clk(clk), 
        .reset(reset), 
        .reset_val(reset_val[7:4]), 
        .ena(ena2), 
        .overflow_condition(max2), 
        .overflow_val(overflow_val_tens),
        .out(q[7:4])
    );
    
endmodule

module bcd_counter_one #(
    parameter COUNT_DOWN = 0
) (
    input clk,
    input reset,
    input [3:0] reset_val,
    input ena,
    input overflow_condition,           // when this condition is met, the counter returns to 0
    input [3:0] overflow_val,                 // the value to return to when overflow_condition is met
    output reg [3:0] out
);
    always @(posedge clk) begin
        if (reset)
            out <= reset_val;
        else
            out <= ena ? (overflow_condition ? overflow_val : (COUNT_DOWN ? (out - 4'b1) : (out + 4'b1))) : out;
    end
endmodule
