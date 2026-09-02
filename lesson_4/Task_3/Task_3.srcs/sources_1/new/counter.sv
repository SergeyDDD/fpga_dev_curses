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


module counter( input logic  clock,
                input logic  reset,
                output logic [3:0] led
              );

    always_ff @(posedge clock or posedge reset) begin
        if (reset)
            led <= 4'd0;
        else begin
            led <= led + 1;
        end;
    end 

endmodule
