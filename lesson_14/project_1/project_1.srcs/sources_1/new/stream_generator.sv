`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2026 08:22:46 PM
// Design Name: 
// Module Name: stream_generator
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


module stream_generator #(parameter integer FRAME_PERIOD=64004)(
    input logic clk, resetn,
    output wire [7:0] pix_data,
    output wire pix_start_frame
);
    localparam integer FRAME_SIZE = 320 * 200;
    logic [31:0] position;
    logic [7:0] data_counter;
    assign pix_data=data_counter;
    assign pix_start_frame=resetn && (position==0);

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            position <= 0;
            data_counter <= 0;
        end
        else begin
            if (position == FRAME_PERIOD - 1) begin
                position <= 0;
            end
            else begin
                position <= position + 1'b1;
                if (position == 0)
                    data_counter <= 0;
                else if (position < FRAME_SIZE)
                    data_counter <= data_counter + 1'b1;
            end
        end
    end
endmodule
