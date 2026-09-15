`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2026 06:10:08 PM
// Design Name: 
// Module Name: lock_controller
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

module lock_controller #(parameter DIGIT_A = 0,
                                   DIGIT_B = 1,
                                   DIGIT_C = 2,
                                   ACTIVE_LED_LEVEL = 1)
                       ( input logic clk,
                         input logic rst,
                         input logic [3:0] digit_in,
                         output logic unlocked_led
                       );

    typedef enum logic [1:0] {
        LOCKED = 2'b00,
        WAIT_D2 = 2'b01,
        WAIT_D3 = 2'b10,
        UNLOCKED = 2'b11
    } lock_state_t;
    lock_state_t lock_state, next_lock_state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            lock_state <= LOCKED;
        else if (clk)
            lock_state <= next_lock_state; 
    end

    always_comb begin
        // next_lock_state = lock_state;
        // I use 'default' case item as mandatory 
        case (lock_state)
            LOCKED:     next_lock_state = (digit_in==DIGIT_A) ? WAIT_D2 : LOCKED;
            WAIT_D2:    next_lock_state = (digit_in==DIGIT_B) ? WAIT_D3 : LOCKED;
            WAIT_D3:    next_lock_state = (digit_in==DIGIT_C) ? UNLOCKED : LOCKED;
            UNLOCKED:   next_lock_state = UNLOCKED;
            default:    next_lock_state = LOCKED;
        endcase
    end

    always_comb begin
        unlocked_led = (lock_state == UNLOCKED) ? ACTIVE_LED_LEVEL : (!ACTIVE_LED_LEVEL);
    end

endmodule
