`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/15/2026 11:10:03 PM
// Design Name: 
// Module Name: fir_plined
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

// FIR: y[n] = x[n]*k0 + x[n-1]*k1 + x[n-2]*k2 + x[n-3]*k3.
module fir_plined (
    input  logic clk,
    input  logic rst,
    input  logic signed [15:0] x0, x1, x2, x3,
    input  logic signed [15:0] k0, k1, k2, k3,
    output logic signed [33:0] result
);

    logic signed [15:0] x0_reg, x1_reg, x2_reg, x3_reg;
    logic signed [15:0] k0_reg, k1_reg, k2_reg, k3_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            x0_reg <= '0;
            x1_reg <= '0;
            x2_reg <= '0;
            x3_reg <= '0;
            k0_reg <= '0;
            k1_reg <= '0;
            k2_reg <= '0;
            k3_reg <= '0;
        end else begin
            x0_reg <= x0;
            x1_reg <= x1;
            x2_reg <= x2;
            x3_reg <= x3;
            k0_reg <= k0;
            k1_reg <= k1;
            k2_reg <= k2;
            k3_reg <= k3;
        end
    end

    logic signed [31:0] p0, p1, p2, p3;
    logic signed [33:0] filter_result;

    always_comb begin
        p0 = x0_reg * k0_reg;
        p1 = x1_reg * k1_reg;
        p2 = x2_reg * k2_reg;
        p3 = x3_reg * k3_reg;

        filter_result = p0 + p1 + p2 + p3;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            result <= '0;
        else
            result <= filter_result;
    end

endmodule

