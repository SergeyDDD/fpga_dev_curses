`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2026 10:48:20 PM
// Design Name: 
// Module Name: streamer_input_tb
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

module streamer_input_tb ();

localparam PERIODS = 70000;

logic       aclk;           // Global Clock Signal
logic       aresetn;        // Global Reset Signal. This Signal is Active LOW

// Streamer control interface
logic       start;
logic       busy;

// Streamer input data interface
logic       pix_clk;
logic [7:0] pix_data;
logic       start_frame;

int         pix_periods;

logic        fifo_rd_en;
logic [31:0] fifo_rd_data;
logic        fifo_empty;
logic        fifo_full;

streamer_input dut (
    .aclk (aclk),
    .aresetn (aresetn),
    .axi_start (start),
    .axi_busy (busy),
    .pix_clk (pix_clk),
    .pix_data (pix_data),
    .pix_start_frame (start_frame),
    .fifo_rd_en   (fifo_rd_en),
    .fifo_rd_data (fifo_rd_data),
    .fifo_empty   (fifo_empty),
    .fifo_full    (fifo_full)
);

// Clock definition
always #10 aclk = ~aclk;
always #300 pix_clk = ~pix_clk;


initial begin
    aclk = '0;
    aresetn = '0;
    start = '0;
    pix_clk = '0;
    pix_data = '0;
    start_frame = '0;
    pix_periods = 0;

    assign fifo_rd_en = aresetn && !fifo_empty;

    repeat (10) @(negedge aclk);
    aresetn = 1;

    repeat (10) @(negedge aclk);

    start = 1;
    @(negedge aclk);
    start = 0;

    for (; pix_periods < PERIODS; pix_periods++) begin
        @(negedge pix_clk);
        pix_data = $urandom_range(0, 255);
        start_frame = (pix_periods == 20);
    end

    @(negedge pix_clk);
    $finish;
end

endmodule
