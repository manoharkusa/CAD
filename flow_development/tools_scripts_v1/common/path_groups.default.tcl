##Default path groups across the flow
group_path -name in2reg -from [get_ports [remove_from_collection [all_inputs] clk]] -to [all_registers -data_pins]
group_path -name reg2reg -from [all_registers -clock_pins] -to [all_registers -data_pins]
group_path -name reg2out -from [all_registers -clock_pins] -to [all_outputs]
group_path -name in2out -from [get_ports [remove_from_collection [all_inputs] clk]] -to [all_outputs]


if {$design_with_macros} {
##Add reg2mem & mem2reg path groups

}

