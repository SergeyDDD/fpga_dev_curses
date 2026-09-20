`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2026 11:17:45 PM
// Design Name: 
// Module Name: tb_design_1_wrapper
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


module tb_design_1_wrapper();

    logic [1:0]gpio_button_tri_i;
    logic [3:0]gpio_led_tri_o;
    logic sys_clk = 0;

    // Test instance declaration
    design_1_wrapper dut (.gpio_button_tri_i(gpio_button_tri_i),
                          .gpio_led_tri_o(gpio_led_tri_o),
                          .sys_clk(sys_clk));

    // Constants declaration
//    localparam DEBOUNCE_PERIOD = 4;

    // Clock definition
    always #10 sys_clk = ~sys_clk;

    initial begin
    
        gpio_button_tri_i[0] = 1'b1;
        gpio_button_tri_i[1] = 1'b1;

        $display("Start testing...");

        #5400us;
        gpio_button_tri_i[0] = 1'b0;
        #500us;
        gpio_button_tri_i[0] = 1'b1;

        #5ms;
        gpio_button_tri_i[1] = 1'b0;
        #500us;
        gpio_button_tri_i[1] = 1'b1;

        #10ms;
        gpio_button_tri_i[1] = 1'b0;
        #500us;
        gpio_button_tri_i[1] = 1'b1;

        #20ms;
        
        $display("End testing");

        $finish;
    end
endmodule

