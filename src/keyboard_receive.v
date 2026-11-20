`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2024 04:46:56 PM
// Design Name: 
// Module Name: keyboard_receive
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


module keyboard_receive(
    input clk,
    input reset,
    input ena,
    input ps2_clk,
    input ps2_data,
    output reg done,
    output [7:0] key_val,
    output key_released
    );

    // WARNING: wider filter means greater resilience to key noise, but it also results in lower senitivity (cannot handle bursts of input)
    localparam FILTER_WIDTH = 5;

    // filters used to stablize the clock signal from keyboard
    reg [FILTER_WIDTH-1:0] ps2_clk_filter;
    wire [FILTER_WIDTH-1:0] ps2_clk_filter_next;

    // the stablized keyboard clock signal
    reg ps2_clk_val;
    wire ps2_clk_val_next;

    // indicates a negedge of keyboard clock signal
    wire ps2_negedge;

    // samples (shifts in) ps2_clk consecutively
    assign ps2_clk_filter_next = {ps2_clk, ps2_clk_filter_next[FILTER_WIDTH-1:1]};

    // changes only when ps2_clk_filter is all 1s or all 0s (8 consecutive high or low signals are sampled)
    assign ps2_clk_val_next = (&ps2_clk_filter) ? 1'b1 :
                                (~(|ps2_clk_filter)) ? 1'b0 :
                                ps2_clk_val_next;

    assign ps2_negedge = ps2_clk_val & ~ps2_clk_val_next;

    always @(posedge clk) begin
        if (reset) begin
            ps2_clk_filter <= 0;
            ps2_clk_val <= 1'b0;
        end else begin
            ps2_clk_filter <= ps2_clk_filter_next;
            ps2_clk_val <= ps2_clk_val_next;
        end
    end

    // FSM
    localparam IDLE = 1'b0, RX = 1'b1;
    reg state, next_state;

    reg [3:0] num;
    reg [3:0] num_next;

    reg [10:0] rx_buffer;
    reg [10:0] rx_buffer_next;

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            num <= 4'b0;
            rx_buffer <= 11'b0;
        end else begin
            state <= next_state;
            num <= num_next;
            rx_buffer <= rx_buffer_next;
        end
    end

    always @(*) begin
        next_state = state;
        num_next = num;
        rx_buffer_next = rx_buffer;
        done = 1'b0;
        case (state)
            IDLE:
                if (ps2_negedge & ena) begin
                    next_state = RX;
                    num_next = 4'd10;
                end
            RX: begin
                if (ps2_negedge) begin
                    rx_buffer_next = {ps2_data, rx_buffer_next[10:1]};
                    num_next = num - 1;
                end
                if (num == 0) begin
                    next_state = IDLE;
                    done = 1'b1;
                end
            end
        endcase
    end

    assign key_val = rx_buffer[8:1];
    assign key_released = done & (key_val == 8'hF0);

endmodule
