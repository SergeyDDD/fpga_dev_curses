`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2026 08:34:24 PM
// Design Name: 
// Module Name: streamer_top
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


module streamer_top (
    input  wire  clk_50m,
    output wire  led_busy,
    output logic led_done = 1'b0
);
    // Startup reset, active LOW, shared by source and capture.
    logic [31:0] reset_count = '0;
    logic pix_reset = 1'b0;
    
    localparam integer RESET_CYCLES = 1024;
    localparam integer FRAME_PERIOD = 64004;

    always_ff @(posedge clk_50m) begin
        if (!pix_reset) begin
            if (reset_count == RESET_CYCLES - 1)
                pix_reset <= 1'b1;
            else
                reset_count <= reset_count + 1'b1;
        end
    end

    wire [7:0] pix_data;
    wire pix_start_frame;

    stream_generator #(
        .FRAME_PERIOD(FRAME_PERIOD)
    ) source (
        .clk(clk_50m),
        .resetn(pix_reset),
        .pix_data(pix_data),
        .pix_start_frame(pix_start_frame)
    );

    streamer_input capture (
        .pix_clk(clk_50m),
        .pix_reset(pix_reset),
        .pix_data(pix_data),
        .pix_start_frame(pix_start_frame)
    );

    // 50 MHz / (2 * 5,000,000) = 5 Hz, 50% duty cycle.
    localparam integer LED_HALF_PERIOD = 5_000_000;
    logic [22:0] led_count = '0;
    assign led_busy = pix_start_frame;
    always_ff @(posedge clk_50m) begin
        if (!pix_reset) begin
            led_count <= '0;
            led_done <= 1'b0;
        end else if (led_count == LED_HALF_PERIOD - 1) begin
            led_count <= '0;
            led_done <= ~led_done;
        end else begin
            led_count <= led_count + 1'b1;
        end
    end
endmodule
