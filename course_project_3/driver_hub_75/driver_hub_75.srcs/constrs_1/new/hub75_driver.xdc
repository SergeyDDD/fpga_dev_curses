# Board clock: 50 MHz oscillator
set_property PACKAGE_PIN J19 [get_ports {clk_in1_0}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk_in1_0}]

# Active-low reset: dedicated RESET button K3, external pull-up (sheet 9).
set_property PACKAGE_PIN L18 [get_ports {resetn}]
set_property IOSTANDARD LVCMOS33 [get_ports {resetn}]

# On-board USB-UART bridge CH340E
# RX/TX are from the FPGA: U2 input, V2 output.
set_property PACKAGE_PIN U2 [get_ports {uart_rtl_0_rxd}]
set_property IOSTANDARD LVCMOS33 [get_ports {uart_rtl_0_rxd}]
set_property PACKAGE_PIN V2 [get_ports {uart_rtl_0_txd}]
set_property IOSTANDARD LVCMOS33 [get_ports {uart_rtl_0_txd}]

# R1: GPIO2_5N
set_property PACKAGE_PIN V22 [get_ports {panel_rgb_upper_0[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_rgb_upper_0[2]}]

# G1: GPIO2_5P
set_property PACKAGE_PIN U22 [get_ports {panel_rgb_upper_0[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_rgb_upper_0[1]}]

# B1: GPIO2_6P
set_property PACKAGE_PIN Y21 [get_ports {panel_rgb_upper_0[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_rgb_upper_0[0]}]

# R2: GPIO2_7P
set_property PACKAGE_PIN AA20 [get_ports {panel_rgb_lower_0[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_rgb_lower_0[2]}]

# G2: GPIO2_6N
set_property PACKAGE_PIN Y22 [get_ports {panel_rgb_lower_0[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_rgb_lower_0[1]}]

# B2: GPIO2_8P
set_property PACKAGE_PIN AB21 [get_ports {panel_rgb_lower_0[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_rgb_lower_0[0]}]

# E: GPIO2_7N
set_property PACKAGE_PIN AA21 [get_ports {panel_row_0[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_row_0[4]}]

# A: GPIO2_13N
set_property PACKAGE_PIN AB18 [get_ports {panel_row_0[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_row_0[0]}]

# B: GPIO2_8N
set_property PACKAGE_PIN AB22 [get_ports {panel_row_0[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_row_0[1]}]

# C: GPIO2_14N
set_property PACKAGE_PIN V19 [get_ports {panel_row_0[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_row_0[2]}]

# D: GPIO2_13P
set_property PACKAGE_PIN AA18 [get_ports {panel_row_0[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_row_0[3]}]

# CLK: GPIO2_15N
set_property PACKAGE_PIN W17 [get_ports {panel_shift_clk_0}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_shift_clk_0}]

# LAT: GPIO2_14P
set_property PACKAGE_PIN V18 [get_ports {panel_lat_0}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_lat_0}]

# OE: GPIO2_15P
set_property PACKAGE_PIN V17 [get_ports {panel_oe_n_0}]
set_property IOSTANDARD LVCMOS33 [get_ports {panel_oe_n_0}]



