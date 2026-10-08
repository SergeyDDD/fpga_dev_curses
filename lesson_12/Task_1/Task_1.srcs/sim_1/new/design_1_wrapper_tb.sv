`timescale 1ns / 1ps

module design_1_wrapper_tb;
    localparam integer FRAME_PIXELS = 64000;
    localparam integer FRAME_WORDS = FRAME_PIXELS / 4;

    typedef union packed {
        logic [(FRAME_WORDS-1):0][31:0] word;
        logic [(FRAME_PIXELS-1):0][7:0]  pixel;
    } expected_t;
    expected_t expected;
    logic [15:0]  expected_pixel_id = '0;

    logic       save_once           = 1'b1;
    logic       save_expected_data  = 1'b0;

    logic       clk_50m             = 1'b0;
    logic       pix_clk             = 1'b0;
    logic       reset_rtl_0         = 1'b0;
    logic [0:0] gpio_rtl_0_tri_i    = 1'b1;
    logic [7:0] pix_data_0          = 8'h00;
    logic       pix_start_frame_0   = 1'b0;

    always #10 clk_50m = ~clk_50m;     // 50 MHz board oscillator
    always #25 pix_clk = ~pix_clk;     // 20 MHz simulated external stream

    design_1_wrapper dut (
        .clk_50m(clk_50m),
        .pix_clk(pix_clk),
        .reset_rtl_0(reset_rtl_0),
        .gpio_rtl_0_tri_i(gpio_rtl_0_tri_i),
        .pix_data_0(pix_data_0),
        .pix_start_frame_0(pix_start_frame_0)
    );

    // Continuous external source, independent of software and streamer state.
    always @(negedge pix_clk) begin
        pix_data_0 <= pix_data_0 + 1'b1;
        if (save_once && save_expected_data) begin
            expected.pixel[expected_pixel_id] = pix_data_0;
            expected_pixel_id++;
        end  
    end

    initial begin
        wait (reset_rtl_0);
        
        #650000; // 6500 us for software startup, and button pressed
    
        forever begin
            @(negedge pix_clk);
            pix_start_frame_0 = 1'b1;
    
            @(negedge pix_clk);
            pix_start_frame_0 = 1'b0;
            
            save_expected_data = 1'b1;
    
            repeat (FRAME_PIXELS)
                @(negedge pix_clk);

            save_expected_data = 1'b0;
            save_once = 1'b0;
        end
    end

    // Only stimulus: no scoreboards or result assertions.
    initial begin
        #2000;
        reset_rtl_0 = 1'b1;
        #200000; // 100 us for software startup, no debounce

        @(negedge clk_50m);
        gpio_rtl_0_tri_i = 1'b0;
        #10_000; // 10 us
        @(negedge clk_50m);
        gpio_rtl_0_tri_i = 1'b1;
        #4000000; // release for 5ms

        for (integer n = 0; n < FRAME_WORDS; n++) begin
            if (dut.design_1_i.axi4_full_ram_0.inst.mem[n] !== expected.word[n])
                $fatal(
                    1,
                    "RAM[%0d]: got %08h, expected %08h",
                    n,
                    dut.design_1_i.axi4_full_ram_0.inst.mem[n],
                    expected.word[n]
                );
        end
        $display("PASS: all 64000 bytes in AXI RAM match");

        $finish;
    end
endmodule
