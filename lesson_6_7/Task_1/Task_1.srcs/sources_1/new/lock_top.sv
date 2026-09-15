`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2026 06:08:24 PM
// Design Name: 
// Module Name: lock_top
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

// digit_in is 0..9  > 0..9 button is pressed
// digit_in is 15    > no button is pressed
// DEBOUNCE_PERIOD has to be higher then 2  

module lock_top #(parameter DIGIT_A = 0,
                            DIGIT_B = 1,
                            DIGIT_C = 2)
                 ( input  logic clk,
                   input  logic rst,
                   input  logic [3:0] digit_in,
                   output logic unlocked_led);

    localparam ACTIVE_LED_LEVEL = 1'b1;
    localparam DEBOUNCE_PERIOD = 4;

    logic lock_clk;
    
    debounce #(.DEBOUNCE_PERIOD(DEBOUNCE_PERIOD))
        debounce_ins (.rst(rst),
                      .clk_in(clk),
                      .digit_in(digit_in),
                      .lock_clk(lock_clk));

    lock_controller #(.DIGIT_A(DIGIT_A),
                      .DIGIT_B(DIGIT_B),
                      .DIGIT_C(DIGIT_C),
                      .ACTIVE_LED_LEVEL(ACTIVE_LED_LEVEL))
           lock_inst (.clk(lock_clk),
                      .rst(rst),
                      .digit_in(digit_in),
                      .unlocked_led(unlocked_led));

endmodule
