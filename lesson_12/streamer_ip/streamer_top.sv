`timescale 1ns / 1ps
module streamer_top #(
    parameter int ADDR_WIDTH = 4
)(
    input  logic                  s_axi_aclk,      // Global Clock Signal
    input  logic                  s_axi_aresetn,   // Global Reset Signal. This Signal is Active LOW
    input  logic [ADDR_WIDTH-1:0] s_axi_awaddr,    // Write address (issued by master, acceped by Slave)
    input  logic [2:0]            s_axi_awprot,    // Write channel Protection type. This signal indicates the
    		                                   // privilege and security level of the transaction, and whether
    		                                   // the transaction is a data access or an instruction access.
    input  logic                  s_axi_awvalid,   // Write address valid. This signal indicates that the master signaling
                                                   // valid write address and control information.
    output logic                  s_axi_awready,   // Write address ready. This signal indicates that the slave is ready
    		                                   // to accept an address and associated control signals.
    input  logic [31:0]           s_axi_wdata,     // Write data (issued by master, acceped by Slave)
    input  logic [3:0]            s_axi_wstrb,     // Write strobes. This signal indicates which byte lanes hold
    		                                   // valid data. There is one write strobe bit for each eight
    		                                   // bits of the write data bus
    input  logic                  s_axi_wvalid,    // Write valid. This signal indicates that valid write
    		                                   // data and strobes are available.
    output logic                  s_axi_wready,    // Write ready. This signal indicates that the slave
    		                                   // can accept the write data.
    output logic  [1:0]           s_axi_bresp,     // Write response. This signal indicates the status
    		                                   // of the write transaction.
    output logic                  s_axi_bvalid,    // Write response valid. This signal indicates that the channel
    		                                   // is signaling a valid write response.
    input  logic                  s_axi_bready,    // Response ready. This signal indicates that the master
    		                                   // can accept a write response.
    input  logic [ADDR_WIDTH-1:0] s_axi_araddr,    // Read address (issued by master, acceped by Slave)
    input  logic [2:0]            s_axi_arprot,    // Protection type. This signal indicates the privilege
        		                           // and security level of the transaction, and whether the
    		                                   // transaction is a data access or an instruction access.
    input  logic                  s_axi_arvalid,   // Read address valid. This signal indicates that the channel
    		                                   // is signaling valid read address and control information.
    output logic                  s_axi_arready,   // Read address ready. This signal indicates that the slave is
    		                                   // ready to accept an address and associated control signals.
    output logic  [31:0]          s_axi_rdata,     // Read data (issued by slave)
    output logic  [1:0]           s_axi_rresp,     // Read response. This signal indicates the status of the
    		                                   // read transfer.
    output logic                  s_axi_rvalid,    // Read valid. This signal indicates that the channel is
    		                                   // signaling the required read data.
    input  logic                  s_axi_rready,    // Read ready. This signal indicates that the master can
    		                                   // accept the read data and response information.

    input logic pix_clk,
    input logic [7:0] pix_data,
    input logic pix_start_frame,
    output wire [31:0] m_axis_tdata,
    output wire m_axis_tvalid,
    input logic m_axis_tready,
    output wire m_axis_tlast,
    output wire [3:0] m_axis_tkeep,
    output wire fifo_full
);
    wire start, capture_busy, fifo_empty, fifo_rd_en, frame_done;
    wire [31:0] fifo_rd_data;
    logic transfer_active;
    // STATUS stays busy until the last AXIS beat is accepted.
    wire stream_busy = capture_busy || transfer_active || !fifo_empty;
    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn)
        if (!s_axi_aresetn) transfer_active <= 1'b0;
        else if (start) transfer_active <= 1'b1;
        else if (frame_done) transfer_active <= 1'b0;

    streamer_control #(.ADDR_WIDTH(ADDR_WIDTH)) control (
        .s_axi_aclk(s_axi_aclk),
        .s_axi_aresetn(s_axi_aresetn),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arprot(s_axi_arprot),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        .start(start), .stream_busy(stream_busy)
    );
    streamer_input capture (
        .aclk(s_axi_aclk), .aresetn(s_axi_aresetn),
        .axi_start(start), .axi_busy(capture_busy),
        .pix_clk(pix_clk), .pix_data(pix_data),
        .pix_start_frame(pix_start_frame),
        .fifo_rd_en(fifo_rd_en), .fifo_rd_data(fifo_rd_data),
        .fifo_empty(fifo_empty), .fifo_full(fifo_full)
    );
    streamer_axis #(.FRAME_WORDS(16000)) axis (
        .aclk(s_axi_aclk), .aresetn(s_axi_aresetn),
        .fifo_rd_data(fifo_rd_data), .fifo_empty(fifo_empty),
        .fifo_rd_en(fifo_rd_en),
        .m_axis_tdata(m_axis_tdata), .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready), .m_axis_tlast(m_axis_tlast),
        .m_axis_tkeep(m_axis_tkeep), .frame_done(frame_done)
    );
endmodule
