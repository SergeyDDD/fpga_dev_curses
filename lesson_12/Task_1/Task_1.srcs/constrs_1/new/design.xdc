# Microphase A7-LITE R11, xc7a200tfbg484-2.
# JP2 uses 3.3 V. External source must use compatible 3.3 V levels.

# Onboard oscillator U10: J19, 50 MHz.
set_property PACKAGE_PIN J19 [get_ports clk_50m]
set_property IOSTANDARD LVCMOS33 [get_ports clk_50m]
create_clock -name clk_50m -period 20.000 [get_ports clk_50m]

# Pixel clock: JP2 pin 27, W19 (IO_L12P_T1_MRCC_14).
set_property PACKAGE_PIN W19 [get_ports pix_clk]
set_property IOSTANDARD LVCMOS33 [get_ports pix_clk]
# External pixel strobe: assumed minimum period 300 ns (~3.33 MHz).
create_clock -name pix_clk -period 300.000 [get_ports pix_clk]

# Pixel data: JP2 pins 1,2,5,6,7,8,9,10.
set_property PACKAGE_PIN W21 [get_ports {pix_data_0[0]}]
set_property PACKAGE_PIN W22 [get_ports {pix_data_0[1]}]
set_property PACKAGE_PIN P19 [get_ports {pix_data_0[2]}]
set_property PACKAGE_PIN R19 [get_ports {pix_data_0[3]}]
set_property PACKAGE_PIN R18 [get_ports {pix_data_0[4]}]
set_property PACKAGE_PIN T18 [get_ports {pix_data_0[5]}]
set_property PACKAGE_PIN T21 [get_ports {pix_data_0[6]}]
set_property PACKAGE_PIN U21 [get_ports {pix_data_0[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pix_data_0[*]}]

# Frame start: JP2 pin 4.
set_property PACKAGE_PIN P17 [get_ports pix_start_frame_0]
set_property IOSTANDARD LVCMOS33 [get_ports pix_start_frame_0]

# GPIO input: JP2 pin 15.
set_property PACKAGE_PIN Y21 [get_ports {gpio_rtl_0_tri_i[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio_rtl_0_tri_i[0]}]

# External active-low reset: JP2 pin 16. Pull-up keeps reset inactive.
# Pull this pin to GND to assert reset. JP2 pin 12 is GND.
set_property PACKAGE_PIN Y22 [get_ports reset_rtl_0]
set_property IOSTANDARD LVCMOS33 [get_ports reset_rtl_0]
set_property PULLUP TRUE [get_ports reset_rtl_0]

# CDC exceptions for the current streamer_top_0 hierarchy.
# Do not also load streamer_cdc.xdc: these replace its exceptions.
# Timing between synchronization stages and XPM FIFO constraints is preserved.

# aclk -> pix_clk: BUSY
set_false_path -to [get_pins {design_1_i/streamer_top_0/inst/capture/pix_busy_dms_reg[0]/D}]

# pix_clk -> aclk: DONE
set_false_path -to [get_pins {design_1_i/streamer_top_0/inst/capture/axi_done_dms_reg[0]/D}]

# pix_clk -> aclk: FIFO read reset
set_false_path -to [get_pins {design_1_i/streamer_top_0/inst/capture/input_fifo/rd_reset_pipe_reg[0]/D}]

# Asynchronous reset assertion on reset-synchronizer registers only.
set_false_path -to [get_pins {
    design_1_i/streamer_top_0/inst/capture/pix_reset_dms_reg[0]/CLR
    design_1_i/streamer_top_0/inst/capture/pix_reset_dms_reg[1]/CLR
}]