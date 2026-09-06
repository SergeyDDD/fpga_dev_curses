`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2026 08:08:55 PM
// Design Name: 
// Module Name: tb_counter
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


module tb_counter();

    logic clk;
    logic rst;
    logic load;
    logic [3:0] data_in;
    logic en;
    logic up_down;
    logic [3:0] count;

    // Constants declaration
    localparam COUNT_UP = 1'd1;
    localparam COUNT_DOWN = 1'd0;
    localparam COUNT_ENABLE = 1'd1;
    localparam COUNT_DISABLE = 1'd0;
    localparam LOAD_ON = 1'd1;
    localparam LOAD_OFF = 1'd0;
    localparam RES_ON = 1'd1;
    localparam RES_OFF = 1'd0;


    
    localparam STEP3_LOAD_VALUE = 4'd10;

    localparam STEP4_CLK_COUNTS = 4'd3;
    localparam STEP4_COUNT_RESULT_1 = STEP3_LOAD_VALUE + STEP4_CLK_COUNTS;
    localparam STEP4_COUNT_RESULT_2 = STEP4_COUNT_RESULT_1 + STEP4_CLK_COUNTS;
    
    localparam STEP5_CLK_COUNTS = 4'd2;
    localparam STEP5_COUNT_RESULT = STEP4_COUNT_RESULT_2;
    
    localparam STEP6_CLK_COUNTS = 4'd1;
    localparam STEP6_COUNT_RESULT = STEP4_COUNT_RESULT_2 - STEP6_CLK_COUNTS;
    
    localparam STEP7_LOAD_VALUE = 4'd05;
    localparam STEP7_COUNT_RESULT = STEP7_LOAD_VALUE;

    localparam STEP_BONUS_CLK_COUNTS = 4'd1;
    localparam STEP_BONUS_LOAD_VALUE = 4'd8;
    localparam STEP_BONUS_COUNT_RESULT = STEP_BONUS_LOAD_VALUE - STEP_BONUS_CLK_COUNTS;

    // Test instance declaration
    counter dut (.clk(clk), .rst(rst), .load(load),
                 .data_in(data_in), .en(en), .up_down(up_down),
                 .count(count));

    // Clock definition
    always #5 clk = ~clk;


    task automatic check_count(
                input [3:0] expected_count,
                input string step_name);
                
        // Step 8. Display output using 'task automatic'
        if (count === expected_count)
            $display ("PASSED: %s done", step_name);
        else
            $display ("FAILED: %s. Counter value is %d. Expected value is %d", step_name, count, expected_count);
    endtask;


    // Testbench
    initial begin

        // Initialize input signals
        clk = 1'b0;
        rst = RES_OFF;
        load = LOAD_OFF;
        data_in = 4'd0;
        en = COUNT_DISABLE;
        up_down = COUNT_DOWN;
        
        // counter reset
        @(posedge clk); #1
        rst = RES_ON;
        @(posedge clk); #1
        rst = RES_OFF;

        // Step 3. `load` feature check
        data_in = STEP3_LOAD_VALUE;
        load = LOAD_ON;
        @(posedge clk); #1
        load = LOAD_OFF;
        check_count(STEP3_LOAD_VALUE, "STEP3");
        
        // Step 4. Up count check. Counter overload check
        en = COUNT_ENABLE;
        up_down = COUNT_UP;

        for (int i = 0; i < STEP4_CLK_COUNTS; i++) begin
            @(posedge clk);
            #1;
        end;
        check_count(STEP4_COUNT_RESULT_1, "STEP4a");

        for (int i = 0; i < STEP4_CLK_COUNTS; i++) begin
            @(posedge clk);
            #1;
        end;
        check_count(STEP4_COUNT_RESULT_2, "STEP4b");

        // Step 5. `un` in '0' behaviour check
        en = COUNT_DISABLE;
        for (int i = 0; i < STEP5_CLK_COUNTS; i++) begin
            @(posedge clk);
            #1;
        end;
        check_count(STEP5_COUNT_RESULT, "STEP5");

        // Step 6. Down count check.
        en = COUNT_ENABLE;
        up_down = COUNT_DOWN;

        for (int i = 0; i < STEP6_CLK_COUNTS; i++) begin
            @(posedge clk);
            #1;
        end;
        check_count(STEP6_COUNT_RESULT, "STEP6");

        // Step 7. Check LOAD priority over the EN signal
        en = COUNT_ENABLE;
        up_down = COUNT_UP;
        load = LOAD_ON; 
        data_in = STEP7_LOAD_VALUE;
        @(posedge clk);
        #1;
        check_count(STEP7_COUNT_RESULT, "STEP7");

        // Step 9.
        // Answer: 'count' is a part of the non-blocking logic, so its value is unknown at the begining until 'rst' or 'load' become active     


        // Step Bonus
        load = LOAD_OFF;
        @(posedge clk);
        #1;
        data_in = STEP_BONUS_LOAD_VALUE;
        load = LOAD_ON;
        @(posedge clk);
        #1;
        load = LOAD_OFF;
        up_down = COUNT_DOWN;
        en = COUNT_ENABLE;
        for (int i = 0; i < STEP_BONUS_CLK_COUNTS; i++) begin
            @(posedge clk);
            #1;
        end;
        check_count(STEP_BONUS_COUNT_RESULT, "STEP_BONUS");

        // Finish
        @(posedge clk);
        #1;

        $finish;
            
    end

endmodule
