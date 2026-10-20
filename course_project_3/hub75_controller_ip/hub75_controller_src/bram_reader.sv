`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 07:20:45 PM
// Design Name: 
// Module Name: bram_reader
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

// 128x64: one byte = {2'b0, RGB_lower[2:0], RGB_upper[2:0]}.
// Each frame is 4096 bytes. Buffer A starts at 0, B at 4096.
// BRAM Controller-mode port: byte addresses, 32-bit data, latency 1,
// All logic uses panel_clk.

// Protocol: frame_start has priority and cancels any pending read.
// Pulse next_pair for one clock only when !busy && !frame_done,
// after frame_start. Requests while busy are ignored.
// pair_valid pulses for one clock; RGB stays stable until next result.
// frame_done stays high after pair 4095 until frame_start or reset.

module bram_reader (
    input  wire        panel_clk,
    input  wire        panel_resetn,
    
    // HUB-75 pixel request interface
    input  wire        hub_frame_start,     // Start frame - reset pixel address
    input  wire        hub_buffer_select,   // Buffer A / Buffer B pointer
    input  wire        hub_pixel_request,   // Next pixel request
    output reg  [2:0]  hub_rgb_upper,       // Upper pixel
    output reg  [2:0]  hub_rgb_lower,       // Lower pixel
    output reg         hub_pixel_valid,     // Pixel valid

    // BRAM port interface
    output reg  [31:0] bram_addr,
    output reg         bram_en,
    input  wire [31:0] bram_rddata,
    input  wire        bram_rst_busy
);

    // Reader SM
    typedef enum logic [2:0] {
        SM_READ_BRAM    = 3'd0,
        SM_WAIT_BRAM    = 3'd1,
        SM_GET_BYTE_0   = 3'd2,
        SM_GET_BYTE_1   = 3'd3,
        SM_GET_BYTE_2   = 3'd4,
        SM_GET_BYTE_3   = 3'd5
    } reader_state_t;
    reader_state_t reader_state;

    reg [31:0] word_cache;
    wire [7:0] word_bytes [0:3];
    assign {word_bytes[3], word_bytes[2], word_bytes[1], word_bytes[0]} = word_cache;

    wire reset;
    reg pixel_valid;

    assign reset = !panel_resetn || bram_rst_busy;
    assign hub_pixel_valid = !reset && pixel_valid;

    // Process BRAM interface
    always_ff @(posedge panel_clk or posedge reset) begin
        if (reset) begin
            bram_addr <= 0;
            bram_en <= 0;
            word_cache <= 0;
        end else if (hub_frame_start) begin
            bram_addr <= hub_buffer_select ? 32'h1000 : 32'h0000;
            bram_en <= 0;
            word_cache <= 0;
        end else begin
            if (reader_state == SM_READ_BRAM && hub_pixel_request)
                bram_en <= 1;
            if (reader_state == SM_WAIT_BRAM)
                bram_en <= 0;
            if (reader_state == SM_GET_BYTE_0) begin
                word_cache <= bram_rddata;
                bram_addr <= bram_addr + 32'd4;
            end
        end
    end

    // Process HUB interface
    always_ff @(posedge panel_clk or posedge reset) begin
        if (reset || hub_frame_start) begin
            reader_state <= SM_READ_BRAM;
            hub_rgb_upper <= 0;
            hub_rgb_lower <= 0;
            pixel_valid <= 0;
        end
        else begin
            case (reader_state)
                SM_READ_BRAM: if (hub_pixel_request) begin
                    pixel_valid <= 0;
                    reader_state <= SM_WAIT_BRAM;
                end
                SM_WAIT_BRAM: reader_state <= SM_GET_BYTE_0;
                SM_GET_BYTE_0: begin
                    hub_rgb_upper <= bram_rddata[6:4];
                    hub_rgb_lower <= bram_rddata[2:0];
                    pixel_valid <= 1;
                    reader_state <= SM_GET_BYTE_1;
                end
                SM_GET_BYTE_1: if (hub_pixel_request) begin
                    hub_rgb_upper <= word_bytes[1][6:4];
                    hub_rgb_lower <= word_bytes[1][2:0];
                    reader_state <= SM_GET_BYTE_2;
                end
                SM_GET_BYTE_2: if (hub_pixel_request) begin
                    hub_rgb_upper <= word_bytes[2][6:4];
                    hub_rgb_lower <= word_bytes[2][2:0];
                    reader_state <= SM_GET_BYTE_3;
                end
                SM_GET_BYTE_3: if (hub_pixel_request) begin
                    hub_rgb_upper <= word_bytes[3][6:4];
                    hub_rgb_lower <= word_bytes[3][2:0];
                    reader_state <= SM_READ_BRAM;
                end
                default: begin
                    reader_state <= SM_READ_BRAM;
                    pixel_valid <= 0;
                end
            endcase
        end
    end

endmodule
