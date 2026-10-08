`timescale 1ns / 1ps
// FIFO FWFT -> AXI4-Stream. One output register, as in axis_doubler.
// One frame contains FRAME_WORDS accepted FIFO words; no arithmetic.

module streamer_axis #(
    parameter int FRAME_WORDS = 16000
)(
    input  logic aclk,                  // Global Clock Signal
    input  logic aresetn,               // Global Reset Signal. This Signal is Active LOW

    input  logic [31:0] fifo_rd_data,   // FIFO read data
    input  logic fifo_empty,            // FIFO empty
    output logic fifo_rd_en,            // FIFO read enable

    output logic [31:0] m_axis_tdata,   //
    output logic m_axis_tvalid,
    input  logic m_axis_tready,
    output logic m_axis_tlast,
    output logic [3:0] m_axis_tkeep,
    output logic frame_done
);
    localparam int COUNT_WIDTH = (FRAME_WORDS > 1) ? $clog2(FRAME_WORDS) : 1;
    logic [COUNT_WIDTH-1:0] word_index;
    wire output_ready = !m_axis_tvalid || m_axis_tready;
    assign fifo_rd_en = aresetn && output_ready && !fifo_empty;
    assign m_axis_tkeep = 4'b1111;
    assign frame_done = aresetn && m_axis_tvalid && m_axis_tready && m_axis_tlast;

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            m_axis_tdata <= '0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast <= 1'b0;
            word_index <= '0;
        end else if (output_ready) begin
            m_axis_tvalid <= !fifo_empty;
            if (!fifo_empty) begin
                m_axis_tdata <= fifo_rd_data;
                m_axis_tlast <= (word_index == FRAME_WORDS-1);
                if (word_index == FRAME_WORDS-1) word_index <= '0;
                else word_index <= word_index + 1'b1;
            end else m_axis_tlast <= 1'b0;
        end
    end
endmodule
