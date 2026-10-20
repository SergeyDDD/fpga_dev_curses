`timescale 1ns / 1ps

module tb_hub75();
    reg  clk = 0;
    reg  resetn = 0;
    reg  enable = 0;
    reg  buffer_select = 0;
    reg  [15:0] brightness_ticks = 400;
    wire frame_start;
    wire pixel_request;
    wire pixel_valid;
    wire frame_end;
    wire [2:0] rgb_upper;
    wire [2:0] rgb_lower;
    wire [2:0] panel_upper;
    wire [2:0] panel_lower;
    wire [4:0] panel_row;
    wire shift_clk;
    wire lat;
    wire oe_n;
    wire bram_en;
    wire [31:0] bram_addr;
    reg  [31:0] bram_rddata = 0;
    reg  [31:0] memory [0:2047]; // 2 frames, 4 KiB each
    
    localparam DISPLAY_TICKS = 16'd800;

    hub75_driver driver (
        .panel_clk(clk),
        .panel_resetn(resetn),
        .enable(enable),
        .clk_half_ticks(4'd2),
        .latch_ticks(4'd2),
        .blank_ticks(4'd2),
        .display_ticks(DISPLAY_TICKS),
        .brightness_ticks(brightness_ticks),
        .frame_end(frame_end),
        .bram_frame_start(frame_start),
        .bram_pixel_request(pixel_request),
        .bram_pixel_valid(pixel_valid),
        .bram_rgb_upper(rgb_upper),
        .bram_rgb_lower(rgb_lower),
        .panel_rgb_upper(panel_upper),
        .panel_rgb_lower(panel_lower),
        .panel_shift_clk(shift_clk),
        .panel_lat(lat),
        .panel_oe_n(oe_n),
        .panel_row(panel_row)
    );

    bram_reader reader (
        .panel_clk(clk),
        .panel_resetn(resetn),
        .hub_frame_start(frame_start),
        .hub_buffer_select(buffer_select),
        .hub_pixel_request(pixel_request),
        .hub_pixel_valid(pixel_valid),
        .hub_rgb_upper(rgb_upper),
        .hub_rgb_lower(rgb_lower),
        .bram_addr(bram_addr),
        .bram_en(bram_en),
        .bram_rddata(bram_rddata),
        .bram_rst_busy(1'b0)
    );

    always #20 clk = ~clk; // 25 MHz

    // Simple pattern. Upper RGB in [6:4], lower RGB in [2:0].
    function automatic [7:0] pattern(input integer buffer_id, pixel_index);
        reg [2:0] upper;
        reg [2:0] lower;
        begin
            upper = 3'(pixel_index % 8);
            lower = 3'((pixel_index + 1 + buffer_id) % 8);
            pattern = {1'b0, upper, 1'b0, lower};
        end
    endfunction

    integer pixels = 0;
    integer rows = 0;
    integer reads = 0;
    integer frames = 0;
    integer buffer_id;
    integer word_id;
    reg [7:0] expected;
    integer light_ticks = 0;
    integer row_ticks = 0;
    integer frame_ticks = 0;
    integer reference_frame_ticks = 0;

    // Brightness changes OE duration without changing the display interval.
    always @(negedge clk) begin
        if (resetn && enable) begin
            if (driver.bram_frame_start)
                frame_ticks = 0;

            frame_ticks = frame_ticks + 1;

            if (driver.state == driver.SM_DISPLAY) begin
                row_ticks = row_ticks + 1;
                if (!oe_n)
                    light_ticks = light_ticks + 1;
            end else if (!oe_n)
                $fatal(1, "OE enabled outside display interval");

            if (driver.state == driver.SM_END_ROW) begin
                if (row_ticks != DISPLAY_TICKS || light_ticks != brightness_ticks)
                    $fatal(1, "Wrong display/brightness duration: %0d/%0d", row_ticks, light_ticks);

                row_ticks = 0;
                light_ticks = 0;
            end
        end
    end

    // Synchronous read: equivalent to BRAM latency 1, no output register.
    always @(posedge clk) begin
        if (resetn && bram_en) begin
            if (bram_addr !== 32'(buffer_select * 4096 + reads * 4))
                $fatal(1, "Wrong BRAM address: %h", bram_addr);

            bram_rddata <= memory[bram_addr[12:2]];
            reads = reads + 1;
        end
    end

    // The panel samples both RGB channels on the rising CLK edge.
    always @(posedge shift_clk) begin
        expected = pattern(int'(buffer_select), pixels);

        if ({panel_upper, panel_lower} !== {expected[6:4], expected[2:0]})
            $fatal(1, "Wrong RGB at pixel %0d: upper=%b lower=%b", pixels, panel_upper, panel_lower);

        if (!oe_n || lat)
            $fatal(1, "Unsafe shift timing");

        pixels = pixels + 1;
    end

    always @(posedge lat) begin
        if (pixels != (rows + 1) * 128 || panel_row !== 5'(rows))
            $fatal(1, "Wrong row or pixel count");

        if (!oe_n)
            $fatal(1, "LAT while panel enabled");

        rows = rows + 1;
    end

    initial begin
        for (buffer_id = 0; buffer_id < 2; buffer_id = buffer_id + 1) begin
            for (word_id = 0; word_id < 1024; word_id = word_id + 1) begin
                memory[buffer_id * 1024 + word_id] = {pattern(buffer_id, word_id * 4 + 3),
                                                    pattern(buffer_id, word_id * 4 + 2),
                                                    pattern(buffer_id, word_id * 4 + 1),
                                                    pattern(buffer_id, word_id * 4)};
            end
        end

        repeat(4) @(negedge clk);
        resetn = 1;
        enable = 1;

        repeat(2) begin
            // Check at negedge, after frame_end and counters have settled.
            do begin
                @(negedge clk);
                #1;
            end while (!frame_end);

            if (pixels != 4096 || rows != 32 || reads != 1024)
                $fatal(1, "Counts: pixels=%0d rows=%0d reads=%0d", pixels, rows, reads);

            if (frames == 0)
                reference_frame_ticks = frame_ticks;
            else if (frame_ticks != reference_frame_ticks)
                $fatal(1, "Brightness changed frame duration");

            frames = frames + 1;
            $display("PASS frame %0d, buffer %0d", frames, buffer_select);
            buffer_select = ~buffer_select; // Emulate selection for next frame.
            brightness_ticks = 200; // Second frame: 25%, same display duration.
            pixels = 0;
            rows = 0;
            reads = 0;
        end

        enable = 0;
        repeat(2) @(negedge clk);

        if (!oe_n || shift_clk || lat)
            $fatal(1, "Unsafe disabled outputs");

        $display("ALL TESTS PASSED");
        $finish;
    end


    initial begin
        #10000000;
        $fatal(1, "Timeout");
    end

endmodule
