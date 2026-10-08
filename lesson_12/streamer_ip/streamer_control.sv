`timescale 1ns / 1ps
// AXI4-Lite control for a frame streamer.
// 0x00 CONTROL: write bit 0 = START;
//               reads always return zero.
// 0x04 STATUS:  read bit 0 = busy;
//               writes return OKAY and have no effect.
// START while busy is ignored with OKAY.
// Reserved CONTROL bits are ignored.
// stream_busy is the BUSY level from streamer_input, synchronous to s_axi_aclk.

module streamer_control #(
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

    // Streamer control interface
    output logic                  start,           // Start streaming
    input  logic                  stream_busy      // Capture busy from streamer_input
);
    localparam logic [1:0] OKAY = 2'b00, SLVERR = 2'b10;
    localparam logic [ADDR_WIDTH-1:0] CONTROL_ADDR = 0, STATUS_ADDR = 4;

    // Buffer AW and W independently: either channel may arrive first.
    logic aw_pending, w_pending;
    logic [ADDR_WIDTH-1:0] awaddr_saved;
    logic start_saved, byte0_saved;
    logic start_pending;

    // Stay busy between issuing START and the input acknowledging it with BUSY.

    assign s_axi_awready = s_axi_aresetn && !aw_pending && !s_axi_bvalid;
    assign s_axi_wready  = s_axi_aresetn && !w_pending  && !s_axi_bvalid;
    assign s_axi_arready = s_axi_aresetn && !s_axi_rvalid;

    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            aw_pending  <= 1'b0;
            w_pending   <= 1'b0;
            awaddr_saved <= '0;
            start_saved <= 1'b0;
            byte0_saved <= 1'b0;
            s_axi_bvalid <= 1'b0;
            s_axi_bresp  <= OKAY;
            start  <= 1'b0;
        end else begin
            // START is an event, never a persistent software register.
            start <= 1'b0;

            if (s_axi_awvalid && s_axi_awready) begin
                awaddr_saved <= s_axi_awaddr;
                aw_pending <= 1'b1;
            end
            if (s_axi_wvalid && s_axi_wready) begin
                start_saved <= s_axi_wdata[0];
                byte0_saved <= s_axi_wstrb[0];
                w_pending <= 1'b1;
            end
            if (s_axi_bvalid && s_axi_bready)
                s_axi_bvalid <= 1'b0;

            // Apply the write once, after both channels have been accepted.
            if (aw_pending && w_pending && !s_axi_bvalid) begin
                aw_pending <= 1'b0;
                w_pending <= 1'b0;
                s_axi_bvalid <= 1'b1;
                s_axi_bresp <= OKAY;
                if ((awaddr_saved != CONTROL_ADDR) &&
                    (awaddr_saved != STATUS_ADDR)) begin
                    s_axi_bresp <= SLVERR;
                end else if ((awaddr_saved == CONTROL_ADDR) &&
                             byte0_saved && start_saved) begin
                    // Ignore another START while waiting for or observing BUSY.
                    if (!stream_busy) begin
                        start <= 1'b1;
                    end
                end
            end
        end
    end

    // Snapshot read data when AR is accepted; keep it stable until RREADY.
    always_ff @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            s_axi_rvalid <= 1'b0;
            s_axi_rdata <= 32'b0;
            s_axi_rresp <= OKAY;
        end else begin
            if (s_axi_rvalid && s_axi_rready)
                s_axi_rvalid <= 1'b0;
            if (s_axi_arvalid && s_axi_arready) begin
                s_axi_rvalid <= 1'b1;
                s_axi_rresp <= OKAY;
                case (s_axi_araddr)
                    CONTROL_ADDR: s_axi_rdata <= 32'b0;
                    STATUS_ADDR:  s_axi_rdata <= {31'b0,stream_busy};
                    default: begin
                        s_axi_rdata <= 32'b0;
                        s_axi_rresp <= SLVERR;
                    end
                endcase
            end
        end
    end
endmodule
