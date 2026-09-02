`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2026 12:01:51 AM
// Design Name: 
// Module Name: decoder
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

module decoder #(parameter WIDTH = 7) (
    input  logic [$clog2(WIDTH)-1:0] din,
    output logic [WIDTH-1:0] dout
);

// variant #1
// din creates overflow if WIDTH is not a power of 2 without 'if (din < WIDTH)'
// Is it Ok?
always_comb begin
    dout = '0;
    if (din < WIDTH)        // is it mandatory to avoid overflow
        dout[din] = 1'b1;
end

/*
// variant #2 where din doesn't create overflow if WIDTH is not a power of 2
always_comb begin
    dout = '0;
    for (int i = 0; i < WIDTH; i++) begin
        if (din == i)
            dout[i] = 1'b1;
    end
end
*/
endmodule
