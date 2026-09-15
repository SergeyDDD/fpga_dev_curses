`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/15/2026 08:02:51 PM
// Design Name: 
// Module Name: lock_top_tb
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

module lock_top_tb();

    logic clk;
    logic rst;
    logic [3:0] digit_in;
    logic unlocked_led;

    // Constants declaration
    localparam DEBOUNCE_PERIOD = 4;

    localparam DIGIT_A     = 4'd5;
    localparam DIGIT_B     = 4'd3;
    localparam DIGIT_C     = 4'd7;
    localparam DIGIT_WRONG = 4'd9;
    localparam NO_BUTTON   = 4'd15;

    localparam LOCKED   = 2'b00;
    localparam WAIT_D2  = 2'b01;
    localparam WAIT_D3  = 2'b10;
    localparam UNLOCKED = 2'b11;

    // Test instance declaration
    lock_top #(.DIGIT_A(DIGIT_A),
               .DIGIT_B(DIGIT_B),
               .DIGIT_C(DIGIT_C))
        dut_lock (
                  .clk(clk),
                  .rst(rst),
                  .digit_in(digit_in),
                  .unlocked_led(unlocked_led)
                );

    // Clock definition
    always #5 clk = ~clk;

    task automatic check(
        input logic condition,
        input string step_name
    );
        if (condition === 1'b1)
            $display("PASSED: %s done", step_name);
        else
            $display("FAILED: %s", step_name);
    endtask

    task automatic check_lock(
        input logic [1:0] expected_state,
        input string step_name
    );
        check((dut_lock.lock_inst.lock_state === expected_state) && (unlocked_led === (expected_state == UNLOCKED)), step_name);
    endtask

    task automatic press_button(input logic [3:0] digit);
        @(negedge clk);
        digit_in = digit;

        for (int i = 0; i < DEBOUNCE_PERIOD + 1; i++) begin
            @(posedge clk);
            #1;
        end

        @(negedge clk);
        digit_in = NO_BUTTON;
        @(posedge clk);
        #1;
    endtask

    // Testbench
    initial begin
        clk = 1'b0;
        rst = 1'b0;
        digit_in = NO_BUTTON;

        // Step 1. reset
        #2;
        rst = 1'b1;
        #1;
        check_lock(LOCKED, "STEP1: reset");
        check(dut_lock.lock_clk === 1'b0, "STEP1: debounce reset");

        @(negedge clk);
        rst = 1'b0;

        // Step 2. Short press test
        @(negedge clk);
        digit_in = DIGIT_A;

        for (int i = 0; i < DEBOUNCE_PERIOD; i++) begin
            @(posedge clk);
            #1;
            check(dut_lock.lock_clk === 1'b0, "STEP2: no early pulse");
        end

        @(negedge clk);
        digit_in = NO_BUTTON;
        @(posedge clk);
        #1;
        check(dut_lock.lock_clk === 1'b0, "STEP2: short press released");
        check_lock(LOCKED, "STEP2: short press ignored");

        // Step 3. Full press, holding and release
        @(negedge clk);
        digit_in = DIGIT_A;

        for (int i = 0; i < DEBOUNCE_PERIOD; i++) begin
            @(posedge clk);
            #1;
            check(dut_lock.lock_clk === 1'b0, "STEP3: debounce delay");
        end

        @(posedge clk);
        #1;
        check(dut_lock.lock_clk === 1'b1, "STEP3: press accepted");
        check_lock(WAIT_D2, "STEP3: LOCKED -> WAIT_D2");

        for (int i = 0; i < DEBOUNCE_PERIOD + 1; i++) begin
            @(posedge clk);
            #1;
            check(dut_lock.lock_clk === 1'b1, "STEP3: held output");
            check_lock(WAIT_D2, "STEP3: no repeated digit");
        end

        @(negedge clk);
        digit_in = NO_BUTTON;
        @(posedge clk);
        #1;
        check(dut_lock.lock_clk === 1'b0, "STEP3: release");

        // Step 4. Wrong second digit returns to LOCKED
        press_button(DIGIT_WRONG);
        check_lock(LOCKED, "STEP4: wrong digit -> LOCKED");

        // Step 5. Correct code after an error
        press_button(DIGIT_A);
        check_lock(WAIT_D2, "STEP5: LOCKED -> WAIT_D2");

        press_button(DIGIT_B);
        check_lock(WAIT_D3, "STEP5: WAIT_D2 -> WAIT_D3");

        press_button(DIGIT_C);
        check_lock(UNLOCKED, "STEP5: WAIT_D3 -> UNLOCKED");

        // Step 6. reset from UNLOCKED
        @(negedge clk);
        #1;
        rst = 1'b1;
        #1;
        check_lock(LOCKED, "STEP6: reset from UNLOCKED");

        $finish;
    end

endmodule