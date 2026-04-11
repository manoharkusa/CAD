set target_library { /proj1/projects/pd/projects_28nm/common_inputs/synthesis_inputs/ccs/tcbn28hpcplusbwp40p140hvtssg0p81vm40c_ccs.db }
set link_library { * /proj1/projects/pd/projects_28nm/common_inputs/synthesis_inputs/ccs/tcbn28hpcplusbwp40p140hvtssg0p81vm40c_ccs.db /proj1/projects/pd/projects_28nm/rp_top/macro1_lib/ts1n28hpcpuhdhvtb2048x129m4swbso_18.50a_ssg0p81vm40c.db /proj1/projects/pd/projects_28nm/rp_top/macro2_lib/tsdn28hpcpuhdb4096x33m4mwa_18.50a_ssg0p81vm40c.db  }
analyze -format verilog -autoread -recursive /home/sumoct22pd156/CM23/Cortex-M23/AT621-BU-50000-r2p0-01rel0/grebe/logical/ -top GREBEINTEGRATION_MCU
elaborate GREBEINTEGRATION_MCU
link
compile
check_timing
all_fanin -to [all_registers -clock_pins ] -flat -startpoints_only

create_clock -period 8.5 -name SCLK [get_ports SCLK]
create_clock -period 8.5 -name HCLK [get_ports HCLK]
create_clock -period 8.5 -name SWCLKTCK [get_ports SWCLKTCK]
create_clock -period 8.5 -name DCLK [get_ports DCLK]
create_clock -period 8.5 -name FCLK [get_ports FCLK]
set_input_delay [expr 8.5*0.6]  -clock SCLK [get_ports [remove_from_collection [all_inputs ] {SCLK HCLK SWCLKTCK DCLK FCLK}]]
set_input_delay [expr 8.5*0.6]  -clock HCLK -add_delay  [get_ports [remove_from_collection [all_inputs ] {SCLK HCLK SWCLKTCK DCLK FCLK}]]
set_input_delay [expr 8.5*0.6]  -clock SWCLKTCK -add_delay  [get_ports [remove_from_collection [all_inputs ] {SCLK HCLK SWCLKTCK DCLK FCLK}]]
set_input_delay [expr 8.5*0.6]  -clock DCLK -add_delay  [get_ports [remove_from_collection [all_inputs ] {SCLK HCLK SWCLKTCK DCLK FCLK}]]
set_input_delay [expr 8.5*0.6]  -clock FCLK -add_delay  [get_ports [remove_from_collection [all_inputs ] {SCLK HCLK SWCLKTCK DCLK FCLK}]]
set_output_delay [expr 8.5*0.6]  -clock SCLK [get_ports [all_outputs]]
set_output_delay [expr 8.5*0.6]  -clock HCLK -add_delay  [get_ports [all_outputs]]
set_output_delay [expr 8.5*0.6]  -clock SWCLKTCK -add_delay  [get_ports [all_outputs]]
set_output_delay [expr 8.5*0.6]  -clock DCLK -add_delay  [get_ports [all_outputs]]
set_output_delay [expr 8.5*0.6]  -clock FCLK -add_delay  [get_ports [all_outputs]]


filter_collection [all_fanout  -from    [all_inputs] ] "port_direction == out "
create_clock -name vir -period 8.5
set_output_delay [expr 8.5*0.35]  -clock vir    [filter_collection [all_fanout  -from    [all_inputs] ] "port_direction == out " ]
set_input_delay [expr 8.5*0.35]  -clock vir    [filter_collection [all_fanin  -to    [all_outputs] ] "port_direction == in " ]

group_path -from [all_inputs ] -to [all_outputs ] -name i2o
group_path -from [all_inputs ] -to [all_registers ] -name i2r
group_path -from [all_registers ] -to [all_registers ] -name r2r
group_path -from [all_registers ] -to [all_outputs ] -name r2o

set_clock_uncertainty -setup [expr 8.5*0.2] [get_clocks SCLK]
set_clock_uncertainty -setup [expr 8.5*0.2] [get_clocks HCLK]
set_clock_uncertainty -setup [expr 8.5*0.2] [get_clocks SWCLKTCK]
set_clock_uncertainty -setup [expr 8.5*0.2] [get_clocks DCLK]
set_clock_uncertainty -setup [expr 8.5*0.2] [get_clocks FCLK]
set_clock_uncertainty -hold [expr 8.5*0.15] [get_clocks SCLK]
set_clock_uncertainty -hold [expr 8.5*0.15] [get_clocks HCLK]
set_clock_uncertainty -hold [expr 8.5*0.15] [get_clocks SWCLKTCK]
set_clock_uncertainty -hold [expr 8.5*0.15] [get_clocks DCLK]
set_clock_uncertainty -hold [expr 8.5*0.15] [get_clocks FCLK]

set_driving_cell -lib_cell BUFFD8BWP40P140HVT [get_ports [remove_from_collection [all_inputs ] {SCLK HCLK SWCLKTCK FCLK DCLK}]]
set_load  0.00153669 [all_outputs ]
set_host_options -max_cores 16
compile
report_timing
