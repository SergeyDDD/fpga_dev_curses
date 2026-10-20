
`timescale 1 ns / 1 ps

module hub75_controller #(
    parameter int ADDR_WIDTH = 4
)(
    input  wire                  s_axi_aclk,        // Global Clock Signal
    input  wire                  s_axi_aresetn,     // Global Reset Signal. This Signal is Active LOW
    input  wire [ADDR_WIDTH-1:0] s_axi_awaddr,      // Write address (issued by master, acceped by Slave)
    input  wire [2:0]            s_axi_awprot,      // Write channel Protection type. This signal indicates the
    	                                            // privilege and security level of the transaction, and whether
                                                    // the transaction is a data access or an instruction access.
    input  wire                  s_axi_awvalid,     // Write address valid. This signal indicates that the master signaling
                                                    // valid write address and control information.
    output wire                  s_axi_awready,     // Write address ready. This signal indicates that the slave is ready
                                                    // to accept an address and associated control signals.
    input  wire [31:0]           s_axi_wdata,       // Write data (issued by master, acceped by Slave)
    input  wire [3:0]            s_axi_wstrb,       // Write strobes. This signal indicates which byte lanes hold
                                                    // valid data. There is one write strobe bit for each eight
                                                    // bits of the write data bus
    input  wire                  s_axi_wvalid,      // Write valid. This signal indicates that valid write
                                                    // data and strobes are available.
    output wire                  s_axi_wready,      // Write ready. This signal indicates that the slave
                                                    // can accept the write data.
    output wire  [1:0]           s_axi_bresp,       // Write response. This signal indicates the status
                                                    // of the write transaction.
    output wire                  s_axi_bvalid,      // Write response valid. This signal indicates that the channel
                                                    // is signaling a valid write response.
    input  wire                  s_axi_bready,      // Response ready. This signal indicates that the master
                                                    // can accept a write response.
    input  wire [ADDR_WIDTH-1:0] s_axi_araddr,      // Read address (issued by master, acceped by Slave)
    input  wire [2:0]            s_axi_arprot,      // Protection type. This signal indicates the privilege
                                                    // and security level of the transaction, and whether the
                                                    // transaction is a data access or an instruction access.
    input  wire                  s_axi_arvalid,     // Read address valid. This signal indicates that the channel
                                                    // is signaling valid read address and control information.
    output wire                  s_axi_arready,     // Read address ready. This signal indicates that the slave is
                                                    // ready to accept an address and associated control signals.
    output wire  [31:0]          s_axi_rdata,       // Read data (issued by slave)
    output wire  [1:0]           s_axi_rresp,       // Read response. This signal indicates the status of the
                                                    // read transfer.
    output wire                  s_axi_rvalid,      // Read valid. This signal indicates that the channel is
                                                    // signaling the required read data.
    input  wire                  s_axi_rready,      // Read ready. This signal indicates that the master can
                                                    // accept the read data and response information.
    // PANEL clock domain
    input  wire        panel_clk,
    input  wire        panel_resetn,
    output wire        panel_frame_end,

    // BRAM port B: 32-bit data, byte address, read latency = 1
    output wire        bram_clk,
    output wire        bram_rst,
    output wire [31:0] bram_addr,
    output wire        bram_en,
    output wire [3:0]  bram_we,
    output wire [31:0] bram_wrdata,
    input  wire [31:0] bram_rddata,
    input  wire        bram_rst_busy,

    // HUB-75 panel interface
    output wire [2:0]  panel_rgb_upper,
    output wire [2:0]  panel_rgb_lower,
    output wire        panel_shift_clk,
    output wire        panel_lat,
    output wire        panel_oe_n,
    output wire [4:0]  panel_row
);
    wire pnl_enable;
    wire pnl_buffer_select;
    wire [3:0] pnl_clk_half_ticks;
    wire [3:0] pnl_latch_ticks;
    wire [3:0] pnl_blank_ticks;
    wire [15:0] pnl_display_ticks;
    wire [15:0] pnl_brightness_ticks;
    wire pnl_frame_start;
    wire pnl_pixel_request;
    wire pnl_pixel_valid;
    wire [2:0] pnl_rgb_upper;
    wire [2:0] pnl_rgb_lower;

    // Either external reset restarts the panel pipeline.
    wire axi_common_resetn;
    assign axi_common_resetn = s_axi_aresetn && panel_resetn;
    (* ASYNC_REG = "TRUE" *) reg [1:0] pnl_reset_pipe;
    always @(posedge panel_clk or negedge axi_common_resetn) begin
        if (!axi_common_resetn) pnl_reset_pipe <= 0;
        else pnl_reset_pipe <= {pnl_reset_pipe[0], 1'b1};
    end
    wire pnl_core_resetn;
    wire pnl_reader_resetn;
    assign pnl_core_resetn = pnl_reset_pipe[1];
    assign pnl_reader_resetn = pnl_core_resetn && !bram_rst_busy;

    assign bram_clk = panel_clk;
    assign bram_rst = !pnl_core_resetn;
    assign bram_we = 4'b0000;
    assign bram_wrdata = 32'b0;

    hub75_axi_light #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) control (
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
        .panel_clk(panel_clk),
        .panel_resetn(pnl_core_resetn),
        .panel_frame_end(panel_frame_end),
        .panel_enable(pnl_enable),
        .panel_buffer_select(pnl_buffer_select),
        .panel_clk_half_ticks(pnl_clk_half_ticks),
        .panel_latch_ticks(pnl_latch_ticks),
        .panel_blank_ticks(pnl_blank_ticks),
        .panel_display_ticks(pnl_display_ticks),
        .panel_brightness_ticks(pnl_brightness_ticks)
    );

    bram_reader reader (
        .panel_clk(panel_clk),
        .panel_resetn(pnl_reader_resetn),
        .hub_frame_start(pnl_frame_start),
        .hub_buffer_select(pnl_buffer_select),
        .hub_pixel_request(pnl_pixel_request),
        .hub_rgb_upper(pnl_rgb_upper),
        .hub_rgb_lower(pnl_rgb_lower),
        .hub_pixel_valid(pnl_pixel_valid),
        .bram_addr(bram_addr),
        .bram_en(bram_en),
        .bram_rddata(bram_rddata),
        .bram_rst_busy(bram_rst_busy)
    );

    hub75_driver driver (
        .panel_clk(panel_clk),
        .panel_resetn(pnl_reader_resetn),
        .enable(pnl_enable),
        .clk_half_ticks(pnl_clk_half_ticks),
        .latch_ticks(pnl_latch_ticks),
        .blank_ticks(pnl_blank_ticks),
        .display_ticks(pnl_display_ticks),
        .brightness_ticks(pnl_brightness_ticks),
        .frame_end(panel_frame_end),
        .bram_frame_start(pnl_frame_start),
        .bram_pixel_request(pnl_pixel_request),
        .bram_rgb_upper(pnl_rgb_upper),
        .bram_rgb_lower(pnl_rgb_lower),
        .bram_pixel_valid(pnl_pixel_valid),
        .panel_rgb_upper(panel_rgb_upper),
        .panel_rgb_lower(panel_rgb_lower),
        .panel_shift_clk(panel_shift_clk),
        .panel_lat(panel_lat),
        .panel_oe_n(panel_oe_n),
        .panel_row(panel_row)
    );
endmodule
