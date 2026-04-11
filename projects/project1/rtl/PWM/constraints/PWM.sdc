utilization 40%

avoid using CK, D24, D20, D18, CLOCKS Buffers

avoid 1x gap between std_cells

disable scandef 

avoid CK buffers 

Target skew  100ps

create NDR's 2w2s (root, internal)  1w2s(sink)

## removing existing Uncertainity #######
remove_clock_uncertainty [get_clocks clk]
set_clock_uncertainty [expr {2*0.15}] -scenarios [get_scenarios ] -setup [get_clocks clk] 
set_clock_uncertainty 0.05 -scenarios [get_scenarios *setup* ] -hold [get_clocks clk]		
set_clock_uncertainty 0.015 -scenarios [get_scenarios *hold* ] -hold [get_clocks clk]	

set_clock_uncertainty [expr {2*0.12}] -scenarios [get_scenarios ] -setup [get_clocks clk]
set_clock_uncertainty 0.05 -scenarios [get_scenarios *setup* ] -hold [get_clocks clk]
set_clock_uncertainty 0.015 -scenarios [get_scenarios *hold* ] -hold [get_clocks clk]
