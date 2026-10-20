`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 10:57:39 PM
// Design Name: 
// Module Name: hub75_driver
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

module hub75_driver (
    input  wire        panel_clk,
    input  wire        panel_resetn,
    input  wire        enable,

    // Parameters from AXI
    input  wire [3:0]  clk_half_ticks,
    input  wire [3:0]  latch_ticks,
    input  wire [3:0]  blank_ticks,
    input  wire [15:0] display_ticks,
    input  wire [15:0] brightness_ticks,

    // End of frame interrupt
    output reg         frame_end,

    // BRAM READER interface
    output reg         bram_frame_start,
    output reg         bram_pixel_request,
    input  wire [2:0]  bram_rgb_upper,
    input  wire [2:0]  bram_rgb_lower,
    input  wire        bram_pixel_valid,
    
    // HUB-75 panel interface
    output reg  [2:0]  panel_rgb_upper,
    output reg  [2:0]  panel_rgb_lower,
    output reg         panel_shift_clk,
    output reg         panel_lat,
    output reg         panel_oe_n,
    output reg  [4:0]  panel_row
);
    // State Machine
    typedef enum logic [3:0] {
        SM_START_FRAME,
        SM_FRAME_SETTLE,
        SM_REQUEST_PIXEL,
        SM_REQUEST_SETTLE,
        SM_WAIT_PIXEL,
        SM_CLK_LOW,
        SM_CLK_HIGH,
        SM_ROW_SETUP,
        SM_LATCH,
        SM_POST_LATCH,
        SM_DISPLAY,
        SM_END_ROW
    } state_t;
    state_t state;

    reg [6:0] column;
    reg [15:0] ticks;

    wire [3:0] half_period = clk_half_ticks == 0 ? 4'd1 : clk_half_ticks;
    wire [3:0] latch_period = latch_ticks == 0 ? 4'd1 : latch_ticks;
    wire [3:0] blank_period = blank_ticks == 0 ? 4'd1 : blank_ticks;
    wire [15:0] display_period = display_ticks == 0 ? 16'd1 : display_ticks;
    wire [15:0] pnl_brightness_period = brightness_ticks > display_period ? display_period : brightness_ticks;


    // Process BRAM READER interface 
    always_ff @(posedge panel_clk) begin
        if (!panel_resetn) begin
            bram_frame_start <= 0;
            bram_pixel_request <= 0;
            panel_rgb_upper <= 0;
            panel_rgb_lower <= 0;
        end else begin
            bram_frame_start <= 0;
            bram_pixel_request <= 0;
            if (enable) begin
                if (state == SM_START_FRAME)     bram_frame_start <= 1;
                if (state == SM_REQUEST_PIXEL)   bram_pixel_request <= 1;
                if (state == SM_WAIT_PIXEL) begin
                    if (bram_pixel_valid) begin
                        panel_rgb_upper <= bram_rgb_upper;
                        panel_rgb_lower <= bram_rgb_lower;
                    end
                end
            end
        end
    end


    // Process HUB interface 
    always_ff @(posedge panel_clk) begin
        if (!panel_resetn) begin
            state <= SM_START_FRAME;
            column <= 0;
            ticks <= 0;
            frame_end <= 0;
            panel_shift_clk <= 0;
            panel_lat <= 0;
            panel_oe_n <= 1;
            panel_row <= 0;
        end else begin
            frame_end <= 0;
            if (!enable) begin
                state <= SM_START_FRAME;
                column <= 0;
                ticks <= 0;
                panel_row <= 0;
                panel_oe_n <= 1;
                panel_shift_clk <= 0;
                panel_lat <= 0;
            end else begin

                case (state)
                    SM_START_FRAME: begin
                        column <= 0;
                        panel_row <= 0;
                        panel_oe_n <= 1;
                        panel_shift_clk <= 0;
                        panel_lat <= 0;
                        state <= SM_FRAME_SETTLE;
                    end
                    
                    SM_FRAME_SETTLE:    state <= SM_REQUEST_PIXEL;
                    SM_REQUEST_PIXEL:   state <= SM_REQUEST_SETTLE;
                    SM_REQUEST_SETTLE: state <= SM_WAIT_PIXEL;

                    SM_WAIT_PIXEL: begin
                        if (bram_pixel_valid) begin
                            ticks <= 0;
                            state <= SM_CLK_LOW;
                        end
                    end
                    
                    SM_CLK_LOW: begin
                        if (ticks == (half_period - 4'd1)) begin
                            panel_shift_clk <= 1;
                            ticks <= 0;
                            state <= SM_CLK_HIGH;
                        end else ticks <= ticks + 1'b1;
                    end
                    
                    SM_CLK_HIGH: begin
                        if (ticks == (half_period - 4'd1)) begin
                            panel_shift_clk <= 0;
                            ticks <= 0;
                            if (column == 127) begin
                                state <= SM_ROW_SETUP;
                            end else begin
                                column <= column + 1'b1;
                                state <= SM_REQUEST_PIXEL;
                            end
                        end else ticks <= ticks + 1'b1;
                    end
                    
                    SM_ROW_SETUP: begin
                        if (ticks == (blank_period - 4'd1)) begin
                            panel_lat <= 1;
                            ticks <= 0;
                            state <= SM_LATCH;
                        end else ticks <= ticks + 1'b1;
                    end
                    
                    SM_LATCH: begin
                        if (ticks == (latch_period - 4'd1)) begin
                            panel_lat <= 0;
                            ticks <= 0;
                            state <= SM_POST_LATCH;
                        end else ticks <= ticks + 1'b1;
                    end
                    
                    SM_POST_LATCH: begin
                        if (ticks == (blank_period - 4'd1)) begin
                            panel_oe_n <= (pnl_brightness_period == 0);
                            ticks <= 0;
                            state <= SM_DISPLAY;
                        end else ticks <= ticks + 1'b1;
                    end
                    
                    SM_DISPLAY: begin
                        if ((pnl_brightness_period == 0) ||
                            (ticks == (pnl_brightness_period - 16'd1)))
                            panel_oe_n <= 1;
                        if (ticks == (display_period - 16'd1)) begin
                            panel_oe_n <= 1;
                            ticks <= 0;
                            state <= SM_END_ROW;
                        end else ticks <= ticks + 1'b1;
                    end
                    
                    SM_END_ROW: begin
                        column <= 0;
                        if (panel_row == 31) begin
                            frame_end <= 1;
                            state <= SM_START_FRAME;
                        end else begin
                            panel_row <= panel_row + 1'b1;
                            state <= SM_REQUEST_PIXEL;
                        end
                    end
                    
                    default: begin
                        state <= SM_START_FRAME;
                        panel_oe_n <= 1;
                        panel_shift_clk <= 0;
                        panel_lat <= 0;
                    end
                endcase
            end
        end
    end
endmodule
