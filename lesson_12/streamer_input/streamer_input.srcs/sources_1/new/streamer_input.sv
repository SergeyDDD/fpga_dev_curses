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


module streamer_input (
    input  logic        aclk,           // Global Clock Signal
    input  logic        aresetn,        // Global Reset Signal. This Signal is Active LOW

    // Streamer control interface
    input  logic        axi_start,
    output logic        axi_busy,

    // Streamer input data interface
    input  logic        pix_clk,
    input  logic [7:0]  pix_data,
    input  logic        pix_start_frame,

    input  logic        fifo_rd_en,
    output logic [31:0] fifo_rd_data,
    output logic        fifo_empty,
    output logic        fifo_full
);

    localparam FRAME_SIZE = 320 * 200; // 64000 bytes

    // Streamer SM
    typedef enum logic [1:0] {
        SS_IDLE           = 2'b00,
        SS_WAIT_FOR_START = 2'b01,
        SS_CAPTURING      = 2'b10,
        SS_FINISH         = 2'b11
    } stream_state_t;
    stream_state_t stream_state, next_stream_state;

    // Async FIFO
    logic fifo_wr_en;
    logic [31:0] fifo_in_data;

    (* ASYNC_REG = "TRUE" *) logic [1:0] pix_reset_dms;
    logic pix_reset;
    assign pix_reset = pix_reset_dms[1];

    (* ASYNC_REG = "TRUE" *) logic [1:0] pix_busy_dms;
    logic pix_busy;
    assign pix_busy = pix_busy_dms[1];

    (* ASYNC_REG = "TRUE" *) logic [1:0] axi_done_dms;       // 'dms' means De MetaState 
    logic axi_done;
    logic pix_done;
    assign pix_done = (stream_state == SS_FINISH);
    assign axi_done = axi_done_dms[1];

    async_fifo input_fifo (
        .rst     (!pix_reset),
    
        .wr_clk  (pix_clk),
        .wr_data (fifo_in_data),
        .wr_en   (fifo_wr_en),
        .full    (fifo_full),
    
        .rd_clk  (aclk),
        .rd_data (fifo_rd_data),
        .rd_en   (fifo_rd_en),
        .empty   (fifo_empty)
    );

    // AXI_STRAM_ENABLE- enables stream capturing
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn)
            axi_done_dms <= '0;
        else
            axi_done_dms <= {axi_done_dms[0], pix_done};
    end

    // AXI_STRAM_ENABLE- enables stream capturing
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn)
            axi_busy <= '0;
        else if (axi_done)
            axi_busy <= 0;
        else if (axi_start)
            axi_busy <= 1;
    end

    // Trace RESET signal from AXI to PIX clock domain
    always_ff @(posedge pix_clk or negedge aresetn) begin
        if (!aresetn) pix_reset_dms <= '0;
        else pix_reset_dms <= {pix_reset_dms[0],1'b1};
    end
    
    // Trace AXI_BUSY signal from AXI to PIX clock domain
    always_ff @(posedge pix_clk or negedge pix_reset) begin
        if (!pix_reset) pix_busy_dms <= '0;
        else pix_busy_dms <= {pix_busy_dms[0], axi_busy};
    end

    // State machine driver
    always_ff @(posedge pix_clk or negedge pix_reset) begin
        if (!pix_reset)
            stream_state <= SS_IDLE;
        else
            stream_state <= next_stream_state;
    end

    // State machine processor
    logic [15:0] pixel_number;
    logic [7:0] pixel_data[4];
    logic [1:0] pixel_index;

    always_comb begin
        case (stream_state)
            SS_IDLE:            next_stream_state = (pix_busy) ? SS_WAIT_FOR_START : SS_IDLE;
            SS_WAIT_FOR_START:  next_stream_state = (pix_start_frame) ? SS_CAPTURING : SS_WAIT_FOR_START;
            SS_CAPTURING:       next_stream_state = (pixel_number == 1) ? SS_FINISH : SS_CAPTURING;
            SS_FINISH:          next_stream_state = (pix_busy) ? SS_FINISH : SS_IDLE;
            default:            next_stream_state = SS_IDLE;
        endcase
    end

    always_ff @(posedge pix_clk) begin
        if (!pix_reset) begin
            pixel_number <= '0;
            pixel_index  <= '0;
            fifo_in_data <= '0;
            for (int i = 0; i < 4; i++)
                pixel_data[i] <= '0;
        end
        else if (stream_state == SS_WAIT_FOR_START) begin
            pixel_number <= FRAME_SIZE;
            pixel_index <= 0;
        end
        else if ((stream_state == SS_CAPTURING) || (stream_state == SS_FINISH)) begin
            pixel_data[pixel_index] <= pix_data;
            pixel_index <= pixel_index + 1'b1;
            pixel_number <= pixel_number - 1'b1;

            if ((pixel_index == 0) && (pixel_number != FRAME_SIZE)) begin
                fifo_in_data <= {pixel_data[3], pixel_data[2], pixel_data[1], pixel_data[0]};
                fifo_wr_en <= 1'b1;
            end else
                fifo_wr_en <= 1'b0;
        end
    end

endmodule
