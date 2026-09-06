`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2026 05:57:14 PM
// Design Name: 
// Module Name: counter
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


module counter( input logic  clk,
                input logic  rst,
                input logic  load,
                input logic [3:0] data_in,
                input logic  en,
                input logic  up_down,   // 1-uo, 0-down
                output logic [3:0] count
              );

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            count <= 4'd0;
        else begin
            if (load)
                count <= data_in;
            else
                if (en)
                    count <= up_down ? count + 1 : count - 1;
        end;
    end;

endmodule
