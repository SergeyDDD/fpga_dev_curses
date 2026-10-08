`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2026 01:30:29 AM
// Design Name: 
// Module Name: async_fifo
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


module async_fifo #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH = 32
) (
    input  logic                  rst,
    input  logic                  wr_clk,
    input  logic [DATA_WIDTH-1:0] wr_data,
    input  logic                  wr_en,
    output logic                  full,
    input  logic                  rd_clk,
    output logic [DATA_WIDTH-1:0] rd_data,
    input  logic                  rd_en,
    output logic                  empty
);
    (* ASYNC_REG = "TRUE" *) logic [1:0] wr_reset_pipe = 2'b11;
    (* ASYNC_REG = "TRUE" *) logic [1:0] rd_reset_pipe = 2'b11;

    always_ff @(posedge wr_clk)
        wr_reset_pipe <= {wr_reset_pipe[0],rst};
    always_ff @(posedge rd_clk)
        rd_reset_pipe <= {rd_reset_pipe[0],rst};

    logic core_full;
    logic core_empty;
    logic wr_rst_busy;
    logic rd_rst_busy;

    assign full  = wr_reset_pipe[1] || wr_rst_busy || core_full;
    assign empty = rd_reset_pipe[1] || rd_rst_busy || core_empty;

    xpm_fifo_async #(
        .FIFO_WRITE_DEPTH(DEPTH),
        .WRITE_DATA_WIDTH(DATA_WIDTH),
        .READ_DATA_WIDTH(DATA_WIDTH),
        .FIFO_MEMORY_TYPE("auto"),
        .READ_MODE("fwft"),
        .FIFO_READ_LATENCY(0),
        .CDC_SYNC_STAGES(2),
        .RELATED_CLOCKS(0),
        .ECC_MODE("no_ecc"),
        .USE_ADV_FEATURES("0000"),
        .PROG_EMPTY_THRESH(5),
        .PROG_FULL_THRESH(7),
        .SIM_ASSERT_CHK(1)
    ) core (
        .rst(wr_reset_pipe[1]),
        .wr_clk(wr_clk),
        .din(wr_data),
        .wr_en(wr_en && !full),
        .full(core_full),
        .wr_rst_busy(wr_rst_busy),
        .rd_clk(rd_clk),
        .dout(rd_data),
        .rd_en(rd_en && !empty),
        .empty(core_empty),
        .rd_rst_busy(rd_rst_busy),
        .sleep(1'b0),
        .injectsbiterr(1'b0),
        .injectdbiterr(1'b0),
        .almost_empty(),
        .almost_full(),
        .data_valid(),
        .dbiterr(),
        .sbiterr(),
        .overflow(),
        .underflow(),
        .prog_empty(),
        .prog_full(),
        .rd_data_count(),
        .wr_data_count(),
        .wr_ack()
    );
endmodule
