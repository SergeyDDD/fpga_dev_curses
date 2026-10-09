`timescale 1ns / 1ps

module streamer_top_tb;
    localparam integer FRAME_BYTES = 64000;
    localparam integer FRAME_WORDS = FRAME_BYTES / 4;
    localparam integer FRAMES_TO_CHECK = 3;

    logic clk_50m = 1'b0;
    wire led_busy, led_done;
    always #10 clk_50m = ~clk_50m;

    streamer_top dut (
        .clk_50m(clk_50m),
        .led_busy(led_busy),
        .led_done(led_done)
    );

    // Current streamer_input signals; no added DUT ports are required.
    wire pix_reset = dut.pix_reset;
    wire [7:0] pix_data = dut.pix_data;
    wire pix_start_frame = dut.pix_start_frame;
    wire [1:0] stream_state = dut.capture.stream_state;
    wire [15:0] pixel_number = dut.capture.pixel_number;
    wire [1:0] pixel_index = dut.capture.pixel_index;
    wire frame_wr_en = dut.capture.frame_wr_en;
    wire [13:0] frame_wr_addr = dut.capture.frame_wr_addr;
    wire [31:0] frame_wr_data = dut.capture.frame_wr_data;

    logic [31:0] expected [0:FRAME_WORDS-1];
    logic [31:0] packed_word = '0;
    integer captured_bytes = 0;
    integer written_words = 0;
    integer checked_frames = 0;

    always @(posedge clk_50m) begin
        if (!pix_reset) begin
            captured_bytes = 0;
            written_words = 0;
            checked_frames = 0;
            packed_word = '0;
        end else begin
            // State before the edge: matches the byte accepted by the DUT.
            if (stream_state == 2'b10) begin // SS_CAPTURING
                if (captured_bytes >= FRAME_BYTES)
                    $fatal(1, "Too many captured bytes");
                if ($isunknown(pix_data))
                    $fatal(1, "Captured pixel contains X/Z");
                packed_word[8 * (captured_bytes % 4) +: 8] = pix_data;
                if ((captured_bytes % 4) == 3)
                    expected[captured_bytes / 4] = packed_word;
                captured_bytes = captured_bytes + 1;
            end

            // These registered signals describe the previous clock's write.
            // The final word is formed in SS_FINISH and checked here next edge.
            if (frame_wr_en) begin
                if (written_words >= FRAME_WORDS)
                    $fatal(1, "Too many written words");
                if (frame_wr_addr !== written_words)
                    $fatal(1, "Write address: got %0d, expected %0d",
                           frame_wr_addr, written_words);
                if (frame_wr_data !== expected[written_words])
                    $fatal(1, "Word %0d: got %08h, expected %08h",
                           written_words, frame_wr_data, expected[written_words]);
                written_words = written_words + 1;

                if (written_words == FRAME_WORDS) begin
                    if (captured_bytes != FRAME_BYTES)
                        $fatal(1, "Reference incomplete: %0d bytes", captured_bytes);
                    for (integer n = 0; n < FRAME_WORDS; n = n + 1)
                        if (dut.capture.frame_buffer[n] !== expected[n])
                            $fatal(1, "RAM[%0d]: got %08h, expected %08h", n,
                                   dut.capture.frame_buffer[n], expected[n]);

                    checked_frames = checked_frames + 1;
                    $display("PASS frame %0d: 64000 bytes, 16000 RAM words",
                             checked_frames);
                    captured_bytes = 0;
                    written_words = 0;
                    packed_word = '0;
                    if (checked_frames == FRAMES_TO_CHECK) begin
                        $display("PASS: all accepted frames verified");
                        $finish;
                    end
                end
            end
        end
    end

    initial begin
        #10_000_000; // 10 ms, sufficient for three captures at FRAME_PERIOD=64000.
        $fatal(1, "Timeout: frames=%0d, bytes=%0d, words=%0d",
               checked_frames, captured_bytes, written_words);
    end
endmodule
