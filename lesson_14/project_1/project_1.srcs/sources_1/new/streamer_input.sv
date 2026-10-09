`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/06/2026 10:45:13 PM
// Design Name:
// Module Name: streamer_input
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

// streamer_input inputs 8-bit pixel stream and puts into 16k x 32bit BRAM array
// Async FIFO buffer was used in the previous project  

module streamer_input (
    input  logic        pix_clk,
    input  logic        pix_reset, // Active LOW, as in the original module
    input  logic [7:0]  pix_data,
    input  logic        pix_start_frame
);
    localparam FRAME_SIZE = 320 * 200; // 64000 bytes

    // Streamer SM
    typedef enum logic [1:0] {
        SS_WAIT_FOR_START = 2'b01,
        SS_CAPTURING      = 2'b10,
        SS_FINISH         = 2'b11
    } stream_state_t;
    stream_state_t stream_state, next_stream_state;

    // Full frame buffer instead of the asynchronous FIFO.
    (* ram_style = "block" *) logic [31:0] frame_buffer [0:FRAME_SIZE/4-1];
    logic [13:0] frame_word_index;
    logic frame_wr_en;
    logic [13:0] frame_wr_addr;
    logic [31:0] frame_wr_data;

    // State machine driver
    always_ff @(posedge pix_clk or negedge pix_reset) begin
        if (!pix_reset)
            stream_state <= SS_WAIT_FOR_START;
        else
            stream_state <= next_stream_state;
    end

    // State machine processor
    logic [15:0] pixel_number;
    logic [7:0] pixel_data[4];
    logic [1:0] pixel_index;

    always_comb begin
        case (stream_state)
            SS_WAIT_FOR_START:  next_stream_state = (pix_start_frame) ? SS_CAPTURING : SS_WAIT_FOR_START;
            SS_CAPTURING:       next_stream_state = (pixel_number == 1) ? SS_FINISH : SS_CAPTURING;
            SS_FINISH:          next_stream_state = SS_WAIT_FOR_START;
            default:            next_stream_state = SS_WAIT_FOR_START;
        endcase
    end

    always_ff @(posedge pix_clk) begin
        frame_wr_en <= 1'b0;
        if (!pix_reset) begin
            pixel_number <= '0;
            pixel_index  <= '0;
            frame_word_index <= '0;
            frame_wr_en <= 1'b0;
            frame_wr_addr <= '0;
            frame_wr_data <= '0;
            for (int i = 0; i < 4; i++)
                pixel_data[i] <= '0;
        end
        else if (stream_state == SS_WAIT_FOR_START) begin
            pixel_number <= FRAME_SIZE;
            pixel_index <= 0;
            frame_word_index <= 0;
        end
        else if ((stream_state == SS_CAPTURING) || (stream_state == SS_FINISH)) begin
            pixel_data[pixel_index] <= pix_data;
            pixel_index <= pixel_index + 1'b1;
            pixel_number <= pixel_number - 1'b1;

            if ((pixel_index == 0) && (pixel_number != FRAME_SIZE)) begin
                frame_buffer[frame_word_index] <= {pixel_data[3], pixel_data[2], pixel_data[1], pixel_data[0]};
                frame_wr_data <= {pixel_data[3], pixel_data[2], pixel_data[1], pixel_data[0]};
                frame_wr_addr <= frame_word_index;
                frame_word_index <= frame_word_index + 1'b1;
                frame_wr_en <= 1'b1;
            end else
                frame_wr_en <= 1'b0;
        end
    end

    ila_0 ila_capture (
        .clk(pix_clk),
        .probe0(pix_start_frame),
        .probe1(stream_state),
        .probe2(pix_data),
        .probe3(frame_wr_data),
        .probe4(frame_wr_addr),
        .probe5(frame_wr_en)
    );

endmodule
