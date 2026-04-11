
clock period = 2ns
input delays = 30% of clock period
uncertainty = 10% of clock period

set_driving_cell -lib_cell BUFFD8BWP30P140HVT [get_ports [remove_from_collection [all_inputs ] {SCK } ]]
set_load 0.00135745 [all_outputs ]
set_clock_uncertainty 0.2 [get_clocks]

