create_clock -name clk -period 2.22 [get_ports clk]
set top [remove_from_collection [all_inputs] clk]
set_driving_cell -lib_cell BUFFD8BWP30P140HVT [get_ports $top]
set_load 0.00135745 [all_outputs ]
set_clock_uncertainty -setup 0.444 [get_clock clk]
set_clock_uncertainty -hold 0.222 [get_clock clk]
set_input_delay -clock clk 1.332 [get_ports $top]
set_output_delay -clock clk 1.332 [all_outputs ]
group_path -name I2O -from [all_inputs ] -to [all_outputs ]
create_clock -name virtual -period 10
set_input_delay -clock virtual 3.5 [get_ports {jtag_en scan_en }]
set_output_delay -clock virtual 3.5 [get_ports {dmux_0_2_out_en jtag_tdo_dmux3 spi_miso}]

