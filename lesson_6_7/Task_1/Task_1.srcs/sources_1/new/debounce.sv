`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2026 06:10:57 PM
// Design Name: 
// Module Name: debounce
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


module debounce #(parameter DEBOUNCE_PERIOD = 100)
                ( input logic rst,
                 input logic clk_in,
                 input logic [3:0] digit_in,
                 output logic lock_clk);

    localparam NO_BUTTTON_PRESSED_PATTERN = 4'b1111;
    localparam RELOAD_DEBOUNCE_VALUE = DEBOUNCE_PERIOD - 1;

    typedef enum logic [1:0] {
        NO_BUTTON_PRESSED = 2'b00,
        DEBOUNCING =        2'b10,
        BUTTON_PRESSED =    2'b11
    } debounce_state_t;

    debounce_state_t state, next_state;
    logic [$clog2(DEBOUNCE_PERIOD)-1:0] debounce_period;
    logic decrement_debounce_period;
    logic reset_debounce_period;
    logic debounce_period_finished;
    logic button_pressed;

    always_comb begin
        lock_clk                  = (state == BUTTON_PRESSED);
        decrement_debounce_period = (state == DEBOUNCING);
        reset_debounce_period     = (state == NO_BUTTON_PRESSED);

        debounce_period_finished = (debounce_period == '0);
        button_pressed           = (digit_in != NO_BUTTTON_PRESSED_PATTERN);
    end


    always_comb begin
        case (state)
            NO_BUTTON_PRESSED:  next_state = button_pressed ? DEBOUNCING : NO_BUTTON_PRESSED;
            DEBOUNCING:         if (button_pressed)
                                    next_state = (debounce_period_finished) ? BUTTON_PRESSED : DEBOUNCING;
                                else
                                    next_state = NO_BUTTON_PRESSED;
            BUTTON_PRESSED:     next_state = button_pressed ? BUTTON_PRESSED : NO_BUTTON_PRESSED;
            default:            next_state = NO_BUTTON_PRESSED;
        endcase
    end


    always_ff @(posedge rst or posedge clk_in) begin
        if (rst) begin
            state <= NO_BUTTON_PRESSED;
            debounce_period <= RELOAD_DEBOUNCE_VALUE;
        end
        else if (clk_in) begin
            state <= next_state;

            if (reset_debounce_period)
                debounce_period <= RELOAD_DEBOUNCE_VALUE;

            if (decrement_debounce_period)
                debounce_period <= debounce_period - 1'b1;
        end 
    end
    
endmodule
