`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2026 08:38:45 PM
// Design Name: 
// Module Name: moving_max_tb
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


`timescale 1ns / 1ps

module moving_max_tb;
    localparam N_SAMPLES = 64;
    localparam WINDOW = 8;
    localparam RD_LAT = 1;

    reg clk = 1'b0;
    reg rst = 1'b1;
    reg ap_start = 1'b0;
    wire ap_done, ap_idle, ap_ready;
    wire [5:0] in_data_address0, out_data_address0;
    wire in_data_ce0, out_data_ce0, out_data_we0;
    wire [31:0] in_data_q0, out_data_d0;

    always #5 clk = ~clk; // 100 MHz

    moving_max_0 dut (
        .ap_clk(clk), .ap_rst(rst), .ap_start(ap_start),
        .ap_done(ap_done), .ap_idle(ap_idle), .ap_ready(ap_ready),
        .in_data_address0(in_data_address0), .in_data_ce0(in_data_ce0),
        .in_data_q0(in_data_q0),
        .out_data_address0(out_data_address0), .out_data_ce0(out_data_ce0),
        .out_data_we0(out_data_we0), .out_data_d0(out_data_d0)
    );

    reg signed [31:0] mem_in [0:N_SAMPLES-1];
    reg signed [31:0] mem_out [0:N_SAMPLES-1];
    reg [31:0] q_a = 0, q_b = 0;

    always @(posedge clk) begin
        if (!rst && in_data_ce0) q_a <= mem_in[in_data_address0];
        q_b <= q_a;
        if (!rst && out_data_ce0 && out_data_we0)
            mem_out[out_data_address0] <= out_data_d0;
    end
    assign in_data_q0 = (RD_LAT == 1) ? q_a : q_b;

    // Independent reference: maximum over available samples in[n-7]..in[n].
    reg signed [31:0] golden [0:N_SAMPLES-1];
    task make_golden;
        integer n, k, first;
        integer maximum;
        begin
            for (n = 0; n < N_SAMPLES; n = n + 1) begin
                first = (n >= WINDOW - 1) ? n - WINDOW + 1 : 0;
                maximum = mem_in[first];
                for (k = first + 1; k <= n; k = k + 1)
                    if (mem_in[k] > maximum) maximum = mem_in[k];
                golden[n] = maximum;
            end
        end
    endtask

    task run_once;
        integer cnt;
        begin
            @(negedge clk);
            ap_start = 1'b1;
            @(negedge clk);
            cnt = 0;
            while (!ap_ready && cnt < 2000) begin
                @(negedge clk);
                cnt = cnt + 1;
            end
            if (!ap_ready) $fatal(1, "TIMEOUT: ap_ready never came");
            ap_start = 1'b0;
            cnt = 0;
            while (!ap_idle && cnt < 100) begin
                @(negedge clk);
                cnt = cnt + 1;
            end
            if (!ap_idle) $fatal(1, "TIMEOUT: ap_idle never came");
        end
    endtask

    integer t, n, errors;
    reg [31:0] seed;

    initial begin
        errors = 0;
        seed = 32'd12345;
        repeat (5) @(negedge clk);
        rst = 1'b0;
        repeat (2) @(negedge clk);

        // Three calls without reset: increasing, decreasing, random.
        for (t = 0; t < 3; t = t + 1) begin
            for (n = 0; n < N_SAMPLES; n = n + 1) begin
                case (t)
                    0: mem_in[n] = n;
                    1: mem_in[n] = N_SAMPLES - 1 - n;
                    2: begin
                        seed = seed * 32'd1103515245 + 32'd12345;
                        mem_in[n] = $signed((seed >> 16) % 201) - 100;
                    end
                endcase
                mem_out[n] = 32'hDEADBEEF;
            end

            make_golden;
            run_once;
            repeat (3) @(negedge clk);

            for (n = 0; n < N_SAMPLES; n = n + 1) begin
                if (mem_out[n] !== golden[n]) begin
                    errors = errors + 1;
                    if (errors <= 10)
                        $display("MISMATCH: case=%0d n=%0d DUT=%0d ref=%0d",
                                 t, n, mem_out[n], golden[n]);
                end
            end
        end

        if (errors != 0) $fatal(1, "Test FAILED: %0d errors", errors);
        $display("Test passed: 3 cases, 192 results");
        $finish;
    end

    initial begin
        #200000;
        $fatal(1, "TIMEOUT: simulation too long");
    end
endmodule
