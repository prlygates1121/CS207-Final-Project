`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2024 08:10:49 PM
// Design Name: 
// Module Name: main
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


module main(
    input clk,                                      // internal clock (100MHz)
    input reset_n,                                  // active-low reset
    input up,
    input down,
    input left,
    input right,
    input center,
    input [7:0] l_sws,
    input [7:0] r_sws,
    input ps2_clk,
    input ps2_data,
    output [7:0] l_leds,
    output [7:0] r_leds,
    output [7:0] tube_ena,                          // selects which tube to display
    output [7:0] left_tube_content,                 // content to display on the left group of tubes
    output [7:0] right_tube_content,                 // content to display on the right group of tubes
    output reg speaker,
    output speaker_enable                           // always being '0' which is enabled
    );

    /* ------------------------------------------------------- Debouncers ------------------------------------------------------- */

    // Internal wires for debouncer outputs
    wire up_state, up_pressed, up_released;
    wire down_state, down_pressed, down_released;
    wire left_state, left_pressed, left_released;
    wire right_state, right_pressed, right_released;
    wire center_state, center_pressed, center_released;
    
    // Signal for run-on shutdown (press the mid button for 3 secs). when 1, shutdown in all circumstances.
    wire shutdown_signal; 
    
    // Instantiate debouncers for each button
    debouncer debouncer_up (
        .clk(clk),
        .PB(up),
        .PB_state(up_state),
        .PB_down(up_pressed),
        .PB_up(up_released)
    );
    
    debouncer debouncer_down (
        .clk(clk),
        .PB(down),
        .PB_state(down_state),
        .PB_down(down_pressed),
        .PB_up(down_released)
    );
    
    debouncer debouncer_left (
        .clk(clk),
        .PB(left),
        .PB_state(left_state),
        .PB_down(left_pressed),
        .PB_up(left_released)
    );
    
    debouncer debouncer_right (
        .clk(clk),
        .PB(right),
        .PB_state(right_state),
        .PB_down(right_pressed),
        .PB_up(right_released)
    );
    
    debouncer debouncer_center (
        .clk(clk),
        .PB(center),
        .PB_state(center_state),
        .PB_down(center_pressed),
        .PB_up(center_released)
    );


    /* ------------------------------------------------------- FSM ------------------------------------------------------- */

    // State definitions
    reg [4:0] state, next_state;

    localparam [4:0] OFF                = 5'd0, 
                     OFF_READY          = 5'd1,
                     STANDBY            = 5'd2,
                     STANDBY_READY      = 5'd3,
                     MENU               = 5'd4,
                     L1                 = 5'd5, 
                     L2                 = 5'd6, 
                     L3                 = 5'd7,
                     L3_FORCED          = 5'd8,
                     ADV_SET            = 5'd9,
                     ADV_SET_REMIND     = 5'd10, 
                     ADV_SET_GESTURE    = 5'd11,
                     GET                = 5'd12,
                     GET_OPERATION      = 5'd13,
                     GET_GESTURE        = 5'd14,
                     SELF_CLEAN         = 5'd15,
                     SET_TIME           = 5'd16;


    // State transition logic
    always @(*) begin
        case (state)
            OFF: 
                if (left_pressed) 
                    next_state = OFF_READY;
                else if (center_pressed)
                    next_state = STANDBY;
                else
                    next_state = OFF;
            OFF_READY:
                if (right_pressed)
                    next_state = STANDBY;
                else if (gp_time_counter_zero)
                    next_state = OFF;
                else
                    next_state = OFF_READY;
            STANDBY:
                if (right_pressed)
                    next_state = STANDBY_READY; 
                else if (up_pressed)
                    next_state = MENU;
                else if (center_pressed)
                    next_state = GET;
                else if (down_pressed)
                    next_state = SET_TIME;
                else if (left_pressed)
                    next_state = ADV_SET;
                else
                    next_state = STANDBY;
            STANDBY_READY:
                if (left_pressed)
                    next_state = OFF;
                else if (gp_time_counter_zero)
                    next_state = STANDBY;
                else
                    next_state = STANDBY_READY;
            MENU:
                if (left_pressed)
                    next_state = L1;
                else if (center_pressed)
                    next_state = L2;
                else if (right_pressed & ~tried_level_3)
                    next_state = L3;
                else if (down_pressed)
                    next_state = SELF_CLEAN;
                else
                    next_state = MENU;
            L1:
                if (up_pressed)
                    next_state = STANDBY;
                else if (center_pressed)
                    next_state = L2;
                else
                    next_state = L1;
            L2:
                if (up_pressed)
                    next_state = STANDBY;
                else if (left_pressed)
                    next_state = L1;
                else
                    next_state = L2;
            L3:
                if (up_pressed)
                    next_state = L3_FORCED;
                else if (gp_time_counter_zero)
                    next_state = L2;
                else
                    next_state = L3;
            L3_FORCED:
                if (gp_time_counter_zero)
                    next_state = STANDBY;
                else
                    next_state = L3_FORCED;
            ADV_SET:
                if (left_pressed)
                    next_state = ADV_SET_REMIND;
                else if (right_pressed)
                    next_state = ADV_SET_GESTURE;
                else
                    next_state = ADV_SET;
            ADV_SET_REMIND:
                if (left_pressed)
                    next_state = STANDBY;
                else
                    next_state = ADV_SET_REMIND;
            ADV_SET_GESTURE:
                if (right_pressed)
                    next_state = STANDBY;
                else
                    next_state = ADV_SET_GESTURE;
            GET:
                if (left_pressed)
                    next_state = GET_OPERATION;
                else if (right_pressed)
                    next_state = GET_GESTURE;
                else
                    next_state = GET;
            GET_OPERATION:
                if (left_pressed)
                    next_state = STANDBY;
                else
                    next_state = GET_OPERATION;
            GET_GESTURE:
                if (right_pressed)
                    next_state = STANDBY;
                else
                    next_state = GET_GESTURE;
            SELF_CLEAN:
                if (gp_time_counter_zero)
                    next_state = STANDBY;
                else
                    next_state = SELF_CLEAN;
            SET_TIME:
                if (down_pressed)
                    next_state = STANDBY;
                else
                    next_state = SET_TIME;
            default:
                next_state = OFF;
        endcase
    end

    // State transition clock
    always @(posedge clk) begin
        if (~reset_n | shutdown_signal) begin
            state <= OFF;
        end else begin
            state <= next_state;
        end
    end

    /* ------------------------------------------------------- System Timer ------------------------------------------------------- */

    wire [23:0] system_time;

    reg system_time_counter_enable;                                                                                 // enable signal to the system time counter
    wire system_time_counter_reset = ~reset_n | state == OFF | state == OFF_READY | state == SET_TIME;          // reset signal to the system time counter
    wire [23:0] system_time_counter_reset_val = state == SET_TIME ? {time_setting_val_reg} : 24'h00_00_00;

    bcd_counter system_time_counter (
        .clk(clk),
        .reset(system_time_counter_reset),
        .reset_val(system_time_counter_reset_val),
        .ena(system_time_counter_enable),
        .hh(system_time[23:16]),
        .mm(system_time[15:8]),
        .ss(system_time[7:0])
    );

    always @(posedge clk) begin
        if (timer_system_done) begin
            system_time_counter_enable <= 1'b1;
        end else begin
            system_time_counter_enable <= 1'b0;
        end
    end
    
    reg timer_system_reset;                             // reset signal to the timer
    wire timer_system_done;                             // done signal from the timer

    timer #(
        .PERIOD(100_000_000)
    ) timer_system (
        .clk(clk),
        .reset(timer_system_reset),
        .halt(state == SET_TIME),
        .done(timer_system_done)
    );

    always @(posedge clk) begin
        if (system_time_counter_reset) begin
            timer_system_reset <= 1'b1;
        end else begin
            timer_system_reset <= 1'b0;
        end
    end

    /* -------------------------------------------------------- Operating Timer -------------------------------------------------------- */
    
    // Operating time elapsed (in hh:mm:ss)
    wire [23:0] operating_time;

    wire is_operational = state == L1 | state == L2 | state == L3 | state == L3_FORCED; // indicator that the machine is currently operating

    wire operating_time_counter_reset = ~reset_n | state == OFF | state == SELF_CLEAN & next_state == STANDBY | state == MENU & up_pressed;
    reg operating_time_counter_enable;

    reg [23:0] operating_time_reminder;
    localparam DEFAULT_OPERATING_TIME_REMINDER_VALUE = 24'h10_00_00;

    // indicates that operating time exceeded reminder value
    assign l_leds[6] = operating_time >= operating_time_reminder;

    bcd_counter operating_time_counter (
        .clk(clk),
        .reset(operating_time_counter_reset),
        .reset_val(24'd0),
        .ena(operating_time_counter_enable),
        .hh(operating_time[23:16]),
        .mm(operating_time[15:8]),
        .ss(operating_time[7:0])
    );
    
    // Operating time update clock
    always @(posedge clk) begin
        if (timer_operation_done) begin
           operating_time_counter_enable <= 1'b1;
        end else begin
           operating_time_counter_enable <= 1'b0;
        end 

        if (~reset_n) begin
            operating_time_reminder <= DEFAULT_OPERATING_TIME_REMINDER_VALUE;
        end else if (state == ADV_SET_REMIND) begin
            operating_time_reminder <= time_setting_val_reg;
        end
    end

    // Timer (operation)
    
    reg timer_operation_reset;                              // reset signal to the timer
    wire timer_operation_done;                              // done signal from the timer

    // Instantiate the operation timer
    timer #(
        .PERIOD(100_000_000)
    ) timer_operation (
        .clk(clk),
        .reset(timer_operation_reset),
        .halt(~is_operational),
        .done(timer_operation_done)
    );

    always @(posedge clk) begin
        if (~reset_n) begin
            timer_operation_reset <= 1'b1;
        end else begin
            timer_operation_reset <= 1'b0;
        end
    end

    /* --------------------------------------------------- General-purpose Timer --------------------------------------------------- */

    wire gp_timer_in_use = state == OFF_READY | state == STANDBY_READY | state == L3 | state == L3_FORCED | state == SELF_CLEAN;

    wire [23:0] gp_time;

    reg gp_time_counter_enable;
    wire gp_time_counter_reset = ~gp_timer_in_use;
    wire gp_time_counter_zero = ~(|gp_time);
    wire gp_time_counter_being_set = state == ADV_SET_GESTURE ;

    wire gp_time_level3_start = state == MENU & next_state == L3 | state == L3 & next_state == L3_FORCED;
    wire gp_time_self_cleaning_start = state == MENU & next_state == SELF_CLEAN;
    wire gp_time_gesture_start = state == OFF & next_state == OFF_READY | state == STANDBY & next_state == STANDBY_READY;

    wire [23:0] gp_time_counter_reset_val;
    reg [23:0] gp_time_counter_reset_val_level3;
    reg [23:0] gp_time_counter_reset_val_self_cleaning;
    reg [23:0] gp_time_counter_reset_val_gesture;
    
    localparam DEFAULT_GP_TIME_COUNTER_RESET_VAL_LEVEL3                 = 24'h00_00_11;
    localparam DEFAULT_GP_TIME_COUNTER_RESET_VAL_SELF_CLEANING          = 24'h00_00_15;
    localparam DEFAULT_GP_TIME_COUNTER_RESET_VAL_GESTURE                = 24'h00_00_05;

    bcd_counter #(
        .COUNT_DOWN(1)
    ) gp_time_counter (
        .clk(clk),
        .reset(gp_time_counter_reset),
        .reset_val(gp_time_counter_reset_val),
        .ena(gp_time_counter_enable),
        .hh(gp_time[23:16]),
        .mm(gp_time[15:8]),
        .ss(gp_time[7:0])
    );

    assign gp_time_counter_reset_val =
        gp_time_level3_start ? gp_time_counter_reset_val_level3 :
        gp_time_self_cleaning_start ? gp_time_counter_reset_val_self_cleaning :
        gp_time_gesture_start ? gp_time_counter_reset_val_gesture :
        gp_time_counter_reset_val_gesture;

    always @(posedge clk) begin
        if (timer_gp_done) begin
            gp_time_counter_enable <= 1'b1;
        end else begin
            gp_time_counter_enable <= 1'b0;
        end

        if (~reset_n) begin
            gp_time_counter_reset_val_level3 <= DEFAULT_GP_TIME_COUNTER_RESET_VAL_LEVEL3;
            gp_time_counter_reset_val_self_cleaning <= DEFAULT_GP_TIME_COUNTER_RESET_VAL_SELF_CLEANING;
            gp_time_counter_reset_val_gesture <= DEFAULT_GP_TIME_COUNTER_RESET_VAL_GESTURE;
        end else if (state == ADV_SET_GESTURE) begin
            gp_time_counter_reset_val_gesture <= time_setting_val_reg;
        end
    end
    
    reg timer_gp_reset;                       // reset signal to the timer
    wire timer_gp_done;                       // done signal from the timer

    timer #(
        .PERIOD(100_000_000)
    ) timer_gp (
        .clk(clk),
        .reset(timer_gp_reset),
        .halt(~gp_timer_in_use | gp_time_counter_being_set),
        .done(timer_gp_done)
    );

    always @(posedge clk) begin
        if (gp_time_counter_reset) begin
            timer_gp_reset <= 1'b1;
        end else begin
            timer_gp_reset <= 1'b0;
        end
    end

    /* ------------------------------------------------------- Shutdown Timer ------------------------------------------------------- */

    timer #(
        .PERIOD(300_000_000)
    ) timer_shutdown (
        .clk(clk),
        .reset(~center_state),
        .halt(1'b0),
        .done(shutdown_signal)
    );

    /* ---------------------------------------------------------- Keyboard ---------------------------------------------------------- */

    wire keyboard_sample_done;
    wire [7:0] key_val_temp;
    reg [7:0] key_val;
    wire key_released;

    keyboard_receive kb(
        .clk(clk),
        .reset(~reset_n),
        .ena(1'b1),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .done(keyboard_sample_done),
        .key_val(key_val_temp),
        .key_released(key_released)
    );

    always @(posedge clk) begin
        if (~reset_n) begin
            key_val <= 8'b0;
        end else if (keyboard_sample_done) begin
            key_val <= key_val_temp;
        end
    end

    wire [3:0] key_bcd;

    key_to_bcd k2bcd(
        .clk(clk),
        .reset(~reset_n),
        .key_val(key_val),
        .key_bcd(key_bcd)
    );

    /* ----------------------------------------------------- Time-setting ----------------------------------------------------- */

    wire setting_something = state == ADV_SET_REMIND | state == ADV_SET_GESTURE | state == SET_TIME;

    reg [5:0] num_sel;

    always @(posedge clk) begin
        if (~reset_n | ~setting_something) begin
            num_sel <= 6'b100000;
        end else begin
            if (key_released) begin
                num_sel <= {num_sel[0], num_sel[5:1]};
            end
        end

    end

    reg [23:0] time_setting_val_reg;

    always @(posedge clk) begin
        if (~reset_n) begin
            time_setting_val_reg <= 24'h000000;
        end else if (key_released) begin
            if (num_sel[5])
                time_setting_val_reg[23:20] <= key_bcd;
            if (num_sel[4])
                time_setting_val_reg[19:16] <= key_bcd;
            if (num_sel[3])
                time_setting_val_reg[15:12] <= (key_bcd[3] | (key_bcd[2] & key_bcd[1])) ? 4'h5 : key_bcd;
            if (num_sel[2])
                time_setting_val_reg[11:8] <= key_bcd;
            if (num_sel[1])
                time_setting_val_reg[7:4] <= (key_bcd[3] | (key_bcd[2] & key_bcd[1])) ? 4'h5 : key_bcd;
            if (num_sel[0])
                time_setting_val_reg[3:0] <= key_bcd;
        end
    end

    /* ----------------------------------------------------- 7-segment Display ----------------------------------------------------- */

    wire [23:0] time_to_display_bcd =
        state == GET_OPERATION ? operating_time :
        (state == GET_GESTURE | state == ADV_SET_GESTURE | state == SELF_CLEAN | state == L3 | state == L3_FORCED | state == OFF_READY | state == STANDBY_READY) ? gp_time :
        state == ADV_SET_REMIND ? operating_time_reminder : system_time;

    wire [63:0] time_to_display_7seg;

    generate 
        genvar i;
        for (i = 0; i < 6; i = i + 1) begin: tubegen
            bcd_to_tube tubes(
                .bcd(time_to_display_bcd[4*i+3:4*i]),
                .tube_content(time_to_display_7seg[8*i+7:8*i])
            );
        end
    endgenerate

    //display the state on the last two tubes
    state_to_tube tube_67 (
        .state(state),
        .tube_content(time_to_display_7seg[63:48])
    );

    reg [7:0] tube_ena_reg;
    wire [7:0] tube_ena_buffer;
    reg tube_hide;
    wire flash;

    timer #(
        .PERIOD(40_000_000)    // 0.5s flash period
    ) timer_tube_flash (
        .clk(clk),
        .reset(~reset_n),
        .halt(1'b0),
        .done(flash)
    );

    always @(posedge clk) begin
        if (~reset_n) begin
            tube_ena_reg <= 8'b0;
        end else if (flash) begin
            tube_hide <= ~tube_hide;
        end else if (tube_hide) begin
            tube_ena_reg <= tube_ena_buffer & {2'b11, ~num_sel};
        end else begin
            tube_ena_reg <= tube_ena_buffer;
        end
    end

    assign tube_ena = setting_something ? tube_ena_reg : tube_ena_buffer;

    // Tube Display
    tube_display tube_display (
        .clk(clk),
        .reset(~reset_n),
        .display_ena(timer_tube_done),          // update the display at lower frequency (500Hz)
        .tube_content(time_to_display_7seg),
        .tube_ena(tube_ena_buffer),
        .left_tube_content(left_tube_content),
        .right_tube_content(right_tube_content)
    );

    // Timer for the tube display
    wire timer_tube_done;                       // done signal from the timer

    timer #(
        .PERIOD(200_000)    // frequency = 100Mhz / 200_000 = 500Hz
    ) timer_tube (
        .clk(clk),
        .reset(~reset_n),
        .halt(1'b0),
        .done(timer_tube_done)
    );

    /* ----------------------------------------------------------- Other ----------------------------------------------------------- */

    // a register that shows whether you have ever used level 3 since the machine is last powered on
    reg tried_level_3;

    always @(posedge clk) begin
        if (~reset_n | state == OFF) begin
            tried_level_3 <= 1'b0;
        end else if (state == L3 | state == L3_FORCED) begin
            tried_level_3 <= 1'b1;
        end
    end

    // an led that indicates whether the lighting system is on (l_sws[7] == 1)
    assign l_leds[7] = l_sws[7] & state != OFF & state != OFF_READY;

    // Control the output of speaker. The vibration frequency is set as 'do_mid'. 
    parameter do_mid = 191095;
    parameter re_mid = 170271;
    parameter me_mid = 151676;
    parameter fa_mid = 142959;
    parameter so_mid = 127551;
    parameter la_mid = 113636;
    parameter si_mid = 101235;
    assign speaker_enable = 0;

    reg[21:0] temp_counter = 1'b0;
    always @(posedge clk) begin
        if (~reset_n) begin
            speaker <= 1'b0;
            temp_counter <= 1'b0;
        end else if (center_pressed) begin
            if (temp_counter < si_mid) begin
                temp_counter <= temp_counter + 1'b1;
            end else begin
                speaker <= ~speaker;
                temp_counter <= 0;
            end
        end else if (state == L2) begin
            if (temp_counter < fa_mid) begin
                temp_counter <= temp_counter + 1'b1;
            end else begin
                speaker <= ~speaker;
                temp_counter <= 0;
            end
        end else if (state == L1) begin
            if (temp_counter < do_mid) begin
                temp_counter <= temp_counter + 1'b1;
            end else begin
                speaker <= ~speaker;
                temp_counter <= 0;
            end
        end else begin
            speaker <= 1'b0;
            temp_counter <= 1'b0;
        end
    end

    /* ------------------------------------------------------- LEDs for debug ------------------------------------------------------- */

    assign r_leds = key_val;

    assign l_leds[5:0] = num_sel;

endmodule
