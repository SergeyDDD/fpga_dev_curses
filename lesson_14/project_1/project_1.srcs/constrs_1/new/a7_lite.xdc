# Microphase A7-LITE R11, XC7A200T-FBG484.
# Onboard oscillator U10: 50 MHz, single-ended, FPGA J19.
set_property PACKAGE_PIN J19 [get_ports clk_50m]
set_property IOSTANDARD LVCMOS33 [get_ports clk_50m]
create_clock -name clk_50m -period 20.000 [get_ports clk_50m]

# Onboard LED1 (D6): frame-generator marker.
set_property PACKAGE_PIN M18 [get_ports led_busy]
set_property IOSTANDARD LVCMOS33 [get_ports led_busy]

# Onboard LED2 (D5): toggles at each generated frame marker.
set_property PACKAGE_PIN N18 [get_ports led_done]
set_property IOSTANDARD LVCMOS33 [get_ports led_done]
