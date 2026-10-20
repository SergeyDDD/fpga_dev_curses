`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 06:03:20 PM
// Design Name: 
// Module Name: tb_design_1_wrapper
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

module tb_design_1_wrapper();
    reg clk_in1_0 = 0;
    reg resetn = 0;
    reg uart_rtl_0_rxd = 1;

    wire uart_rtl_0_txd;
    wire [2:0] panel_rgb_upper_0;
    wire [2:0] panel_rgb_lower_0;
    wire [4:0] panel_row_0;
    wire panel_shift_clk_0;
    wire panel_lat_0;
    wire panel_oe_n_0;

    design_1_wrapper dut (
        .clk_in1_0(clk_in1_0),
        .resetn(resetn),

        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),

        .panel_rgb_upper_0(panel_rgb_upper_0),
        .panel_rgb_lower_0(panel_rgb_lower_0),
        .panel_row_0(panel_row_0),
        .panel_shift_clk_0(panel_shift_clk_0),
        .panel_lat_0(panel_lat_0),
        .panel_oe_n_0(panel_oe_n_0)
    );

    // Board oscillator: 50 MHz.
    always #10 clk_in1_0 = ~clk_in1_0;

    // External reset is active low.
    initial begin
        repeat(50) @(negedge clk_in1_0);
        resetn = 1;
    end

    // Simulation duration: 10 ms.
    initial begin
        #5000000;
        $finish;
    end
endmodule
