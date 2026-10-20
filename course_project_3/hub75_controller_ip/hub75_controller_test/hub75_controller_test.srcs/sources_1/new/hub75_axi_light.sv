`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 02:05:29 AM
// Design Name: 
// Module Name: hub75_axi_light
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

module hub75_axi_light #(
    parameter int ADDR_WIDTH = 4
)(
    input  logic                  s_axi_aclk,       // Global Clock Signal
    input  logic                  s_axi_aresetn,    // Global Reset Signal. This Signal is Active LOW
    input  logic [ADDR_WIDTH-1:0] s_axi_awaddr,     // Write address (issued by master, acceped by Slave)
    input  logic [2:0]            s_axi_awprot,     // Write channel Protection type. This signal indicates the
                                                    // privilege and security level of the transaction, and whether
                                                    // the transaction is a data access or an instruction access.
    input  logic                  s_axi_awvalid,    // Write address valid. This signal indicates that the master signaling
                                                    // valid write address and control information.
    output logic                  s_axi_awready,    // Write address ready. This signal indicates that the slave is ready
                                                    // to accept an address and associated control signals.
    input  logic [31:0]           s_axi_wdata,      // Write data (issued by master, acceped by Slave)
    input  logic [3:0]            s_axi_wstrb,      // Write strobes. This signal indicates which byte lanes hold
                                                    // valid data. There is one write strobe bit for each eight
                                                    // bits of the write data bus
    input  logic                  s_axi_wvalid,     // Write valid. This signal indicates that valid write
                                                    // data and strobes are available.
    output logic                  s_axi_wready,     // Write ready. This signal indicates that the slave
                                                    // can accept the write data.
    output logic  [1:0]           s_axi_bresp,      // Write response. This signal indicates the status
                                                    // of the write transaction.
    output logic                  s_axi_bvalid,     // Write response valid. This signal indicates that the channel
                                                    // is signaling a valid write response.
    input  logic                  s_axi_bready,     // Response ready. This signal indicates that the master
                                                    // can accept a write response.
    input  logic [ADDR_WIDTH-1:0] s_axi_araddr,     // Read address (issued by master, acceped by Slave)
    input  logic [2:0]            s_axi_arprot,     // Protection type. This signal indicates the privilege
                                                    // and security level of the transaction, and whether the
                                                    // transaction is a data access or an instruction access.
    input  logic                  s_axi_arvalid,    // Read address valid. This signal indicates that the channel
                                                    // is signaling valid read address and control information.
    output logic                  s_axi_arready,    // Read address ready. This signal indicates that the slave is
                                                    // ready to accept an address and associated control signals.
    output logic  [31:0]          s_axi_rdata,      // Read data (issued by slave)
    output logic  [1:0]           s_axi_rresp,      // Read response. This signal indicates the status of the
                                                    // read transfer.
    output logic                  s_axi_rvalid,     // Read valid. This signal indicates that the channel is
                                                    // signaling the required read data.
    input  logic                  s_axi_rready,     // Read ready. This signal indicates that the master can
                                                    // accept the read data and response information.
    // Internal control interface
    input  wire        panel_clk,
    input  wire        panel_resetn,
    input  wire        panel_frame_end,
    output reg         panel_enable,
    output reg         panel_buffer_select,
    output reg [3:0]   panel_clk_half_ticks,
    output reg [3:0]   panel_latch_ticks,
    output reg [3:0]   panel_blank_ticks,
    output reg [15:0]  panel_display_ticks,
    output reg [15:0]  panel_brightness_ticks
);
    typedef enum logic [ADDR_WIDTH-1:0] {
        REG_CONTROL   = 0,      // CONTROL (R/W)
                                //   [0] Enable
                                //   [1] Buffer (0=A,1=B)
        REG_STATUS    = 4,      // STATUS (RO)
                                //   [0] Enabled
                                //   [1] Active buffer
        REG_TIMING    = 8,      // TIMING (R/W)
                                //   [3:0]  CLK half
                                //   [7:4]  LAT
                                //   [11:8] Blank
        REG_DISPLAY   = 12      // DISPLAY (R/W)
                                //   [15:0]  Display duration
                                //   [31:16] Brightness duration 
    } register_id_t;

    localparam [1:0] OKAY = 2'b00, SLVERR = 2'b10;
    localparam [1:0] AXI_IDLE = 0, AXI_WAIT_RESPONSE = 1, AXI_WAIT_RELEASE = 2;

    reg [1:0] axi_state;
    reg axi_aw_pending;
    reg axi_w_pending;
    reg axi_ar_pending;
    reg [ADDR_WIDTH-1:0] axi_awaddr_saved;
    reg [ADDR_WIDTH-1:0] axi_araddr_saved;
    reg [31:0] axi_wdata_saved;
    reg [3:0] axi_wstrb_saved;

    // Hold the entire command unchanged until the handshake completes.
    reg axi_command_write;
    reg [ADDR_WIDTH-1:0] axi_command_address;
    reg [31:0] axi_command_data;
    reg [3:0] axi_command_strobe;
    reg axi_param_change_request;
    reg pnl_param_applied_response;
    reg [31:0] pnl_response_data;
    reg [1:0] pnl_response_code;

    reg pnl_parameter_enable;
    reg pnl_parameter_buffer;
    reg [11:0] pnl_parameter_timing;
    reg [31:0] pnl_parameter_display;

    // Reset control in both domains, synchronize release per clock.
    wire axi_common_resetn;
    assign axi_common_resetn = s_axi_aresetn && panel_resetn;

    // CDC: Merge s_axi_aresetn and panel_resetn for AXI domain
    (* ASYNC_REG = "TRUE" *) reg [1:0] axi_reset_pipe;
    always @(posedge s_axi_aclk or negedge axi_common_resetn)
        if (!axi_common_resetn) axi_reset_pipe <= 0;
        else axi_reset_pipe <= {axi_reset_pipe[0], 1'b1};
    wire axi_resetn;
    assign axi_resetn = axi_reset_pipe[1];

    // CDC: Panel Ready for PANEL domain
    (* ASYNC_REG = "TRUE" *) reg [1:0] pnl_reset_pipe;
    always @(posedge panel_clk or negedge axi_common_resetn)
        if (!axi_common_resetn) pnl_reset_pipe <= 0;
        else pnl_reset_pipe <= {pnl_reset_pipe[0], 1'b1};
    wire pnl_resetn;
    assign pnl_resetn = pnl_reset_pipe[1];

    // CDC: Request and response levels use two-stage synchronizers.
    (* ASYNC_REG = "TRUE" *) reg [1:0] pnl_param_change_request_sync;
    (* ASYNC_REG = "TRUE" *) reg [1:0] axi_param_applied_response_sync;
    always @(posedge panel_clk or negedge pnl_resetn) begin
        if (!pnl_resetn) pnl_param_change_request_sync <= 0;
        else pnl_param_change_request_sync <= {pnl_param_change_request_sync[0],
                                               axi_param_change_request};
    end

    always @(posedge s_axi_aclk or negedge axi_resetn) begin
        if (!axi_resetn) axi_param_applied_response_sync <= 0;
        else axi_param_applied_response_sync <= {axi_param_applied_response_sync[0],
                                                 pnl_param_applied_response};
    end

    // AXI accepts independent address/data channels while idle.
    // Accepted parts are retained while another command completes.
    wire axi_access_ready;
    assign axi_access_ready = axi_resetn && (axi_state == AXI_IDLE) &&
                              !s_axi_bvalid && !s_axi_rvalid;
    assign s_axi_awready = axi_access_ready && !axi_aw_pending;
    assign s_axi_wready = axi_access_ready && !axi_w_pending;
    assign s_axi_arready = axi_access_ready && !axi_ar_pending;

    always_ff @(posedge s_axi_aclk or negedge axi_resetn) begin
        if (!axi_resetn) begin
            axi_state <= AXI_IDLE;
            axi_aw_pending <= 0;
            axi_w_pending <= 0;
            axi_ar_pending <= 0;
            axi_awaddr_saved <= 0;
            axi_araddr_saved <= 0;
            axi_wdata_saved <= 0;
            axi_wstrb_saved <= 0;
            axi_command_write <= 0;
            axi_command_address <= 0;
            axi_command_data <= 0;
            axi_command_strobe <= 0;
            axi_param_change_request <= 0;
            s_axi_bvalid <= 0;
            s_axi_bresp <= OKAY;
            s_axi_rvalid <= 0;
            s_axi_rdata <= 0;
            s_axi_rresp <= OKAY;
        end else begin
            if (s_axi_awvalid && s_axi_awready) begin
                axi_aw_pending <= 1;
                axi_awaddr_saved <= s_axi_awaddr;
            end
            if (s_axi_wvalid && s_axi_wready) begin
                axi_w_pending <= 1;
                axi_wdata_saved <= s_axi_wdata;
                axi_wstrb_saved <= s_axi_wstrb;
            end
            if (s_axi_arvalid && s_axi_arready) begin
                axi_ar_pending <= 1;
                axi_araddr_saved <= s_axi_araddr;
            end
            if (s_axi_bvalid && s_axi_bready) s_axi_bvalid <= 0;
            if (s_axi_rvalid && s_axi_rready) s_axi_rvalid <= 0;

            case (axi_state)
                AXI_IDLE: if (!s_axi_bvalid && !s_axi_rvalid) begin
                    if (axi_aw_pending && axi_w_pending) begin
                        axi_command_write <= 1;
                        axi_command_address <= axi_awaddr_saved;
                        axi_command_data <= axi_wdata_saved;
                        axi_command_strobe <= axi_wstrb_saved;
                        axi_aw_pending <= 0;
                        axi_w_pending <= 0;
                        axi_param_change_request <= 1;
                        axi_state <= AXI_WAIT_RESPONSE;
                    end else if (axi_ar_pending) begin
                        axi_command_write <= 0;
                        axi_command_address <= axi_araddr_saved;
                        axi_command_data <= 0;
                        axi_command_strobe <= 0;
                        axi_ar_pending <= 0;
                        axi_param_change_request <= 1;
                        axi_state <= AXI_WAIT_RESPONSE;
                    end
                end
                AXI_WAIT_RESPONSE: if (axi_param_applied_response_sync[1]) begin
                    // The panel captured the command; no frame boundary wait here.
                    if (axi_command_write) begin
                        s_axi_bvalid <= 1;
                        s_axi_bresp <= pnl_response_code;
                    end else begin
                        s_axi_rvalid <= 1;
                        s_axi_rdata <= pnl_response_data;
                        s_axi_rresp <= pnl_response_code;
                    end
                    axi_param_change_request <= 0;
                    axi_state <= AXI_WAIT_RELEASE;
                end
                AXI_WAIT_RELEASE: if (!axi_param_applied_response_sync[1])
                    axi_state <= AXI_IDLE;
                default: begin
                    axi_param_change_request <= 0;
                    axi_state <= AXI_WAIT_RELEASE;
                end
            endcase
        end
    end

    // PANEL domain holds all the parameter registers and decodes every bus command.
    // Command data is stable before the synchronized request.
    // Response data is held through the return-to-zero handshake.
    always_ff @(posedge panel_clk or negedge pnl_resetn) begin
        if (!pnl_resetn) begin
            pnl_parameter_enable <= 0;
            pnl_parameter_buffer <= 0;
            pnl_parameter_timing <= 12'h222;
            pnl_parameter_display <= {16'd20, 16'd20};
            pnl_param_applied_response <= 0;
            pnl_response_data <= 0;
            pnl_response_code <= OKAY;
        end else if (!pnl_param_change_request_sync[1]) begin
            pnl_param_applied_response <= 0;
        end else if (!pnl_param_applied_response) begin
            pnl_response_code <= OKAY;
            pnl_response_data <= 0;
            if (axi_command_write) begin
                case (axi_command_address)
                    REG_CONTROL: if (axi_command_strobe[0]) begin
                        pnl_parameter_enable <= axi_command_data[0];
                        pnl_parameter_buffer <= axi_command_data[1];
                    end
                    REG_STATUS: ; // Read-only status, writes ignored.
                    REG_TIMING: begin
                        if (axi_command_strobe[0])
                            pnl_parameter_timing[7:0] <= axi_command_data[7:0];
                        if (axi_command_strobe[1])
                            pnl_parameter_timing[11:8] <= axi_command_data[11:8];
                    end
                    REG_DISPLAY: begin
                        if (axi_command_strobe[0])
                            pnl_parameter_display[7:0] <= axi_command_data[7:0];
                        if (axi_command_strobe[1])
                            pnl_parameter_display[15:8] <= axi_command_data[15:8];
                        if (axi_command_strobe[2])
                            pnl_parameter_display[23:16] <= axi_command_data[23:16];
                        if (axi_command_strobe[3])
                            pnl_parameter_display[31:24] <= axi_command_data[31:24];
                    end
                    default: pnl_response_code <= SLVERR;
                endcase
            end else begin
                // Reading
                case (axi_command_address)
                    REG_CONTROL: pnl_response_data <= {30'b0, pnl_parameter_buffer,
                                                       pnl_parameter_enable};
                    REG_STATUS: pnl_response_data <= {30'b0, panel_buffer_select, panel_enable};
                    REG_TIMING: pnl_response_data <= {20'b0, pnl_parameter_timing};
                    REG_DISPLAY: pnl_response_data <= pnl_parameter_display;
                    default: pnl_response_code <= SLVERR;
                endcase
            end
            pnl_param_applied_response <= 1;
        end
    end

    // Apply stored parameters on a frame boundary, or while disabled.
    always_ff @(posedge panel_clk or negedge pnl_resetn) begin
        if (!pnl_resetn) begin
            panel_enable <= 0;
            panel_buffer_select <= 0;
            panel_clk_half_ticks <= 2;
            panel_latch_ticks <= 2;
            panel_blank_ticks <= 2;
            panel_display_ticks <= 20;
            panel_brightness_ticks <= 20;
        end else if (!panel_enable || panel_frame_end) begin
            panel_enable <= pnl_parameter_enable;
            panel_buffer_select <= pnl_parameter_buffer;
            panel_clk_half_ticks <= pnl_parameter_timing[3:0];
            panel_latch_ticks <= pnl_parameter_timing[7:4];
            panel_blank_ticks <= pnl_parameter_timing[11:8];
            panel_display_ticks <= pnl_parameter_display[15:0];
            panel_brightness_ticks <= pnl_parameter_display[31:16];
        end
    end
endmodule
