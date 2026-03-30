# ####################################################################

#  Created by Genus(TM) Synthesis Solution 21.18-s082_1 on Tue Mar 17 17:49:45 IST 2026

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design aes_cipher_top

create_clock -name "clk" -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_clock_transition -max 0.1 [get_clocks clk]
set_dont_touch_network [get_clocks clk]
set_false_path -from [get_ports rst]
group_path -weight 1.000000 -name cg_enable_group_default -through [list \
  [get_pins u0/r0_RC_CG_HIER_INST34/enable]  \
  [get_pins u0/r0_RC_CG_HIER_INST34/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST2/enable]  \
  [get_pins u0/RC_CG_HIER_INST2/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST3/enable]  \
  [get_pins u0/RC_CG_HIER_INST3/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST4/enable]  \
  [get_pins u0/RC_CG_HIER_INST4/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST5/enable]  \
  [get_pins u0/RC_CG_HIER_INST5/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST6/enable]  \
  [get_pins u0/RC_CG_HIER_INST6/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST7/enable]  \
  [get_pins u0/RC_CG_HIER_INST7/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST8/enable]  \
  [get_pins u0/RC_CG_HIER_INST8/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST9/enable]  \
  [get_pins u0/RC_CG_HIER_INST9/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST10/enable]  \
  [get_pins u0/RC_CG_HIER_INST10/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST11/enable]  \
  [get_pins u0/RC_CG_HIER_INST11/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST12/enable]  \
  [get_pins u0/RC_CG_HIER_INST12/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST13/enable]  \
  [get_pins u0/RC_CG_HIER_INST13/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST14/enable]  \
  [get_pins u0/RC_CG_HIER_INST14/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST15/enable]  \
  [get_pins u0/RC_CG_HIER_INST15/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST16/enable]  \
  [get_pins u0/RC_CG_HIER_INST16/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST17/enable]  \
  [get_pins u0/RC_CG_HIER_INST17/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST18/enable]  \
  [get_pins u0/RC_CG_HIER_INST18/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST19/enable]  \
  [get_pins u0/RC_CG_HIER_INST19/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST20/enable]  \
  [get_pins u0/RC_CG_HIER_INST20/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST21/enable]  \
  [get_pins u0/RC_CG_HIER_INST21/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST22/enable]  \
  [get_pins u0/RC_CG_HIER_INST22/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST23/enable]  \
  [get_pins u0/RC_CG_HIER_INST23/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST24/enable]  \
  [get_pins u0/RC_CG_HIER_INST24/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST25/enable]  \
  [get_pins u0/RC_CG_HIER_INST25/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST26/enable]  \
  [get_pins u0/RC_CG_HIER_INST26/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST27/enable]  \
  [get_pins u0/RC_CG_HIER_INST27/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST28/enable]  \
  [get_pins u0/RC_CG_HIER_INST28/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST29/enable]  \
  [get_pins u0/RC_CG_HIER_INST29/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST30/enable]  \
  [get_pins u0/RC_CG_HIER_INST30/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST31/enable]  \
  [get_pins u0/RC_CG_HIER_INST31/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST32/enable]  \
  [get_pins u0/RC_CG_HIER_INST32/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST33/enable]  \
  [get_pins u0/RC_CG_HIER_INST33/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST0/enable]  \
  [get_pins RC_CG_HIER_INST0/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST1/enable]  \
  [get_pins RC_CG_HIER_INST1/RC_CGIC_INST/E] ]
group_path -weight 1.000000 -name cg_enable_group_clk -through [list \
  [get_pins RC_CG_HIER_INST0/enable]  \
  [get_pins RC_CG_HIER_INST0/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST1/enable]  \
  [get_pins RC_CG_HIER_INST1/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST2/enable]  \
  [get_pins u0/RC_CG_HIER_INST2/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST3/enable]  \
  [get_pins u0/RC_CG_HIER_INST3/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST4/enable]  \
  [get_pins u0/RC_CG_HIER_INST4/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST5/enable]  \
  [get_pins u0/RC_CG_HIER_INST5/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST6/enable]  \
  [get_pins u0/RC_CG_HIER_INST6/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST7/enable]  \
  [get_pins u0/RC_CG_HIER_INST7/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST8/enable]  \
  [get_pins u0/RC_CG_HIER_INST8/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST9/enable]  \
  [get_pins u0/RC_CG_HIER_INST9/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST10/enable]  \
  [get_pins u0/RC_CG_HIER_INST10/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST11/enable]  \
  [get_pins u0/RC_CG_HIER_INST11/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST12/enable]  \
  [get_pins u0/RC_CG_HIER_INST12/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST13/enable]  \
  [get_pins u0/RC_CG_HIER_INST13/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST14/enable]  \
  [get_pins u0/RC_CG_HIER_INST14/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST15/enable]  \
  [get_pins u0/RC_CG_HIER_INST15/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST16/enable]  \
  [get_pins u0/RC_CG_HIER_INST16/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST17/enable]  \
  [get_pins u0/RC_CG_HIER_INST17/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST18/enable]  \
  [get_pins u0/RC_CG_HIER_INST18/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST19/enable]  \
  [get_pins u0/RC_CG_HIER_INST19/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST20/enable]  \
  [get_pins u0/RC_CG_HIER_INST20/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST21/enable]  \
  [get_pins u0/RC_CG_HIER_INST21/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST22/enable]  \
  [get_pins u0/RC_CG_HIER_INST22/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST23/enable]  \
  [get_pins u0/RC_CG_HIER_INST23/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST24/enable]  \
  [get_pins u0/RC_CG_HIER_INST24/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST25/enable]  \
  [get_pins u0/RC_CG_HIER_INST25/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST26/enable]  \
  [get_pins u0/RC_CG_HIER_INST26/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST27/enable]  \
  [get_pins u0/RC_CG_HIER_INST27/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST28/enable]  \
  [get_pins u0/RC_CG_HIER_INST28/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST29/enable]  \
  [get_pins u0/RC_CG_HIER_INST29/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST30/enable]  \
  [get_pins u0/RC_CG_HIER_INST30/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST31/enable]  \
  [get_pins u0/RC_CG_HIER_INST31/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST32/enable]  \
  [get_pins u0/RC_CG_HIER_INST32/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST33/enable]  \
  [get_pins u0/RC_CG_HIER_INST33/RC_CGIC_INST/E]  \
  [get_pins u0/r0_RC_CG_HIER_INST34/enable]  \
  [get_pins u0/r0_RC_CG_HIER_INST34/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST0/enable]  \
  [get_pins RC_CG_HIER_INST1/enable]  \
  [get_pins u0/RC_CG_HIER_INST2/enable]  \
  [get_pins u0/RC_CG_HIER_INST3/enable]  \
  [get_pins u0/RC_CG_HIER_INST4/enable]  \
  [get_pins u0/RC_CG_HIER_INST5/enable]  \
  [get_pins u0/RC_CG_HIER_INST6/enable]  \
  [get_pins u0/RC_CG_HIER_INST7/enable]  \
  [get_pins u0/RC_CG_HIER_INST8/enable]  \
  [get_pins u0/RC_CG_HIER_INST9/enable]  \
  [get_pins u0/RC_CG_HIER_INST10/enable]  \
  [get_pins u0/RC_CG_HIER_INST11/enable]  \
  [get_pins u0/RC_CG_HIER_INST12/enable]  \
  [get_pins u0/RC_CG_HIER_INST13/enable]  \
  [get_pins u0/RC_CG_HIER_INST14/enable]  \
  [get_pins u0/RC_CG_HIER_INST15/enable]  \
  [get_pins u0/RC_CG_HIER_INST16/enable]  \
  [get_pins u0/RC_CG_HIER_INST17/enable]  \
  [get_pins u0/RC_CG_HIER_INST18/enable]  \
  [get_pins u0/RC_CG_HIER_INST19/enable]  \
  [get_pins u0/RC_CG_HIER_INST20/enable]  \
  [get_pins u0/RC_CG_HIER_INST21/enable]  \
  [get_pins u0/RC_CG_HIER_INST22/enable]  \
  [get_pins u0/RC_CG_HIER_INST23/enable]  \
  [get_pins u0/RC_CG_HIER_INST24/enable]  \
  [get_pins u0/RC_CG_HIER_INST25/enable]  \
  [get_pins u0/RC_CG_HIER_INST26/enable]  \
  [get_pins u0/RC_CG_HIER_INST27/enable]  \
  [get_pins u0/RC_CG_HIER_INST28/enable]  \
  [get_pins u0/RC_CG_HIER_INST29/enable]  \
  [get_pins u0/RC_CG_HIER_INST30/enable]  \
  [get_pins u0/RC_CG_HIER_INST31/enable]  \
  [get_pins u0/RC_CG_HIER_INST32/enable]  \
  [get_pins u0/RC_CG_HIER_INST33/enable]  \
  [get_pins u0/r0_RC_CG_HIER_INST34/enable] ]
group_path -weight 1.000000 -name in2reg -from [list \
  [get_ports rst]  \
  [get_ports ld]  \
  [get_ports {key[127]}]  \
  [get_ports {key[126]}]  \
  [get_ports {key[125]}]  \
  [get_ports {key[124]}]  \
  [get_ports {key[123]}]  \
  [get_ports {key[122]}]  \
  [get_ports {key[121]}]  \
  [get_ports {key[120]}]  \
  [get_ports {key[119]}]  \
  [get_ports {key[118]}]  \
  [get_ports {key[117]}]  \
  [get_ports {key[116]}]  \
  [get_ports {key[115]}]  \
  [get_ports {key[114]}]  \
  [get_ports {key[113]}]  \
  [get_ports {key[112]}]  \
  [get_ports {key[111]}]  \
  [get_ports {key[110]}]  \
  [get_ports {key[109]}]  \
  [get_ports {key[108]}]  \
  [get_ports {key[107]}]  \
  [get_ports {key[106]}]  \
  [get_ports {key[105]}]  \
  [get_ports {key[104]}]  \
  [get_ports {key[103]}]  \
  [get_ports {key[102]}]  \
  [get_ports {key[101]}]  \
  [get_ports {key[100]}]  \
  [get_ports {key[99]}]  \
  [get_ports {key[98]}]  \
  [get_ports {key[97]}]  \
  [get_ports {key[96]}]  \
  [get_ports {key[95]}]  \
  [get_ports {key[94]}]  \
  [get_ports {key[93]}]  \
  [get_ports {key[92]}]  \
  [get_ports {key[91]}]  \
  [get_ports {key[90]}]  \
  [get_ports {key[89]}]  \
  [get_ports {key[88]}]  \
  [get_ports {key[87]}]  \
  [get_ports {key[86]}]  \
  [get_ports {key[85]}]  \
  [get_ports {key[84]}]  \
  [get_ports {key[83]}]  \
  [get_ports {key[82]}]  \
  [get_ports {key[81]}]  \
  [get_ports {key[80]}]  \
  [get_ports {key[79]}]  \
  [get_ports {key[78]}]  \
  [get_ports {key[77]}]  \
  [get_ports {key[76]}]  \
  [get_ports {key[75]}]  \
  [get_ports {key[74]}]  \
  [get_ports {key[73]}]  \
  [get_ports {key[72]}]  \
  [get_ports {key[71]}]  \
  [get_ports {key[70]}]  \
  [get_ports {key[69]}]  \
  [get_ports {key[68]}]  \
  [get_ports {key[67]}]  \
  [get_ports {key[66]}]  \
  [get_ports {key[65]}]  \
  [get_ports {key[64]}]  \
  [get_ports {key[63]}]  \
  [get_ports {key[62]}]  \
  [get_ports {key[61]}]  \
  [get_ports {key[60]}]  \
  [get_ports {key[59]}]  \
  [get_ports {key[58]}]  \
  [get_ports {key[57]}]  \
  [get_ports {key[56]}]  \
  [get_ports {key[55]}]  \
  [get_ports {key[54]}]  \
  [get_ports {key[53]}]  \
  [get_ports {key[52]}]  \
  [get_ports {key[51]}]  \
  [get_ports {key[50]}]  \
  [get_ports {key[49]}]  \
  [get_ports {key[48]}]  \
  [get_ports {key[47]}]  \
  [get_ports {key[46]}]  \
  [get_ports {key[45]}]  \
  [get_ports {key[44]}]  \
  [get_ports {key[43]}]  \
  [get_ports {key[42]}]  \
  [get_ports {key[41]}]  \
  [get_ports {key[40]}]  \
  [get_ports {key[39]}]  \
  [get_ports {key[38]}]  \
  [get_ports {key[37]}]  \
  [get_ports {key[36]}]  \
  [get_ports {key[35]}]  \
  [get_ports {key[34]}]  \
  [get_ports {key[33]}]  \
  [get_ports {key[32]}]  \
  [get_ports {key[31]}]  \
  [get_ports {key[30]}]  \
  [get_ports {key[29]}]  \
  [get_ports {key[28]}]  \
  [get_ports {key[27]}]  \
  [get_ports {key[26]}]  \
  [get_ports {key[25]}]  \
  [get_ports {key[24]}]  \
  [get_ports {key[23]}]  \
  [get_ports {key[22]}]  \
  [get_ports {key[21]}]  \
  [get_ports {key[20]}]  \
  [get_ports {key[19]}]  \
  [get_ports {key[18]}]  \
  [get_ports {key[17]}]  \
  [get_ports {key[16]}]  \
  [get_ports {key[15]}]  \
  [get_ports {key[14]}]  \
  [get_ports {key[13]}]  \
  [get_ports {key[12]}]  \
  [get_ports {key[11]}]  \
  [get_ports {key[10]}]  \
  [get_ports {key[9]}]  \
  [get_ports {key[8]}]  \
  [get_ports {key[7]}]  \
  [get_ports {key[6]}]  \
  [get_ports {key[5]}]  \
  [get_ports {key[4]}]  \
  [get_ports {key[3]}]  \
  [get_ports {key[2]}]  \
  [get_ports {key[1]}]  \
  [get_ports {key[0]}]  \
  [get_ports {text_in[127]}]  \
  [get_ports {text_in[126]}]  \
  [get_ports {text_in[125]}]  \
  [get_ports {text_in[124]}]  \
  [get_ports {text_in[123]}]  \
  [get_ports {text_in[122]}]  \
  [get_ports {text_in[121]}]  \
  [get_ports {text_in[120]}]  \
  [get_ports {text_in[119]}]  \
  [get_ports {text_in[118]}]  \
  [get_ports {text_in[117]}]  \
  [get_ports {text_in[116]}]  \
  [get_ports {text_in[115]}]  \
  [get_ports {text_in[114]}]  \
  [get_ports {text_in[113]}]  \
  [get_ports {text_in[112]}]  \
  [get_ports {text_in[111]}]  \
  [get_ports {text_in[110]}]  \
  [get_ports {text_in[109]}]  \
  [get_ports {text_in[108]}]  \
  [get_ports {text_in[107]}]  \
  [get_ports {text_in[106]}]  \
  [get_ports {text_in[105]}]  \
  [get_ports {text_in[104]}]  \
  [get_ports {text_in[103]}]  \
  [get_ports {text_in[102]}]  \
  [get_ports {text_in[101]}]  \
  [get_ports {text_in[100]}]  \
  [get_ports {text_in[99]}]  \
  [get_ports {text_in[98]}]  \
  [get_ports {text_in[97]}]  \
  [get_ports {text_in[96]}]  \
  [get_ports {text_in[95]}]  \
  [get_ports {text_in[94]}]  \
  [get_ports {text_in[93]}]  \
  [get_ports {text_in[92]}]  \
  [get_ports {text_in[91]}]  \
  [get_ports {text_in[90]}]  \
  [get_ports {text_in[89]}]  \
  [get_ports {text_in[88]}]  \
  [get_ports {text_in[87]}]  \
  [get_ports {text_in[86]}]  \
  [get_ports {text_in[85]}]  \
  [get_ports {text_in[84]}]  \
  [get_ports {text_in[83]}]  \
  [get_ports {text_in[82]}]  \
  [get_ports {text_in[81]}]  \
  [get_ports {text_in[80]}]  \
  [get_ports {text_in[79]}]  \
  [get_ports {text_in[78]}]  \
  [get_ports {text_in[77]}]  \
  [get_ports {text_in[76]}]  \
  [get_ports {text_in[75]}]  \
  [get_ports {text_in[74]}]  \
  [get_ports {text_in[73]}]  \
  [get_ports {text_in[72]}]  \
  [get_ports {text_in[71]}]  \
  [get_ports {text_in[70]}]  \
  [get_ports {text_in[69]}]  \
  [get_ports {text_in[68]}]  \
  [get_ports {text_in[67]}]  \
  [get_ports {text_in[66]}]  \
  [get_ports {text_in[65]}]  \
  [get_ports {text_in[64]}]  \
  [get_ports {text_in[63]}]  \
  [get_ports {text_in[62]}]  \
  [get_ports {text_in[61]}]  \
  [get_ports {text_in[60]}]  \
  [get_ports {text_in[59]}]  \
  [get_ports {text_in[58]}]  \
  [get_ports {text_in[57]}]  \
  [get_ports {text_in[56]}]  \
  [get_ports {text_in[55]}]  \
  [get_ports {text_in[54]}]  \
  [get_ports {text_in[53]}]  \
  [get_ports {text_in[52]}]  \
  [get_ports {text_in[51]}]  \
  [get_ports {text_in[50]}]  \
  [get_ports {text_in[49]}]  \
  [get_ports {text_in[48]}]  \
  [get_ports {text_in[47]}]  \
  [get_ports {text_in[46]}]  \
  [get_ports {text_in[45]}]  \
  [get_ports {text_in[44]}]  \
  [get_ports {text_in[43]}]  \
  [get_ports {text_in[42]}]  \
  [get_ports {text_in[41]}]  \
  [get_ports {text_in[40]}]  \
  [get_ports {text_in[39]}]  \
  [get_ports {text_in[38]}]  \
  [get_ports {text_in[37]}]  \
  [get_ports {text_in[36]}]  \
  [get_ports {text_in[35]}]  \
  [get_ports {text_in[34]}]  \
  [get_ports {text_in[33]}]  \
  [get_ports {text_in[32]}]  \
  [get_ports {text_in[31]}]  \
  [get_ports {text_in[30]}]  \
  [get_ports {text_in[29]}]  \
  [get_ports {text_in[28]}]  \
  [get_ports {text_in[27]}]  \
  [get_ports {text_in[26]}]  \
  [get_ports {text_in[25]}]  \
  [get_ports {text_in[24]}]  \
  [get_ports {text_in[23]}]  \
  [get_ports {text_in[22]}]  \
  [get_ports {text_in[21]}]  \
  [get_ports {text_in[20]}]  \
  [get_ports {text_in[19]}]  \
  [get_ports {text_in[18]}]  \
  [get_ports {text_in[17]}]  \
  [get_ports {text_in[16]}]  \
  [get_ports {text_in[15]}]  \
  [get_ports {text_in[14]}]  \
  [get_ports {text_in[13]}]  \
  [get_ports {text_in[12]}]  \
  [get_ports {text_in[11]}]  \
  [get_ports {text_in[10]}]  \
  [get_ports {text_in[9]}]  \
  [get_ports {text_in[8]}]  \
  [get_ports {text_in[7]}]  \
  [get_ports {text_in[6]}]  \
  [get_ports {text_in[5]}]  \
  [get_ports {text_in[4]}]  \
  [get_ports {text_in[3]}]  \
  [get_ports {text_in[2]}]  \
  [get_ports {text_in[1]}]  \
  [get_ports {text_in[0]}] ] -to [list \
  [get_pins RC_CG_HIER_INST0/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST0/RC_CGIC_INST/TE]  \
  [get_pins RC_CG_HIER_INST1/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST1/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST2/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST2/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST3/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST3/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST4/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST4/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST5/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST5/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST6/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST6/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST7/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST7/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST8/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST8/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST9/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST9/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST10/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST10/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST11/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST11/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST12/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST12/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST13/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST13/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST14/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST14/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST15/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST15/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST16/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST16/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST17/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST17/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST18/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST18/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST19/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST19/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST20/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST20/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST21/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST21/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST22/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST22/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST23/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST23/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST24/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST24/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST25/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST25/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST26/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST26/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST27/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST27/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST28/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST28/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST29/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST29/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST30/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST30/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST31/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST31/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST32/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST32/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST33/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST33/RC_CGIC_INST/TE]  \
  [get_pins u0/r0_RC_CG_HIER_INST34/RC_CGIC_INST/E]  \
  [get_pins u0/r0_RC_CG_HIER_INST34/RC_CGIC_INST/TE]  \
  [get_pins {u0/r0_out_reg[24]/D}]  \
  [get_pins {u0/r0_out_reg[25]/CN}]  \
  [get_pins {u0/r0_out_reg[25]/D}]  \
  [get_pins {u0/r0_out_reg[26]/CN}]  \
  [get_pins {u0/r0_out_reg[26]/D}]  \
  [get_pins {u0/r0_out_reg[27]/CN}]  \
  [get_pins {u0/r0_out_reg[27]/D}]  \
  [get_pins {u0/r0_out_reg[28]/CN}]  \
  [get_pins {u0/r0_out_reg[28]/D}]  \
  [get_pins {u0/r0_out_reg[29]/CN}]  \
  [get_pins {u0/r0_out_reg[29]/D}]  \
  [get_pins {u0/r0_out_reg[30]/CN}]  \
  [get_pins {u0/r0_out_reg[30]/D}]  \
  [get_pins {u0/r0_out_reg[31]/CN}]  \
  [get_pins {u0/r0_out_reg[31]/D}]  \
  [get_pins {u0/r0_rcnt_reg[0]/D}]  \
  [get_pins {u0/r0_rcnt_reg[1]/D}]  \
  [get_pins {u0/r0_rcnt_reg[2]/CN}]  \
  [get_pins {u0/r0_rcnt_reg[2]/D}]  \
  [get_pins {u0/r0_rcnt_reg[3]/CN}]  \
  [get_pins {u0/r0_rcnt_reg[3]/D}]  \
  [get_pins {u0/w_reg[0][0]/DA}]  \
  [get_pins {u0/w_reg[0][0]/DB}]  \
  [get_pins {u0/w_reg[0][0]/SA}]  \
  [get_pins {u0/w_reg[0][1]/DA}]  \
  [get_pins {u0/w_reg[0][1]/DB}]  \
  [get_pins {u0/w_reg[0][1]/SA}]  \
  [get_pins {u0/w_reg[0][2]/DA}]  \
  [get_pins {u0/w_reg[0][2]/DB}]  \
  [get_pins {u0/w_reg[0][2]/SA}]  \
  [get_pins {u0/w_reg[0][3]/DA}]  \
  [get_pins {u0/w_reg[0][3]/DB}]  \
  [get_pins {u0/w_reg[0][3]/SA}]  \
  [get_pins {u0/w_reg[0][4]/DA}]  \
  [get_pins {u0/w_reg[0][4]/DB}]  \
  [get_pins {u0/w_reg[0][4]/SA}]  \
  [get_pins {u0/w_reg[0][5]/DA}]  \
  [get_pins {u0/w_reg[0][5]/DB}]  \
  [get_pins {u0/w_reg[0][5]/SA}]  \
  [get_pins {u0/w_reg[0][6]/DA}]  \
  [get_pins {u0/w_reg[0][6]/DB}]  \
  [get_pins {u0/w_reg[0][6]/SA}]  \
  [get_pins {u0/w_reg[0][7]/DA}]  \
  [get_pins {u0/w_reg[0][7]/DB}]  \
  [get_pins {u0/w_reg[0][7]/SA}]  \
  [get_pins {u0/w_reg[0][8]/DA}]  \
  [get_pins {u0/w_reg[0][8]/DB}]  \
  [get_pins {u0/w_reg[0][8]/SA}]  \
  [get_pins {u0/w_reg[0][9]/DA}]  \
  [get_pins {u0/w_reg[0][9]/DB}]  \
  [get_pins {u0/w_reg[0][9]/SA}]  \
  [get_pins {u0/w_reg[0][10]/DA}]  \
  [get_pins {u0/w_reg[0][10]/DB}]  \
  [get_pins {u0/w_reg[0][10]/SA}]  \
  [get_pins {u0/w_reg[0][11]/DA}]  \
  [get_pins {u0/w_reg[0][11]/DB}]  \
  [get_pins {u0/w_reg[0][11]/SA}]  \
  [get_pins {u0/w_reg[0][12]/DA}]  \
  [get_pins {u0/w_reg[0][12]/DB}]  \
  [get_pins {u0/w_reg[0][12]/SA}]  \
  [get_pins {u0/w_reg[0][13]/DA}]  \
  [get_pins {u0/w_reg[0][13]/DB}]  \
  [get_pins {u0/w_reg[0][13]/SA}]  \
  [get_pins {u0/w_reg[0][14]/DA}]  \
  [get_pins {u0/w_reg[0][14]/DB}]  \
  [get_pins {u0/w_reg[0][14]/SA}]  \
  [get_pins {u0/w_reg[0][15]/DA}]  \
  [get_pins {u0/w_reg[0][15]/DB}]  \
  [get_pins {u0/w_reg[0][15]/SA}]  \
  [get_pins {u0/w_reg[0][16]/DA}]  \
  [get_pins {u0/w_reg[0][16]/DB}]  \
  [get_pins {u0/w_reg[0][16]/SA}]  \
  [get_pins {u0/w_reg[0][17]/DA}]  \
  [get_pins {u0/w_reg[0][17]/DB}]  \
  [get_pins {u0/w_reg[0][17]/SA}]  \
  [get_pins {u0/w_reg[0][18]/DA}]  \
  [get_pins {u0/w_reg[0][18]/DB}]  \
  [get_pins {u0/w_reg[0][18]/SA}]  \
  [get_pins {u0/w_reg[0][19]/DA}]  \
  [get_pins {u0/w_reg[0][19]/DB}]  \
  [get_pins {u0/w_reg[0][19]/SA}]  \
  [get_pins {u0/w_reg[0][20]/DA}]  \
  [get_pins {u0/w_reg[0][20]/DB}]  \
  [get_pins {u0/w_reg[0][20]/SA}]  \
  [get_pins {u0/w_reg[0][21]/DA}]  \
  [get_pins {u0/w_reg[0][21]/DB}]  \
  [get_pins {u0/w_reg[0][21]/SA}]  \
  [get_pins {u0/w_reg[0][22]/DA}]  \
  [get_pins {u0/w_reg[0][22]/DB}]  \
  [get_pins {u0/w_reg[0][22]/SA}]  \
  [get_pins {u0/w_reg[0][23]/DA}]  \
  [get_pins {u0/w_reg[0][23]/DB}]  \
  [get_pins {u0/w_reg[0][23]/SA}]  \
  [get_pins {u0/w_reg[0][24]/DA}]  \
  [get_pins {u0/w_reg[0][24]/DB}]  \
  [get_pins {u0/w_reg[0][24]/SA}]  \
  [get_pins {u0/w_reg[0][25]/DA}]  \
  [get_pins {u0/w_reg[0][25]/DB}]  \
  [get_pins {u0/w_reg[0][25]/SA}]  \
  [get_pins {u0/w_reg[0][26]/DA}]  \
  [get_pins {u0/w_reg[0][26]/DB}]  \
  [get_pins {u0/w_reg[0][26]/SA}]  \
  [get_pins {u0/w_reg[0][27]/DA}]  \
  [get_pins {u0/w_reg[0][27]/DB}]  \
  [get_pins {u0/w_reg[0][27]/SA}]  \
  [get_pins {u0/w_reg[0][28]/DA}]  \
  [get_pins {u0/w_reg[0][28]/DB}]  \
  [get_pins {u0/w_reg[0][28]/SA}]  \
  [get_pins {u0/w_reg[0][29]/DA}]  \
  [get_pins {u0/w_reg[0][29]/DB}]  \
  [get_pins {u0/w_reg[0][29]/SA}]  \
  [get_pins {u0/w_reg[0][30]/DA}]  \
  [get_pins {u0/w_reg[0][30]/DB}]  \
  [get_pins {u0/w_reg[0][30]/SA}]  \
  [get_pins {u0/w_reg[0][31]/DA}]  \
  [get_pins {u0/w_reg[0][31]/DB}]  \
  [get_pins {u0/w_reg[0][31]/SA}]  \
  [get_pins {u0/w_reg[1][0]/DA}]  \
  [get_pins {u0/w_reg[1][0]/DB}]  \
  [get_pins {u0/w_reg[1][0]/SA}]  \
  [get_pins {u0/w_reg[1][1]/DA}]  \
  [get_pins {u0/w_reg[1][1]/DB}]  \
  [get_pins {u0/w_reg[1][1]/SA}]  \
  [get_pins {u0/w_reg[1][2]/DA}]  \
  [get_pins {u0/w_reg[1][2]/DB}]  \
  [get_pins {u0/w_reg[1][2]/SA}]  \
  [get_pins {u0/w_reg[1][3]/DA}]  \
  [get_pins {u0/w_reg[1][3]/DB}]  \
  [get_pins {u0/w_reg[1][3]/SA}]  \
  [get_pins {u0/w_reg[1][4]/DA}]  \
  [get_pins {u0/w_reg[1][4]/DB}]  \
  [get_pins {u0/w_reg[1][4]/SA}]  \
  [get_pins {u0/w_reg[1][5]/DA}]  \
  [get_pins {u0/w_reg[1][5]/DB}]  \
  [get_pins {u0/w_reg[1][5]/SA}]  \
  [get_pins {u0/w_reg[1][6]/DA}]  \
  [get_pins {u0/w_reg[1][6]/DB}]  \
  [get_pins {u0/w_reg[1][6]/SA}]  \
  [get_pins {u0/w_reg[1][7]/DA}]  \
  [get_pins {u0/w_reg[1][7]/DB}]  \
  [get_pins {u0/w_reg[1][7]/SA}]  \
  [get_pins {u0/w_reg[1][8]/DA}]  \
  [get_pins {u0/w_reg[1][8]/DB}]  \
  [get_pins {u0/w_reg[1][8]/SA}]  \
  [get_pins {u0/w_reg[1][9]/DA}]  \
  [get_pins {u0/w_reg[1][9]/DB}]  \
  [get_pins {u0/w_reg[1][9]/SA}]  \
  [get_pins {u0/w_reg[1][10]/DA}]  \
  [get_pins {u0/w_reg[1][10]/DB}]  \
  [get_pins {u0/w_reg[1][10]/SA}]  \
  [get_pins {u0/w_reg[1][11]/DA}]  \
  [get_pins {u0/w_reg[1][11]/DB}]  \
  [get_pins {u0/w_reg[1][11]/SA}]  \
  [get_pins {u0/w_reg[1][12]/DA}]  \
  [get_pins {u0/w_reg[1][12]/DB}]  \
  [get_pins {u0/w_reg[1][12]/SA}]  \
  [get_pins {u0/w_reg[1][13]/DA}]  \
  [get_pins {u0/w_reg[1][13]/DB}]  \
  [get_pins {u0/w_reg[1][13]/SA}]  \
  [get_pins {u0/w_reg[1][14]/DA}]  \
  [get_pins {u0/w_reg[1][14]/DB}]  \
  [get_pins {u0/w_reg[1][14]/SA}]  \
  [get_pins {u0/w_reg[1][15]/DA}]  \
  [get_pins {u0/w_reg[1][15]/DB}]  \
  [get_pins {u0/w_reg[1][15]/SA}]  \
  [get_pins {u0/w_reg[1][16]/DA}]  \
  [get_pins {u0/w_reg[1][16]/DB}]  \
  [get_pins {u0/w_reg[1][16]/SA}]  \
  [get_pins {u0/w_reg[1][17]/DA}]  \
  [get_pins {u0/w_reg[1][17]/DB}]  \
  [get_pins {u0/w_reg[1][17]/SA}]  \
  [get_pins {u0/w_reg[1][18]/DA}]  \
  [get_pins {u0/w_reg[1][18]/DB}]  \
  [get_pins {u0/w_reg[1][18]/SA}]  \
  [get_pins {u0/w_reg[1][19]/DA}]  \
  [get_pins {u0/w_reg[1][19]/DB}]  \
  [get_pins {u0/w_reg[1][19]/SA}]  \
  [get_pins {u0/w_reg[1][20]/DA}]  \
  [get_pins {u0/w_reg[1][20]/DB}]  \
  [get_pins {u0/w_reg[1][20]/SA}]  \
  [get_pins {u0/w_reg[1][21]/DA}]  \
  [get_pins {u0/w_reg[1][21]/DB}]  \
  [get_pins {u0/w_reg[1][21]/SA}]  \
  [get_pins {u0/w_reg[1][22]/DA}]  \
  [get_pins {u0/w_reg[1][22]/DB}]  \
  [get_pins {u0/w_reg[1][22]/SA}]  \
  [get_pins {u0/w_reg[1][23]/DA}]  \
  [get_pins {u0/w_reg[1][23]/DB}]  \
  [get_pins {u0/w_reg[1][23]/SA}]  \
  [get_pins {u0/w_reg[1][24]/DA}]  \
  [get_pins {u0/w_reg[1][24]/DB}]  \
  [get_pins {u0/w_reg[1][24]/SA}]  \
  [get_pins {u0/w_reg[1][25]/DA}]  \
  [get_pins {u0/w_reg[1][25]/DB}]  \
  [get_pins {u0/w_reg[1][25]/SA}]  \
  [get_pins {u0/w_reg[1][26]/DA}]  \
  [get_pins {u0/w_reg[1][26]/DB}]  \
  [get_pins {u0/w_reg[1][26]/SA}]  \
  [get_pins {u0/w_reg[1][27]/DA}]  \
  [get_pins {u0/w_reg[1][27]/DB}]  \
  [get_pins {u0/w_reg[1][27]/SA}]  \
  [get_pins {u0/w_reg[1][28]/DA}]  \
  [get_pins {u0/w_reg[1][28]/DB}]  \
  [get_pins {u0/w_reg[1][28]/SA}]  \
  [get_pins {u0/w_reg[1][29]/DA}]  \
  [get_pins {u0/w_reg[1][29]/DB}]  \
  [get_pins {u0/w_reg[1][29]/SA}]  \
  [get_pins {u0/w_reg[1][30]/DA}]  \
  [get_pins {u0/w_reg[1][30]/DB}]  \
  [get_pins {u0/w_reg[1][30]/SA}]  \
  [get_pins {u0/w_reg[1][31]/DA}]  \
  [get_pins {u0/w_reg[1][31]/DB}]  \
  [get_pins {u0/w_reg[1][31]/SA}]  \
  [get_pins {u0/w_reg[2][0]/DA}]  \
  [get_pins {u0/w_reg[2][0]/DB}]  \
  [get_pins {u0/w_reg[2][0]/SA}]  \
  [get_pins {u0/w_reg[2][1]/DA}]  \
  [get_pins {u0/w_reg[2][1]/DB}]  \
  [get_pins {u0/w_reg[2][1]/SA}]  \
  [get_pins {u0/w_reg[2][2]/DA}]  \
  [get_pins {u0/w_reg[2][2]/DB}]  \
  [get_pins {u0/w_reg[2][2]/SA}]  \
  [get_pins {u0/w_reg[2][3]/DA}]  \
  [get_pins {u0/w_reg[2][3]/DB}]  \
  [get_pins {u0/w_reg[2][3]/SA}]  \
  [get_pins {u0/w_reg[2][4]/DA}]  \
  [get_pins {u0/w_reg[2][4]/DB}]  \
  [get_pins {u0/w_reg[2][4]/SA}]  \
  [get_pins {u0/w_reg[2][5]/DA}]  \
  [get_pins {u0/w_reg[2][5]/DB}]  \
  [get_pins {u0/w_reg[2][5]/SA}]  \
  [get_pins {u0/w_reg[2][6]/DA}]  \
  [get_pins {u0/w_reg[2][6]/DB}]  \
  [get_pins {u0/w_reg[2][6]/SA}]  \
  [get_pins {u0/w_reg[2][7]/DA}]  \
  [get_pins {u0/w_reg[2][7]/DB}]  \
  [get_pins {u0/w_reg[2][7]/SA}]  \
  [get_pins {u0/w_reg[2][8]/DA}]  \
  [get_pins {u0/w_reg[2][8]/DB}]  \
  [get_pins {u0/w_reg[2][8]/SA}]  \
  [get_pins {u0/w_reg[2][9]/DA}]  \
  [get_pins {u0/w_reg[2][9]/DB}]  \
  [get_pins {u0/w_reg[2][9]/SA}]  \
  [get_pins {u0/w_reg[2][10]/DA}]  \
  [get_pins {u0/w_reg[2][10]/DB}]  \
  [get_pins {u0/w_reg[2][10]/SA}]  \
  [get_pins {u0/w_reg[2][11]/DA}]  \
  [get_pins {u0/w_reg[2][11]/DB}]  \
  [get_pins {u0/w_reg[2][11]/SA}]  \
  [get_pins {u0/w_reg[2][12]/DA}]  \
  [get_pins {u0/w_reg[2][12]/DB}]  \
  [get_pins {u0/w_reg[2][12]/SA}]  \
  [get_pins {u0/w_reg[2][13]/DA}]  \
  [get_pins {u0/w_reg[2][13]/DB}]  \
  [get_pins {u0/w_reg[2][13]/SA}]  \
  [get_pins {u0/w_reg[2][14]/DA}]  \
  [get_pins {u0/w_reg[2][14]/DB}]  \
  [get_pins {u0/w_reg[2][14]/SA}]  \
  [get_pins {u0/w_reg[2][15]/DA}]  \
  [get_pins {u0/w_reg[2][15]/DB}]  \
  [get_pins {u0/w_reg[2][15]/SA}]  \
  [get_pins {u0/w_reg[2][16]/DA}]  \
  [get_pins {u0/w_reg[2][16]/DB}]  \
  [get_pins {u0/w_reg[2][16]/SA}]  \
  [get_pins {u0/w_reg[2][17]/DA}]  \
  [get_pins {u0/w_reg[2][17]/DB}]  \
  [get_pins {u0/w_reg[2][17]/SA}]  \
  [get_pins {u0/w_reg[2][18]/DA}]  \
  [get_pins {u0/w_reg[2][18]/DB}]  \
  [get_pins {u0/w_reg[2][18]/SA}]  \
  [get_pins {u0/w_reg[2][19]/DA}]  \
  [get_pins {u0/w_reg[2][19]/DB}]  \
  [get_pins {u0/w_reg[2][19]/SA}]  \
  [get_pins {u0/w_reg[2][20]/DA}]  \
  [get_pins {u0/w_reg[2][20]/DB}]  \
  [get_pins {u0/w_reg[2][20]/SA}]  \
  [get_pins {u0/w_reg[2][21]/DA}]  \
  [get_pins {u0/w_reg[2][21]/DB}]  \
  [get_pins {u0/w_reg[2][21]/SA}]  \
  [get_pins {u0/w_reg[2][22]/DA}]  \
  [get_pins {u0/w_reg[2][22]/DB}]  \
  [get_pins {u0/w_reg[2][22]/SA}]  \
  [get_pins {u0/w_reg[2][23]/DA}]  \
  [get_pins {u0/w_reg[2][23]/DB}]  \
  [get_pins {u0/w_reg[2][23]/SA}]  \
  [get_pins {u0/w_reg[2][24]/DA}]  \
  [get_pins {u0/w_reg[2][24]/DB}]  \
  [get_pins {u0/w_reg[2][24]/SA}]  \
  [get_pins {u0/w_reg[2][25]/DA}]  \
  [get_pins {u0/w_reg[2][25]/DB}]  \
  [get_pins {u0/w_reg[2][25]/SA}]  \
  [get_pins {u0/w_reg[2][26]/DA}]  \
  [get_pins {u0/w_reg[2][26]/DB}]  \
  [get_pins {u0/w_reg[2][26]/SA}]  \
  [get_pins {u0/w_reg[2][27]/DA}]  \
  [get_pins {u0/w_reg[2][27]/DB}]  \
  [get_pins {u0/w_reg[2][27]/SA}]  \
  [get_pins {u0/w_reg[2][28]/DA}]  \
  [get_pins {u0/w_reg[2][28]/DB}]  \
  [get_pins {u0/w_reg[2][28]/SA}]  \
  [get_pins {u0/w_reg[2][29]/DA}]  \
  [get_pins {u0/w_reg[2][29]/DB}]  \
  [get_pins {u0/w_reg[2][29]/SA}]  \
  [get_pins {u0/w_reg[2][30]/DA}]  \
  [get_pins {u0/w_reg[2][30]/DB}]  \
  [get_pins {u0/w_reg[2][30]/SA}]  \
  [get_pins {u0/w_reg[2][31]/DA}]  \
  [get_pins {u0/w_reg[2][31]/DB}]  \
  [get_pins {u0/w_reg[2][31]/SA}]  \
  [get_pins {u0/w_reg[3][0]/DA}]  \
  [get_pins {u0/w_reg[3][0]/DB}]  \
  [get_pins {u0/w_reg[3][0]/SA}]  \
  [get_pins {u0/w_reg[3][1]/DA}]  \
  [get_pins {u0/w_reg[3][1]/DB}]  \
  [get_pins {u0/w_reg[3][1]/SA}]  \
  [get_pins {u0/w_reg[3][2]/DA}]  \
  [get_pins {u0/w_reg[3][2]/DB}]  \
  [get_pins {u0/w_reg[3][2]/SA}]  \
  [get_pins {u0/w_reg[3][3]/DA}]  \
  [get_pins {u0/w_reg[3][3]/DB}]  \
  [get_pins {u0/w_reg[3][3]/SA}]  \
  [get_pins {u0/w_reg[3][4]/DA}]  \
  [get_pins {u0/w_reg[3][4]/DB}]  \
  [get_pins {u0/w_reg[3][4]/SA}]  \
  [get_pins {u0/w_reg[3][5]/DA}]  \
  [get_pins {u0/w_reg[3][5]/DB}]  \
  [get_pins {u0/w_reg[3][5]/SA}]  \
  [get_pins {u0/w_reg[3][6]/DA}]  \
  [get_pins {u0/w_reg[3][6]/DB}]  \
  [get_pins {u0/w_reg[3][6]/SA}]  \
  [get_pins {u0/w_reg[3][7]/DA}]  \
  [get_pins {u0/w_reg[3][7]/DB}]  \
  [get_pins {u0/w_reg[3][7]/SA}]  \
  [get_pins {u0/w_reg[3][8]/DA}]  \
  [get_pins {u0/w_reg[3][8]/DB}]  \
  [get_pins {u0/w_reg[3][8]/SA}]  \
  [get_pins {u0/w_reg[3][9]/DA}]  \
  [get_pins {u0/w_reg[3][9]/DB}]  \
  [get_pins {u0/w_reg[3][9]/SA}]  \
  [get_pins {u0/w_reg[3][10]/DA}]  \
  [get_pins {u0/w_reg[3][10]/DB}]  \
  [get_pins {u0/w_reg[3][10]/SA}]  \
  [get_pins {u0/w_reg[3][11]/DA}]  \
  [get_pins {u0/w_reg[3][11]/DB}]  \
  [get_pins {u0/w_reg[3][11]/SA}]  \
  [get_pins {u0/w_reg[3][12]/DA}]  \
  [get_pins {u0/w_reg[3][12]/DB}]  \
  [get_pins {u0/w_reg[3][12]/SA}]  \
  [get_pins {u0/w_reg[3][13]/DA}]  \
  [get_pins {u0/w_reg[3][13]/DB}]  \
  [get_pins {u0/w_reg[3][13]/SA}]  \
  [get_pins {u0/w_reg[3][14]/DA}]  \
  [get_pins {u0/w_reg[3][14]/DB}]  \
  [get_pins {u0/w_reg[3][14]/SA}]  \
  [get_pins {u0/w_reg[3][15]/DA}]  \
  [get_pins {u0/w_reg[3][15]/DB}]  \
  [get_pins {u0/w_reg[3][15]/SA}]  \
  [get_pins {u0/w_reg[3][16]/DA}]  \
  [get_pins {u0/w_reg[3][16]/DB}]  \
  [get_pins {u0/w_reg[3][16]/SA}]  \
  [get_pins {u0/w_reg[3][17]/DA}]  \
  [get_pins {u0/w_reg[3][17]/DB}]  \
  [get_pins {u0/w_reg[3][17]/SA}]  \
  [get_pins {u0/w_reg[3][18]/DA}]  \
  [get_pins {u0/w_reg[3][18]/DB}]  \
  [get_pins {u0/w_reg[3][18]/SA}]  \
  [get_pins {u0/w_reg[3][19]/DA}]  \
  [get_pins {u0/w_reg[3][19]/DB}]  \
  [get_pins {u0/w_reg[3][19]/SA}]  \
  [get_pins {u0/w_reg[3][20]/DA}]  \
  [get_pins {u0/w_reg[3][20]/DB}]  \
  [get_pins {u0/w_reg[3][20]/SA}]  \
  [get_pins {u0/w_reg[3][21]/DA}]  \
  [get_pins {u0/w_reg[3][21]/DB}]  \
  [get_pins {u0/w_reg[3][21]/SA}]  \
  [get_pins {u0/w_reg[3][22]/DA}]  \
  [get_pins {u0/w_reg[3][22]/DB}]  \
  [get_pins {u0/w_reg[3][22]/SA}]  \
  [get_pins {u0/w_reg[3][23]/DA}]  \
  [get_pins {u0/w_reg[3][23]/DB}]  \
  [get_pins {u0/w_reg[3][23]/SA}]  \
  [get_pins {u0/w_reg[3][24]/DA}]  \
  [get_pins {u0/w_reg[3][24]/DB}]  \
  [get_pins {u0/w_reg[3][24]/SA}]  \
  [get_pins {u0/w_reg[3][25]/DA}]  \
  [get_pins {u0/w_reg[3][25]/DB}]  \
  [get_pins {u0/w_reg[3][25]/SA}]  \
  [get_pins {u0/w_reg[3][26]/DA}]  \
  [get_pins {u0/w_reg[3][26]/DB}]  \
  [get_pins {u0/w_reg[3][26]/SA}]  \
  [get_pins {u0/w_reg[3][27]/DA}]  \
  [get_pins {u0/w_reg[3][27]/DB}]  \
  [get_pins {u0/w_reg[3][27]/SA}]  \
  [get_pins {u0/w_reg[3][28]/DA}]  \
  [get_pins {u0/w_reg[3][28]/DB}]  \
  [get_pins {u0/w_reg[3][28]/SA}]  \
  [get_pins {u0/w_reg[3][29]/DA}]  \
  [get_pins {u0/w_reg[3][29]/DB}]  \
  [get_pins {u0/w_reg[3][29]/SA}]  \
  [get_pins {u0/w_reg[3][30]/DA}]  \
  [get_pins {u0/w_reg[3][30]/DB}]  \
  [get_pins {u0/w_reg[3][30]/SA}]  \
  [get_pins {u0/w_reg[3][31]/DA}]  \
  [get_pins {u0/w_reg[3][31]/DB}]  \
  [get_pins {u0/w_reg[3][31]/SA}]  \
  [get_pins done_reg/CN]  \
  [get_pins done_reg/D]  \
  [get_pins ld_r_reg/D]  \
  [get_pins {sa00_reg[0]/DA}]  \
  [get_pins {sa00_reg[0]/DB}]  \
  [get_pins {sa00_reg[0]/SA}]  \
  [get_pins {sa00_reg[1]/DA}]  \
  [get_pins {sa00_reg[1]/DB}]  \
  [get_pins {sa00_reg[1]/SA}]  \
  [get_pins {sa00_reg[2]/DA}]  \
  [get_pins {sa00_reg[2]/DB}]  \
  [get_pins {sa00_reg[2]/SA}]  \
  [get_pins {sa00_reg[3]/DA}]  \
  [get_pins {sa00_reg[3]/DB}]  \
  [get_pins {sa00_reg[3]/SA}]  \
  [get_pins {sa00_reg[4]/DA}]  \
  [get_pins {sa00_reg[4]/DB}]  \
  [get_pins {sa00_reg[4]/SA}]  \
  [get_pins {sa00_reg[5]/DA}]  \
  [get_pins {sa00_reg[5]/DB}]  \
  [get_pins {sa00_reg[5]/SA}]  \
  [get_pins {sa00_reg[6]/DA}]  \
  [get_pins {sa00_reg[6]/DB}]  \
  [get_pins {sa00_reg[6]/SA}]  \
  [get_pins {sa00_reg[7]/DA}]  \
  [get_pins {sa00_reg[7]/DB}]  \
  [get_pins {sa00_reg[7]/SA}]  \
  [get_pins {sa01_reg[0]/DA}]  \
  [get_pins {sa01_reg[0]/DB}]  \
  [get_pins {sa01_reg[0]/SA}]  \
  [get_pins {sa01_reg[1]/DA}]  \
  [get_pins {sa01_reg[1]/DB}]  \
  [get_pins {sa01_reg[1]/SA}]  \
  [get_pins {sa01_reg[2]/DA}]  \
  [get_pins {sa01_reg[2]/DB}]  \
  [get_pins {sa01_reg[2]/SA}]  \
  [get_pins {sa01_reg[3]/DA}]  \
  [get_pins {sa01_reg[3]/DB}]  \
  [get_pins {sa01_reg[3]/SA}]  \
  [get_pins {sa01_reg[4]/DA}]  \
  [get_pins {sa01_reg[4]/DB}]  \
  [get_pins {sa01_reg[4]/SA}]  \
  [get_pins {sa01_reg[5]/DA}]  \
  [get_pins {sa01_reg[5]/DB}]  \
  [get_pins {sa01_reg[5]/SA}]  \
  [get_pins {sa01_reg[6]/DA}]  \
  [get_pins {sa01_reg[6]/DB}]  \
  [get_pins {sa01_reg[6]/SA}]  \
  [get_pins {sa01_reg[7]/DA}]  \
  [get_pins {sa01_reg[7]/DB}]  \
  [get_pins {sa01_reg[7]/SA}]  \
  [get_pins {sa02_reg[0]/DA}]  \
  [get_pins {sa02_reg[0]/DB}]  \
  [get_pins {sa02_reg[0]/SA}]  \
  [get_pins {sa02_reg[1]/DA}]  \
  [get_pins {sa02_reg[1]/DB}]  \
  [get_pins {sa02_reg[1]/SA}]  \
  [get_pins {sa02_reg[2]/DA}]  \
  [get_pins {sa02_reg[2]/DB}]  \
  [get_pins {sa02_reg[2]/SA}]  \
  [get_pins {sa02_reg[3]/DA}]  \
  [get_pins {sa02_reg[3]/DB}]  \
  [get_pins {sa02_reg[3]/SA}]  \
  [get_pins {sa02_reg[4]/DA}]  \
  [get_pins {sa02_reg[4]/DB}]  \
  [get_pins {sa02_reg[4]/SA}]  \
  [get_pins {sa02_reg[5]/DA}]  \
  [get_pins {sa02_reg[5]/DB}]  \
  [get_pins {sa02_reg[5]/SA}]  \
  [get_pins {sa02_reg[6]/DA}]  \
  [get_pins {sa02_reg[6]/DB}]  \
  [get_pins {sa02_reg[6]/SA}]  \
  [get_pins {sa02_reg[7]/DA}]  \
  [get_pins {sa02_reg[7]/DB}]  \
  [get_pins {sa02_reg[7]/SA}]  \
  [get_pins {sa03_reg[0]/DA}]  \
  [get_pins {sa03_reg[0]/DB}]  \
  [get_pins {sa03_reg[0]/SA}]  \
  [get_pins {sa03_reg[1]/DA}]  \
  [get_pins {sa03_reg[1]/DB}]  \
  [get_pins {sa03_reg[1]/SA}]  \
  [get_pins {sa03_reg[2]/DA}]  \
  [get_pins {sa03_reg[2]/DB}]  \
  [get_pins {sa03_reg[2]/SA}]  \
  [get_pins {sa03_reg[3]/DA}]  \
  [get_pins {sa03_reg[3]/DB}]  \
  [get_pins {sa03_reg[3]/SA}]  \
  [get_pins {sa03_reg[4]/DA}]  \
  [get_pins {sa03_reg[4]/DB}]  \
  [get_pins {sa03_reg[4]/SA}]  \
  [get_pins {sa03_reg[5]/DA}]  \
  [get_pins {sa03_reg[5]/DB}]  \
  [get_pins {sa03_reg[5]/SA}]  \
  [get_pins {sa03_reg[6]/DA}]  \
  [get_pins {sa03_reg[6]/DB}]  \
  [get_pins {sa03_reg[6]/SA}]  \
  [get_pins {sa03_reg[7]/DA}]  \
  [get_pins {sa03_reg[7]/DB}]  \
  [get_pins {sa03_reg[7]/SA}]  \
  [get_pins {sa10_reg[0]/DA}]  \
  [get_pins {sa10_reg[0]/DB}]  \
  [get_pins {sa10_reg[0]/SA}]  \
  [get_pins {sa10_reg[1]/DA}]  \
  [get_pins {sa10_reg[1]/DB}]  \
  [get_pins {sa10_reg[1]/SA}]  \
  [get_pins {sa10_reg[2]/DA}]  \
  [get_pins {sa10_reg[2]/DB}]  \
  [get_pins {sa10_reg[2]/SA}]  \
  [get_pins {sa10_reg[3]/DA}]  \
  [get_pins {sa10_reg[3]/DB}]  \
  [get_pins {sa10_reg[3]/SA}]  \
  [get_pins {sa10_reg[4]/DA}]  \
  [get_pins {sa10_reg[4]/DB}]  \
  [get_pins {sa10_reg[4]/SA}]  \
  [get_pins {sa10_reg[5]/DA}]  \
  [get_pins {sa10_reg[5]/DB}]  \
  [get_pins {sa10_reg[5]/SA}]  \
  [get_pins {sa10_reg[6]/DA}]  \
  [get_pins {sa10_reg[6]/DB}]  \
  [get_pins {sa10_reg[6]/SA}]  \
  [get_pins {sa10_reg[7]/DA}]  \
  [get_pins {sa10_reg[7]/DB}]  \
  [get_pins {sa10_reg[7]/SA}]  \
  [get_pins {sa11_reg[0]/DA}]  \
  [get_pins {sa11_reg[0]/DB}]  \
  [get_pins {sa11_reg[0]/SA}]  \
  [get_pins {sa11_reg[1]/DA}]  \
  [get_pins {sa11_reg[1]/DB}]  \
  [get_pins {sa11_reg[1]/SA}]  \
  [get_pins {sa11_reg[2]/DA}]  \
  [get_pins {sa11_reg[2]/DB}]  \
  [get_pins {sa11_reg[2]/SA}]  \
  [get_pins {sa11_reg[3]/DA}]  \
  [get_pins {sa11_reg[3]/DB}]  \
  [get_pins {sa11_reg[3]/SA}]  \
  [get_pins {sa11_reg[4]/DA}]  \
  [get_pins {sa11_reg[4]/DB}]  \
  [get_pins {sa11_reg[4]/SA}]  \
  [get_pins {sa11_reg[5]/DA}]  \
  [get_pins {sa11_reg[5]/DB}]  \
  [get_pins {sa11_reg[5]/SA}]  \
  [get_pins {sa11_reg[6]/DA}]  \
  [get_pins {sa11_reg[6]/DB}]  \
  [get_pins {sa11_reg[6]/SA}]  \
  [get_pins {sa11_reg[7]/DA}]  \
  [get_pins {sa11_reg[7]/DB}]  \
  [get_pins {sa11_reg[7]/SA}]  \
  [get_pins {sa12_reg[0]/DA}]  \
  [get_pins {sa12_reg[0]/DB}]  \
  [get_pins {sa12_reg[0]/SA}]  \
  [get_pins {sa12_reg[1]/DA}]  \
  [get_pins {sa12_reg[1]/DB}]  \
  [get_pins {sa12_reg[1]/SA}]  \
  [get_pins {sa12_reg[2]/DA}]  \
  [get_pins {sa12_reg[2]/DB}]  \
  [get_pins {sa12_reg[2]/SA}]  \
  [get_pins {sa12_reg[3]/DA}]  \
  [get_pins {sa12_reg[3]/DB}]  \
  [get_pins {sa12_reg[3]/SA}]  \
  [get_pins {sa12_reg[4]/DA}]  \
  [get_pins {sa12_reg[4]/DB}]  \
  [get_pins {sa12_reg[4]/SA}]  \
  [get_pins {sa12_reg[5]/DA}]  \
  [get_pins {sa12_reg[5]/DB}]  \
  [get_pins {sa12_reg[5]/SA}]  \
  [get_pins {sa12_reg[6]/DA}]  \
  [get_pins {sa12_reg[6]/DB}]  \
  [get_pins {sa12_reg[6]/SA}]  \
  [get_pins {sa12_reg[7]/DA}]  \
  [get_pins {sa12_reg[7]/DB}]  \
  [get_pins {sa12_reg[7]/SA}]  \
  [get_pins {sa13_reg[0]/DA}]  \
  [get_pins {sa13_reg[0]/DB}]  \
  [get_pins {sa13_reg[0]/SA}]  \
  [get_pins {sa13_reg[1]/DA}]  \
  [get_pins {sa13_reg[1]/DB}]  \
  [get_pins {sa13_reg[1]/SA}]  \
  [get_pins {sa13_reg[2]/DA}]  \
  [get_pins {sa13_reg[2]/DB}]  \
  [get_pins {sa13_reg[2]/SA}]  \
  [get_pins {sa13_reg[3]/DA}]  \
  [get_pins {sa13_reg[3]/DB}]  \
  [get_pins {sa13_reg[3]/SA}]  \
  [get_pins {sa13_reg[4]/DA}]  \
  [get_pins {sa13_reg[4]/DB}]  \
  [get_pins {sa13_reg[4]/SA}]  \
  [get_pins {sa13_reg[5]/DA}]  \
  [get_pins {sa13_reg[5]/DB}]  \
  [get_pins {sa13_reg[5]/SA}]  \
  [get_pins {sa13_reg[6]/DA}]  \
  [get_pins {sa13_reg[6]/DB}]  \
  [get_pins {sa13_reg[6]/SA}]  \
  [get_pins {sa13_reg[7]/DA}]  \
  [get_pins {sa13_reg[7]/DB}]  \
  [get_pins {sa13_reg[7]/SA}]  \
  [get_pins {sa20_reg[0]/DA}]  \
  [get_pins {sa20_reg[0]/DB}]  \
  [get_pins {sa20_reg[0]/SA}]  \
  [get_pins {sa20_reg[1]/DA}]  \
  [get_pins {sa20_reg[1]/DB}]  \
  [get_pins {sa20_reg[1]/SA}]  \
  [get_pins {sa20_reg[2]/DA}]  \
  [get_pins {sa20_reg[2]/DB}]  \
  [get_pins {sa20_reg[2]/SA}]  \
  [get_pins {sa20_reg[3]/DA}]  \
  [get_pins {sa20_reg[3]/DB}]  \
  [get_pins {sa20_reg[3]/SA}]  \
  [get_pins {sa20_reg[4]/DA}]  \
  [get_pins {sa20_reg[4]/DB}]  \
  [get_pins {sa20_reg[4]/SA}]  \
  [get_pins {sa20_reg[5]/DA}]  \
  [get_pins {sa20_reg[5]/DB}]  \
  [get_pins {sa20_reg[5]/SA}]  \
  [get_pins {sa20_reg[6]/DA}]  \
  [get_pins {sa20_reg[6]/DB}]  \
  [get_pins {sa20_reg[6]/SA}]  \
  [get_pins {sa20_reg[7]/DA}]  \
  [get_pins {sa20_reg[7]/DB}]  \
  [get_pins {sa20_reg[7]/SA}]  \
  [get_pins {sa21_reg[0]/DA}]  \
  [get_pins {sa21_reg[0]/DB}]  \
  [get_pins {sa21_reg[0]/SA}]  \
  [get_pins {sa21_reg[1]/DA}]  \
  [get_pins {sa21_reg[1]/DB}]  \
  [get_pins {sa21_reg[1]/SA}]  \
  [get_pins {sa21_reg[2]/DA}]  \
  [get_pins {sa21_reg[2]/DB}]  \
  [get_pins {sa21_reg[2]/SA}]  \
  [get_pins {sa21_reg[3]/DA}]  \
  [get_pins {sa21_reg[3]/DB}]  \
  [get_pins {sa21_reg[3]/SA}]  \
  [get_pins {sa21_reg[4]/DA}]  \
  [get_pins {sa21_reg[4]/DB}]  \
  [get_pins {sa21_reg[4]/SA}]  \
  [get_pins {sa21_reg[5]/DA}]  \
  [get_pins {sa21_reg[5]/DB}]  \
  [get_pins {sa21_reg[5]/SA}]  \
  [get_pins {sa21_reg[6]/DA}]  \
  [get_pins {sa21_reg[6]/DB}]  \
  [get_pins {sa21_reg[6]/SA}]  \
  [get_pins {sa21_reg[7]/DA}]  \
  [get_pins {sa21_reg[7]/DB}]  \
  [get_pins {sa21_reg[7]/SA}]  \
  [get_pins {sa22_reg[0]/DA}]  \
  [get_pins {sa22_reg[0]/DB}]  \
  [get_pins {sa22_reg[0]/SA}]  \
  [get_pins {sa22_reg[1]/DA}]  \
  [get_pins {sa22_reg[1]/DB}]  \
  [get_pins {sa22_reg[1]/SA}]  \
  [get_pins {sa22_reg[2]/DA}]  \
  [get_pins {sa22_reg[2]/DB}]  \
  [get_pins {sa22_reg[2]/SA}]  \
  [get_pins {sa22_reg[3]/DA}]  \
  [get_pins {sa22_reg[3]/DB}]  \
  [get_pins {sa22_reg[3]/SA}]  \
  [get_pins {sa22_reg[4]/DA}]  \
  [get_pins {sa22_reg[4]/DB}]  \
  [get_pins {sa22_reg[4]/SA}]  \
  [get_pins {sa22_reg[5]/DA}]  \
  [get_pins {sa22_reg[5]/DB}]  \
  [get_pins {sa22_reg[5]/SA}]  \
  [get_pins {sa22_reg[6]/DA}]  \
  [get_pins {sa22_reg[6]/DB}]  \
  [get_pins {sa22_reg[6]/SA}]  \
  [get_pins {sa22_reg[7]/DA}]  \
  [get_pins {sa22_reg[7]/DB}]  \
  [get_pins {sa22_reg[7]/SA}]  \
  [get_pins {sa23_reg[0]/DA}]  \
  [get_pins {sa23_reg[0]/DB}]  \
  [get_pins {sa23_reg[0]/SA}]  \
  [get_pins {sa23_reg[1]/DA}]  \
  [get_pins {sa23_reg[1]/DB}]  \
  [get_pins {sa23_reg[1]/SA}]  \
  [get_pins {sa23_reg[2]/DA}]  \
  [get_pins {sa23_reg[2]/DB}]  \
  [get_pins {sa23_reg[2]/SA}]  \
  [get_pins {sa23_reg[3]/DA}]  \
  [get_pins {sa23_reg[3]/DB}]  \
  [get_pins {sa23_reg[3]/SA}]  \
  [get_pins {sa23_reg[4]/DA}]  \
  [get_pins {sa23_reg[4]/DB}]  \
  [get_pins {sa23_reg[4]/SA}]  \
  [get_pins {sa23_reg[5]/DA}]  \
  [get_pins {sa23_reg[5]/DB}]  \
  [get_pins {sa23_reg[5]/SA}]  \
  [get_pins {sa23_reg[6]/DA}]  \
  [get_pins {sa23_reg[6]/DB}]  \
  [get_pins {sa23_reg[6]/SA}]  \
  [get_pins {sa23_reg[7]/DA}]  \
  [get_pins {sa23_reg[7]/DB}]  \
  [get_pins {sa23_reg[7]/SA}]  \
  [get_pins {sa30_reg[0]/DA}]  \
  [get_pins {sa30_reg[0]/DB}]  \
  [get_pins {sa30_reg[0]/SA}]  \
  [get_pins {sa30_reg[1]/DA}]  \
  [get_pins {sa30_reg[1]/DB}]  \
  [get_pins {sa30_reg[1]/SA}]  \
  [get_pins {sa30_reg[2]/DA}]  \
  [get_pins {sa30_reg[2]/DB}]  \
  [get_pins {sa30_reg[2]/SA}]  \
  [get_pins {sa30_reg[3]/DA}]  \
  [get_pins {sa30_reg[3]/DB}]  \
  [get_pins {sa30_reg[3]/SA}]  \
  [get_pins {sa30_reg[4]/DA}]  \
  [get_pins {sa30_reg[4]/DB}]  \
  [get_pins {sa30_reg[4]/SA}]  \
  [get_pins {sa30_reg[5]/DA}]  \
  [get_pins {sa30_reg[5]/DB}]  \
  [get_pins {sa30_reg[5]/SA}]  \
  [get_pins {sa30_reg[6]/DA}]  \
  [get_pins {sa30_reg[6]/DB}]  \
  [get_pins {sa30_reg[6]/SA}]  \
  [get_pins {sa30_reg[7]/DA}]  \
  [get_pins {sa30_reg[7]/DB}]  \
  [get_pins {sa30_reg[7]/SA}]  \
  [get_pins {sa31_reg[0]/DA}]  \
  [get_pins {sa31_reg[0]/DB}]  \
  [get_pins {sa31_reg[0]/SA}]  \
  [get_pins {sa31_reg[1]/DA}]  \
  [get_pins {sa31_reg[1]/DB}]  \
  [get_pins {sa31_reg[1]/SA}]  \
  [get_pins {sa31_reg[2]/DA}]  \
  [get_pins {sa31_reg[2]/DB}]  \
  [get_pins {sa31_reg[2]/SA}]  \
  [get_pins {sa31_reg[3]/DA}]  \
  [get_pins {sa31_reg[3]/DB}]  \
  [get_pins {sa31_reg[3]/SA}]  \
  [get_pins {sa31_reg[4]/DA}]  \
  [get_pins {sa31_reg[4]/DB}]  \
  [get_pins {sa31_reg[4]/SA}]  \
  [get_pins {sa31_reg[5]/DA}]  \
  [get_pins {sa31_reg[5]/DB}]  \
  [get_pins {sa31_reg[5]/SA}]  \
  [get_pins {sa31_reg[6]/DA}]  \
  [get_pins {sa31_reg[6]/DB}]  \
  [get_pins {sa31_reg[6]/SA}]  \
  [get_pins {sa31_reg[7]/DA}]  \
  [get_pins {sa31_reg[7]/DB}]  \
  [get_pins {sa31_reg[7]/SA}]  \
  [get_pins {sa32_reg[0]/DA}]  \
  [get_pins {sa32_reg[0]/DB}]  \
  [get_pins {sa32_reg[0]/SA}]  \
  [get_pins {sa32_reg[1]/DA}]  \
  [get_pins {sa32_reg[1]/DB}]  \
  [get_pins {sa32_reg[1]/SA}]  \
  [get_pins {sa32_reg[2]/DA}]  \
  [get_pins {sa32_reg[2]/DB}]  \
  [get_pins {sa32_reg[2]/SA}]  \
  [get_pins {sa32_reg[3]/DA}]  \
  [get_pins {sa32_reg[3]/DB}]  \
  [get_pins {sa32_reg[3]/SA}]  \
  [get_pins {sa32_reg[4]/DA}]  \
  [get_pins {sa32_reg[4]/DB}]  \
  [get_pins {sa32_reg[4]/SA}]  \
  [get_pins {sa32_reg[5]/DA}]  \
  [get_pins {sa32_reg[5]/DB}]  \
  [get_pins {sa32_reg[5]/SA}]  \
  [get_pins {sa32_reg[6]/DA}]  \
  [get_pins {sa32_reg[6]/DB}]  \
  [get_pins {sa32_reg[6]/SA}]  \
  [get_pins {sa32_reg[7]/DA}]  \
  [get_pins {sa32_reg[7]/DB}]  \
  [get_pins {sa32_reg[7]/SA}]  \
  [get_pins {sa33_reg[0]/DA}]  \
  [get_pins {sa33_reg[0]/DB}]  \
  [get_pins {sa33_reg[0]/SA}]  \
  [get_pins {sa33_reg[1]/DA}]  \
  [get_pins {sa33_reg[1]/DB}]  \
  [get_pins {sa33_reg[1]/SA}]  \
  [get_pins {sa33_reg[2]/DA}]  \
  [get_pins {sa33_reg[2]/DB}]  \
  [get_pins {sa33_reg[2]/SA}]  \
  [get_pins {sa33_reg[3]/DA}]  \
  [get_pins {sa33_reg[3]/DB}]  \
  [get_pins {sa33_reg[3]/SA}]  \
  [get_pins {sa33_reg[4]/DA}]  \
  [get_pins {sa33_reg[4]/DB}]  \
  [get_pins {sa33_reg[4]/SA}]  \
  [get_pins {sa33_reg[5]/DA}]  \
  [get_pins {sa33_reg[5]/DB}]  \
  [get_pins {sa33_reg[5]/SA}]  \
  [get_pins {sa33_reg[6]/DA}]  \
  [get_pins {sa33_reg[6]/DB}]  \
  [get_pins {sa33_reg[6]/SA}]  \
  [get_pins {sa33_reg[7]/DA}]  \
  [get_pins {sa33_reg[7]/DB}]  \
  [get_pins {sa33_reg[7]/SA}]  \
  [get_pins {text_in_r_reg[0]/D}]  \
  [get_pins {text_in_r_reg[1]/D}]  \
  [get_pins {text_in_r_reg[2]/D}]  \
  [get_pins {text_in_r_reg[3]/D}]  \
  [get_pins {text_in_r_reg[4]/D}]  \
  [get_pins {text_in_r_reg[5]/D}]  \
  [get_pins {text_in_r_reg[6]/D}]  \
  [get_pins {text_in_r_reg[7]/D}]  \
  [get_pins {text_in_r_reg[8]/D}]  \
  [get_pins {text_in_r_reg[9]/D}]  \
  [get_pins {text_in_r_reg[10]/D}]  \
  [get_pins {text_in_r_reg[11]/D}]  \
  [get_pins {text_in_r_reg[12]/D}]  \
  [get_pins {text_in_r_reg[13]/D}]  \
  [get_pins {text_in_r_reg[14]/D}]  \
  [get_pins {text_in_r_reg[15]/D}]  \
  [get_pins {text_in_r_reg[16]/D}]  \
  [get_pins {text_in_r_reg[17]/D}]  \
  [get_pins {text_in_r_reg[18]/D}]  \
  [get_pins {text_in_r_reg[19]/D}]  \
  [get_pins {text_in_r_reg[20]/D}]  \
  [get_pins {text_in_r_reg[21]/D}]  \
  [get_pins {text_in_r_reg[22]/D}]  \
  [get_pins {text_in_r_reg[23]/D}]  \
  [get_pins {text_in_r_reg[24]/D}]  \
  [get_pins {text_in_r_reg[25]/D}]  \
  [get_pins {text_in_r_reg[26]/D}]  \
  [get_pins {text_in_r_reg[27]/D}]  \
  [get_pins {text_in_r_reg[28]/D}]  \
  [get_pins {text_in_r_reg[29]/D}]  \
  [get_pins {text_in_r_reg[30]/D}]  \
  [get_pins {text_in_r_reg[31]/D}]  \
  [get_pins {text_in_r_reg[32]/D}]  \
  [get_pins {text_in_r_reg[33]/D}]  \
  [get_pins {text_in_r_reg[34]/D}]  \
  [get_pins {text_in_r_reg[35]/D}]  \
  [get_pins {text_in_r_reg[36]/D}]  \
  [get_pins {text_in_r_reg[37]/D}]  \
  [get_pins {text_in_r_reg[38]/D}]  \
  [get_pins {text_in_r_reg[39]/D}]  \
  [get_pins {text_in_r_reg[40]/D}]  \
  [get_pins {text_in_r_reg[41]/D}]  \
  [get_pins {text_in_r_reg[42]/D}]  \
  [get_pins {text_in_r_reg[43]/D}]  \
  [get_pins {text_in_r_reg[44]/D}]  \
  [get_pins {text_in_r_reg[45]/D}]  \
  [get_pins {text_in_r_reg[46]/D}]  \
  [get_pins {text_in_r_reg[47]/D}]  \
  [get_pins {text_in_r_reg[48]/D}]  \
  [get_pins {text_in_r_reg[49]/D}]  \
  [get_pins {text_in_r_reg[50]/D}]  \
  [get_pins {text_in_r_reg[51]/D}]  \
  [get_pins {text_in_r_reg[52]/D}]  \
  [get_pins {text_in_r_reg[53]/D}]  \
  [get_pins {text_in_r_reg[54]/D}]  \
  [get_pins {text_in_r_reg[55]/D}]  \
  [get_pins {text_in_r_reg[56]/D}]  \
  [get_pins {text_in_r_reg[57]/D}]  \
  [get_pins {text_in_r_reg[58]/D}]  \
  [get_pins {text_in_r_reg[59]/D}]  \
  [get_pins {text_in_r_reg[60]/D}]  \
  [get_pins {text_in_r_reg[61]/D}]  \
  [get_pins {text_in_r_reg[62]/D}]  \
  [get_pins {text_in_r_reg[63]/D}]  \
  [get_pins {text_in_r_reg[64]/D}]  \
  [get_pins {text_in_r_reg[65]/D}]  \
  [get_pins {text_in_r_reg[66]/D}]  \
  [get_pins {text_in_r_reg[67]/D}]  \
  [get_pins {text_in_r_reg[68]/D}]  \
  [get_pins {text_in_r_reg[69]/D}]  \
  [get_pins {text_in_r_reg[70]/D}]  \
  [get_pins {text_in_r_reg[71]/D}]  \
  [get_pins {text_in_r_reg[72]/D}]  \
  [get_pins {text_in_r_reg[73]/D}]  \
  [get_pins {text_in_r_reg[74]/D}]  \
  [get_pins {text_in_r_reg[75]/D}]  \
  [get_pins {text_in_r_reg[76]/D}]  \
  [get_pins {text_in_r_reg[77]/D}]  \
  [get_pins {text_in_r_reg[78]/D}]  \
  [get_pins {text_in_r_reg[79]/D}]  \
  [get_pins {text_in_r_reg[80]/D}]  \
  [get_pins {text_in_r_reg[81]/D}]  \
  [get_pins {text_in_r_reg[82]/D}]  \
  [get_pins {text_in_r_reg[83]/D}]  \
  [get_pins {text_in_r_reg[84]/D}]  \
  [get_pins {text_in_r_reg[85]/D}]  \
  [get_pins {text_in_r_reg[86]/D}]  \
  [get_pins {text_in_r_reg[87]/D}]  \
  [get_pins {text_in_r_reg[88]/D}]  \
  [get_pins {text_in_r_reg[89]/D}]  \
  [get_pins {text_in_r_reg[90]/D}]  \
  [get_pins {text_in_r_reg[91]/D}]  \
  [get_pins {text_in_r_reg[92]/D}]  \
  [get_pins {text_in_r_reg[93]/D}]  \
  [get_pins {text_in_r_reg[94]/D}]  \
  [get_pins {text_in_r_reg[95]/D}]  \
  [get_pins {text_in_r_reg[96]/D}]  \
  [get_pins {text_in_r_reg[97]/D}]  \
  [get_pins {text_in_r_reg[98]/D}]  \
  [get_pins {text_in_r_reg[99]/D}]  \
  [get_pins {text_in_r_reg[100]/D}]  \
  [get_pins {text_in_r_reg[101]/D}]  \
  [get_pins {text_in_r_reg[102]/D}]  \
  [get_pins {text_in_r_reg[103]/D}]  \
  [get_pins {text_in_r_reg[104]/D}]  \
  [get_pins {text_in_r_reg[105]/D}]  \
  [get_pins {text_in_r_reg[106]/D}]  \
  [get_pins {text_in_r_reg[107]/D}]  \
  [get_pins {text_in_r_reg[108]/D}]  \
  [get_pins {text_in_r_reg[109]/D}]  \
  [get_pins {text_in_r_reg[110]/D}]  \
  [get_pins {text_in_r_reg[111]/D}]  \
  [get_pins {text_in_r_reg[112]/D}]  \
  [get_pins {text_in_r_reg[113]/D}]  \
  [get_pins {text_in_r_reg[114]/D}]  \
  [get_pins {text_in_r_reg[115]/D}]  \
  [get_pins {text_in_r_reg[116]/D}]  \
  [get_pins {text_in_r_reg[117]/D}]  \
  [get_pins {text_in_r_reg[118]/D}]  \
  [get_pins {text_in_r_reg[119]/D}]  \
  [get_pins {text_in_r_reg[120]/D}]  \
  [get_pins {text_in_r_reg[121]/D}]  \
  [get_pins {text_in_r_reg[122]/D}]  \
  [get_pins {text_in_r_reg[123]/D}]  \
  [get_pins {text_in_r_reg[124]/D}]  \
  [get_pins {text_in_r_reg[125]/D}]  \
  [get_pins {text_in_r_reg[126]/D}]  \
  [get_pins {text_in_r_reg[127]/D}]  \
  [get_pins {text_out_reg[0]/DA}]  \
  [get_pins {text_out_reg[0]/DB}]  \
  [get_pins {text_out_reg[0]/SA}]  \
  [get_pins {text_out_reg[1]/DA}]  \
  [get_pins {text_out_reg[1]/DB}]  \
  [get_pins {text_out_reg[1]/SA}]  \
  [get_pins {text_out_reg[2]/DA}]  \
  [get_pins {text_out_reg[2]/DB}]  \
  [get_pins {text_out_reg[2]/SA}]  \
  [get_pins {text_out_reg[3]/DA}]  \
  [get_pins {text_out_reg[3]/DB}]  \
  [get_pins {text_out_reg[3]/SA}]  \
  [get_pins {text_out_reg[4]/DA}]  \
  [get_pins {text_out_reg[4]/DB}]  \
  [get_pins {text_out_reg[4]/SA}]  \
  [get_pins {text_out_reg[5]/DA}]  \
  [get_pins {text_out_reg[5]/DB}]  \
  [get_pins {text_out_reg[5]/SA}]  \
  [get_pins {text_out_reg[6]/DA}]  \
  [get_pins {text_out_reg[6]/DB}]  \
  [get_pins {text_out_reg[6]/SA}]  \
  [get_pins {text_out_reg[7]/DA}]  \
  [get_pins {text_out_reg[7]/DB}]  \
  [get_pins {text_out_reg[7]/SA}]  \
  [get_pins {text_out_reg[8]/DA}]  \
  [get_pins {text_out_reg[8]/DB}]  \
  [get_pins {text_out_reg[8]/SA}]  \
  [get_pins {text_out_reg[9]/DA}]  \
  [get_pins {text_out_reg[9]/DB}]  \
  [get_pins {text_out_reg[9]/SA}]  \
  [get_pins {text_out_reg[10]/DA}]  \
  [get_pins {text_out_reg[10]/DB}]  \
  [get_pins {text_out_reg[10]/SA}]  \
  [get_pins {text_out_reg[11]/DA}]  \
  [get_pins {text_out_reg[11]/DB}]  \
  [get_pins {text_out_reg[11]/SA}]  \
  [get_pins {text_out_reg[12]/DA}]  \
  [get_pins {text_out_reg[12]/DB}]  \
  [get_pins {text_out_reg[12]/SA}]  \
  [get_pins {text_out_reg[13]/DA}]  \
  [get_pins {text_out_reg[13]/DB}]  \
  [get_pins {text_out_reg[13]/SA}]  \
  [get_pins {text_out_reg[14]/DA}]  \
  [get_pins {text_out_reg[14]/DB}]  \
  [get_pins {text_out_reg[14]/SA}]  \
  [get_pins {text_out_reg[15]/DA}]  \
  [get_pins {text_out_reg[15]/DB}]  \
  [get_pins {text_out_reg[15]/SA}]  \
  [get_pins {text_out_reg[16]/DA}]  \
  [get_pins {text_out_reg[16]/DB}]  \
  [get_pins {text_out_reg[16]/SA}]  \
  [get_pins {text_out_reg[17]/DA}]  \
  [get_pins {text_out_reg[17]/DB}]  \
  [get_pins {text_out_reg[17]/SA}]  \
  [get_pins {text_out_reg[18]/DA}]  \
  [get_pins {text_out_reg[18]/DB}]  \
  [get_pins {text_out_reg[18]/SA}]  \
  [get_pins {text_out_reg[19]/DA}]  \
  [get_pins {text_out_reg[19]/DB}]  \
  [get_pins {text_out_reg[19]/SA}]  \
  [get_pins {text_out_reg[20]/DA}]  \
  [get_pins {text_out_reg[20]/DB}]  \
  [get_pins {text_out_reg[20]/SA}]  \
  [get_pins {text_out_reg[21]/DA}]  \
  [get_pins {text_out_reg[21]/DB}]  \
  [get_pins {text_out_reg[21]/SA}]  \
  [get_pins {text_out_reg[22]/DA}]  \
  [get_pins {text_out_reg[22]/DB}]  \
  [get_pins {text_out_reg[22]/SA}]  \
  [get_pins {text_out_reg[23]/DA}]  \
  [get_pins {text_out_reg[23]/DB}]  \
  [get_pins {text_out_reg[23]/SA}]  \
  [get_pins {text_out_reg[24]/DA}]  \
  [get_pins {text_out_reg[24]/DB}]  \
  [get_pins {text_out_reg[24]/SA}]  \
  [get_pins {text_out_reg[25]/DA}]  \
  [get_pins {text_out_reg[25]/DB}]  \
  [get_pins {text_out_reg[25]/SA}]  \
  [get_pins {text_out_reg[26]/DA}]  \
  [get_pins {text_out_reg[26]/DB}]  \
  [get_pins {text_out_reg[26]/SA}]  \
  [get_pins {text_out_reg[27]/DA}]  \
  [get_pins {text_out_reg[27]/DB}]  \
  [get_pins {text_out_reg[27]/SA}]  \
  [get_pins {text_out_reg[28]/DA}]  \
  [get_pins {text_out_reg[28]/DB}]  \
  [get_pins {text_out_reg[28]/SA}]  \
  [get_pins {text_out_reg[29]/DA}]  \
  [get_pins {text_out_reg[29]/DB}]  \
  [get_pins {text_out_reg[29]/SA}]  \
  [get_pins {text_out_reg[30]/DA}]  \
  [get_pins {text_out_reg[30]/DB}]  \
  [get_pins {text_out_reg[30]/SA}]  \
  [get_pins {text_out_reg[31]/DA}]  \
  [get_pins {text_out_reg[31]/DB}]  \
  [get_pins {text_out_reg[31]/SA}]  \
  [get_pins {text_out_reg[32]/DA}]  \
  [get_pins {text_out_reg[32]/DB}]  \
  [get_pins {text_out_reg[32]/SA}]  \
  [get_pins {text_out_reg[33]/DA}]  \
  [get_pins {text_out_reg[33]/DB}]  \
  [get_pins {text_out_reg[33]/SA}]  \
  [get_pins {text_out_reg[34]/DA}]  \
  [get_pins {text_out_reg[34]/DB}]  \
  [get_pins {text_out_reg[34]/SA}]  \
  [get_pins {text_out_reg[35]/DA}]  \
  [get_pins {text_out_reg[35]/DB}]  \
  [get_pins {text_out_reg[35]/SA}]  \
  [get_pins {text_out_reg[36]/DA}]  \
  [get_pins {text_out_reg[36]/DB}]  \
  [get_pins {text_out_reg[36]/SA}]  \
  [get_pins {text_out_reg[37]/DA}]  \
  [get_pins {text_out_reg[37]/DB}]  \
  [get_pins {text_out_reg[37]/SA}]  \
  [get_pins {text_out_reg[38]/DA}]  \
  [get_pins {text_out_reg[38]/DB}]  \
  [get_pins {text_out_reg[38]/SA}]  \
  [get_pins {text_out_reg[39]/DA}]  \
  [get_pins {text_out_reg[39]/DB}]  \
  [get_pins {text_out_reg[39]/SA}]  \
  [get_pins {text_out_reg[40]/DA}]  \
  [get_pins {text_out_reg[40]/DB}]  \
  [get_pins {text_out_reg[40]/SA}]  \
  [get_pins {text_out_reg[41]/DA}]  \
  [get_pins {text_out_reg[41]/DB}]  \
  [get_pins {text_out_reg[41]/SA}]  \
  [get_pins {text_out_reg[42]/DA}]  \
  [get_pins {text_out_reg[42]/DB}]  \
  [get_pins {text_out_reg[42]/SA}]  \
  [get_pins {text_out_reg[43]/DA}]  \
  [get_pins {text_out_reg[43]/DB}]  \
  [get_pins {text_out_reg[43]/SA}]  \
  [get_pins {text_out_reg[44]/DA}]  \
  [get_pins {text_out_reg[44]/DB}]  \
  [get_pins {text_out_reg[44]/SA}]  \
  [get_pins {text_out_reg[45]/DA}]  \
  [get_pins {text_out_reg[45]/DB}]  \
  [get_pins {text_out_reg[45]/SA}]  \
  [get_pins {text_out_reg[46]/DA}]  \
  [get_pins {text_out_reg[46]/DB}]  \
  [get_pins {text_out_reg[46]/SA}]  \
  [get_pins {text_out_reg[47]/DA}]  \
  [get_pins {text_out_reg[47]/DB}]  \
  [get_pins {text_out_reg[47]/SA}]  \
  [get_pins {text_out_reg[48]/DA}]  \
  [get_pins {text_out_reg[48]/DB}]  \
  [get_pins {text_out_reg[48]/SA}]  \
  [get_pins {text_out_reg[49]/DA}]  \
  [get_pins {text_out_reg[49]/DB}]  \
  [get_pins {text_out_reg[49]/SA}]  \
  [get_pins {text_out_reg[50]/DA}]  \
  [get_pins {text_out_reg[50]/DB}]  \
  [get_pins {text_out_reg[50]/SA}]  \
  [get_pins {text_out_reg[51]/DA}]  \
  [get_pins {text_out_reg[51]/DB}]  \
  [get_pins {text_out_reg[51]/SA}]  \
  [get_pins {text_out_reg[52]/DA}]  \
  [get_pins {text_out_reg[52]/DB}]  \
  [get_pins {text_out_reg[52]/SA}]  \
  [get_pins {text_out_reg[53]/DA}]  \
  [get_pins {text_out_reg[53]/DB}]  \
  [get_pins {text_out_reg[53]/SA}]  \
  [get_pins {text_out_reg[54]/DA}]  \
  [get_pins {text_out_reg[54]/DB}]  \
  [get_pins {text_out_reg[54]/SA}]  \
  [get_pins {text_out_reg[55]/DA}]  \
  [get_pins {text_out_reg[55]/DB}]  \
  [get_pins {text_out_reg[55]/SA}]  \
  [get_pins {text_out_reg[56]/DA}]  \
  [get_pins {text_out_reg[56]/DB}]  \
  [get_pins {text_out_reg[56]/SA}]  \
  [get_pins {text_out_reg[57]/DA}]  \
  [get_pins {text_out_reg[57]/DB}]  \
  [get_pins {text_out_reg[57]/SA}]  \
  [get_pins {text_out_reg[58]/DA}]  \
  [get_pins {text_out_reg[58]/DB}]  \
  [get_pins {text_out_reg[58]/SA}]  \
  [get_pins {text_out_reg[59]/DA}]  \
  [get_pins {text_out_reg[59]/DB}]  \
  [get_pins {text_out_reg[59]/SA}]  \
  [get_pins {text_out_reg[60]/DA}]  \
  [get_pins {text_out_reg[60]/DB}]  \
  [get_pins {text_out_reg[60]/SA}]  \
  [get_pins {text_out_reg[61]/DA}]  \
  [get_pins {text_out_reg[61]/DB}]  \
  [get_pins {text_out_reg[61]/SA}]  \
  [get_pins {text_out_reg[62]/DA}]  \
  [get_pins {text_out_reg[62]/DB}]  \
  [get_pins {text_out_reg[62]/SA}]  \
  [get_pins {text_out_reg[63]/DA}]  \
  [get_pins {text_out_reg[63]/DB}]  \
  [get_pins {text_out_reg[63]/SA}]  \
  [get_pins {text_out_reg[64]/DA}]  \
  [get_pins {text_out_reg[64]/DB}]  \
  [get_pins {text_out_reg[64]/SA}]  \
  [get_pins {text_out_reg[65]/DA}]  \
  [get_pins {text_out_reg[65]/DB}]  \
  [get_pins {text_out_reg[65]/SA}]  \
  [get_pins {text_out_reg[66]/DA}]  \
  [get_pins {text_out_reg[66]/DB}]  \
  [get_pins {text_out_reg[66]/SA}]  \
  [get_pins {text_out_reg[67]/DA}]  \
  [get_pins {text_out_reg[67]/DB}]  \
  [get_pins {text_out_reg[67]/SA}]  \
  [get_pins {text_out_reg[68]/DA}]  \
  [get_pins {text_out_reg[68]/DB}]  \
  [get_pins {text_out_reg[68]/SA}]  \
  [get_pins {text_out_reg[69]/DA}]  \
  [get_pins {text_out_reg[69]/DB}]  \
  [get_pins {text_out_reg[69]/SA}]  \
  [get_pins {text_out_reg[70]/DA}]  \
  [get_pins {text_out_reg[70]/DB}]  \
  [get_pins {text_out_reg[70]/SA}]  \
  [get_pins {text_out_reg[71]/DA}]  \
  [get_pins {text_out_reg[71]/DB}]  \
  [get_pins {text_out_reg[71]/SA}]  \
  [get_pins {text_out_reg[72]/DA}]  \
  [get_pins {text_out_reg[72]/DB}]  \
  [get_pins {text_out_reg[72]/SA}]  \
  [get_pins {text_out_reg[73]/DA}]  \
  [get_pins {text_out_reg[73]/DB}]  \
  [get_pins {text_out_reg[73]/SA}]  \
  [get_pins {text_out_reg[74]/DA}]  \
  [get_pins {text_out_reg[74]/DB}]  \
  [get_pins {text_out_reg[74]/SA}]  \
  [get_pins {text_out_reg[75]/DA}]  \
  [get_pins {text_out_reg[75]/DB}]  \
  [get_pins {text_out_reg[75]/SA}]  \
  [get_pins {text_out_reg[76]/DA}]  \
  [get_pins {text_out_reg[76]/DB}]  \
  [get_pins {text_out_reg[76]/SA}]  \
  [get_pins {text_out_reg[77]/DA}]  \
  [get_pins {text_out_reg[77]/DB}]  \
  [get_pins {text_out_reg[77]/SA}]  \
  [get_pins {text_out_reg[78]/DA}]  \
  [get_pins {text_out_reg[78]/DB}]  \
  [get_pins {text_out_reg[78]/SA}]  \
  [get_pins {text_out_reg[79]/DA}]  \
  [get_pins {text_out_reg[79]/DB}]  \
  [get_pins {text_out_reg[79]/SA}]  \
  [get_pins {text_out_reg[80]/DA}]  \
  [get_pins {text_out_reg[80]/DB}]  \
  [get_pins {text_out_reg[80]/SA}]  \
  [get_pins {text_out_reg[81]/DA}]  \
  [get_pins {text_out_reg[81]/DB}]  \
  [get_pins {text_out_reg[81]/SA}]  \
  [get_pins {text_out_reg[82]/DA}]  \
  [get_pins {text_out_reg[82]/DB}]  \
  [get_pins {text_out_reg[82]/SA}]  \
  [get_pins {text_out_reg[83]/DA}]  \
  [get_pins {text_out_reg[83]/DB}]  \
  [get_pins {text_out_reg[83]/SA}]  \
  [get_pins {text_out_reg[84]/DA}]  \
  [get_pins {text_out_reg[84]/DB}]  \
  [get_pins {text_out_reg[84]/SA}]  \
  [get_pins {text_out_reg[85]/DA}]  \
  [get_pins {text_out_reg[85]/DB}]  \
  [get_pins {text_out_reg[85]/SA}]  \
  [get_pins {text_out_reg[86]/DA}]  \
  [get_pins {text_out_reg[86]/DB}]  \
  [get_pins {text_out_reg[86]/SA}]  \
  [get_pins {text_out_reg[87]/DA}]  \
  [get_pins {text_out_reg[87]/DB}]  \
  [get_pins {text_out_reg[87]/SA}]  \
  [get_pins {text_out_reg[88]/DA}]  \
  [get_pins {text_out_reg[88]/DB}]  \
  [get_pins {text_out_reg[88]/SA}]  \
  [get_pins {text_out_reg[89]/DA}]  \
  [get_pins {text_out_reg[89]/DB}]  \
  [get_pins {text_out_reg[89]/SA}]  \
  [get_pins {text_out_reg[90]/DA}]  \
  [get_pins {text_out_reg[90]/DB}]  \
  [get_pins {text_out_reg[90]/SA}]  \
  [get_pins {text_out_reg[91]/DA}]  \
  [get_pins {text_out_reg[91]/DB}]  \
  [get_pins {text_out_reg[91]/SA}]  \
  [get_pins {text_out_reg[92]/DA}]  \
  [get_pins {text_out_reg[92]/DB}]  \
  [get_pins {text_out_reg[92]/SA}]  \
  [get_pins {text_out_reg[93]/DA}]  \
  [get_pins {text_out_reg[93]/DB}]  \
  [get_pins {text_out_reg[93]/SA}]  \
  [get_pins {text_out_reg[94]/DA}]  \
  [get_pins {text_out_reg[94]/DB}]  \
  [get_pins {text_out_reg[94]/SA}]  \
  [get_pins {text_out_reg[95]/DA}]  \
  [get_pins {text_out_reg[95]/DB}]  \
  [get_pins {text_out_reg[95]/SA}]  \
  [get_pins {text_out_reg[96]/DA}]  \
  [get_pins {text_out_reg[96]/DB}]  \
  [get_pins {text_out_reg[96]/SA}]  \
  [get_pins {text_out_reg[97]/DA}]  \
  [get_pins {text_out_reg[97]/DB}]  \
  [get_pins {text_out_reg[97]/SA}]  \
  [get_pins {text_out_reg[98]/DA}]  \
  [get_pins {text_out_reg[98]/DB}]  \
  [get_pins {text_out_reg[98]/SA}]  \
  [get_pins {text_out_reg[99]/DA}]  \
  [get_pins {text_out_reg[99]/DB}]  \
  [get_pins {text_out_reg[99]/SA}]  \
  [get_pins {text_out_reg[100]/DA}]  \
  [get_pins {text_out_reg[100]/DB}]  \
  [get_pins {text_out_reg[100]/SA}]  \
  [get_pins {text_out_reg[101]/DA}]  \
  [get_pins {text_out_reg[101]/DB}]  \
  [get_pins {text_out_reg[101]/SA}]  \
  [get_pins {text_out_reg[102]/DA}]  \
  [get_pins {text_out_reg[102]/DB}]  \
  [get_pins {text_out_reg[102]/SA}]  \
  [get_pins {text_out_reg[103]/DA}]  \
  [get_pins {text_out_reg[103]/DB}]  \
  [get_pins {text_out_reg[103]/SA}]  \
  [get_pins {text_out_reg[104]/DA}]  \
  [get_pins {text_out_reg[104]/DB}]  \
  [get_pins {text_out_reg[104]/SA}]  \
  [get_pins {text_out_reg[105]/DA}]  \
  [get_pins {text_out_reg[105]/DB}]  \
  [get_pins {text_out_reg[105]/SA}]  \
  [get_pins {text_out_reg[106]/DA}]  \
  [get_pins {text_out_reg[106]/DB}]  \
  [get_pins {text_out_reg[106]/SA}]  \
  [get_pins {text_out_reg[107]/DA}]  \
  [get_pins {text_out_reg[107]/DB}]  \
  [get_pins {text_out_reg[107]/SA}]  \
  [get_pins {text_out_reg[108]/DA}]  \
  [get_pins {text_out_reg[108]/DB}]  \
  [get_pins {text_out_reg[108]/SA}]  \
  [get_pins {text_out_reg[109]/DA}]  \
  [get_pins {text_out_reg[109]/DB}]  \
  [get_pins {text_out_reg[109]/SA}]  \
  [get_pins {text_out_reg[110]/DA}]  \
  [get_pins {text_out_reg[110]/DB}]  \
  [get_pins {text_out_reg[110]/SA}]  \
  [get_pins {text_out_reg[111]/DA}]  \
  [get_pins {text_out_reg[111]/DB}]  \
  [get_pins {text_out_reg[111]/SA}]  \
  [get_pins {text_out_reg[112]/DA}]  \
  [get_pins {text_out_reg[112]/DB}]  \
  [get_pins {text_out_reg[112]/SA}]  \
  [get_pins {text_out_reg[113]/DA}]  \
  [get_pins {text_out_reg[113]/DB}]  \
  [get_pins {text_out_reg[113]/SA}]  \
  [get_pins {text_out_reg[114]/DA}]  \
  [get_pins {text_out_reg[114]/DB}]  \
  [get_pins {text_out_reg[114]/SA}]  \
  [get_pins {text_out_reg[115]/DA}]  \
  [get_pins {text_out_reg[115]/DB}]  \
  [get_pins {text_out_reg[115]/SA}]  \
  [get_pins {text_out_reg[116]/DA}]  \
  [get_pins {text_out_reg[116]/DB}]  \
  [get_pins {text_out_reg[116]/SA}]  \
  [get_pins {text_out_reg[117]/DA}]  \
  [get_pins {text_out_reg[117]/DB}]  \
  [get_pins {text_out_reg[117]/SA}]  \
  [get_pins {text_out_reg[118]/DA}]  \
  [get_pins {text_out_reg[118]/DB}]  \
  [get_pins {text_out_reg[118]/SA}]  \
  [get_pins {text_out_reg[119]/DA}]  \
  [get_pins {text_out_reg[119]/DB}]  \
  [get_pins {text_out_reg[119]/SA}]  \
  [get_pins {text_out_reg[120]/DA}]  \
  [get_pins {text_out_reg[120]/DB}]  \
  [get_pins {text_out_reg[120]/SA}]  \
  [get_pins {text_out_reg[121]/DA}]  \
  [get_pins {text_out_reg[121]/DB}]  \
  [get_pins {text_out_reg[121]/SA}]  \
  [get_pins {text_out_reg[122]/DA}]  \
  [get_pins {text_out_reg[122]/DB}]  \
  [get_pins {text_out_reg[122]/SA}]  \
  [get_pins {text_out_reg[123]/DA}]  \
  [get_pins {text_out_reg[123]/DB}]  \
  [get_pins {text_out_reg[123]/SA}]  \
  [get_pins {text_out_reg[124]/DA}]  \
  [get_pins {text_out_reg[124]/DB}]  \
  [get_pins {text_out_reg[124]/SA}]  \
  [get_pins {text_out_reg[125]/DA}]  \
  [get_pins {text_out_reg[125]/DB}]  \
  [get_pins {text_out_reg[125]/SA}]  \
  [get_pins {text_out_reg[126]/DA}]  \
  [get_pins {text_out_reg[126]/DB}]  \
  [get_pins {text_out_reg[126]/SA}]  \
  [get_pins {text_out_reg[127]/DA}]  \
  [get_pins {text_out_reg[127]/DB}]  \
  [get_pins {text_out_reg[127]/SA}]  \
  [get_pins {dcnt_reg[2]/CN}]  \
  [get_pins {dcnt_reg[2]/D}]  \
  [get_pins {dcnt_reg[3]/DA}]  \
  [get_pins {dcnt_reg[3]/DB}]  \
  [get_pins {dcnt_reg[3]/SA}]  \
  [get_pins {dcnt_reg[1]/DA}]  \
  [get_pins {dcnt_reg[1]/DB}]  \
  [get_pins {dcnt_reg[1]/SA}]  \
  [get_pins {dcnt_reg[0]/DA}]  \
  [get_pins {dcnt_reg[0]/DB}]  \
  [get_pins {dcnt_reg[0]/SA}] ]
group_path -weight 1.000000 -name reg2reg -from [list \
  [get_pins RC_CG_HIER_INST0/RC_CGIC_INST/CP]  \
  [get_pins RC_CG_HIER_INST1/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST2/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST3/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST4/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST5/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST6/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST7/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST8/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST9/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST10/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST11/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST12/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST13/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST14/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST15/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST16/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST17/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST18/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST19/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST20/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST21/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST22/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST23/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST24/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST25/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST26/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST27/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST28/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST29/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST30/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST31/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST32/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST33/RC_CGIC_INST/CP]  \
  [get_pins u0/r0_RC_CG_HIER_INST34/RC_CGIC_INST/CP]  \
  [get_pins {u0/r0_out_reg[24]/CP}]  \
  [get_pins {u0/r0_out_reg[25]/CP}]  \
  [get_pins {u0/r0_out_reg[26]/CP}]  \
  [get_pins {u0/r0_out_reg[27]/CP}]  \
  [get_pins {u0/r0_out_reg[28]/CP}]  \
  [get_pins {u0/r0_out_reg[29]/CP}]  \
  [get_pins {u0/r0_out_reg[30]/CP}]  \
  [get_pins {u0/r0_out_reg[31]/CP}]  \
  [get_pins {u0/r0_rcnt_reg[0]/CP}]  \
  [get_pins {u0/r0_rcnt_reg[1]/CP}]  \
  [get_pins {u0/r0_rcnt_reg[2]/CP}]  \
  [get_pins {u0/r0_rcnt_reg[3]/CP}]  \
  [get_pins {u0/w_reg[0][0]/CP}]  \
  [get_pins {u0/w_reg[0][1]/CP}]  \
  [get_pins {u0/w_reg[0][2]/CP}]  \
  [get_pins {u0/w_reg[0][3]/CP}]  \
  [get_pins {u0/w_reg[0][4]/CP}]  \
  [get_pins {u0/w_reg[0][5]/CP}]  \
  [get_pins {u0/w_reg[0][6]/CP}]  \
  [get_pins {u0/w_reg[0][7]/CP}]  \
  [get_pins {u0/w_reg[0][8]/CP}]  \
  [get_pins {u0/w_reg[0][9]/CP}]  \
  [get_pins {u0/w_reg[0][10]/CP}]  \
  [get_pins {u0/w_reg[0][11]/CP}]  \
  [get_pins {u0/w_reg[0][12]/CP}]  \
  [get_pins {u0/w_reg[0][13]/CP}]  \
  [get_pins {u0/w_reg[0][14]/CP}]  \
  [get_pins {u0/w_reg[0][15]/CP}]  \
  [get_pins {u0/w_reg[0][16]/CP}]  \
  [get_pins {u0/w_reg[0][17]/CP}]  \
  [get_pins {u0/w_reg[0][18]/CP}]  \
  [get_pins {u0/w_reg[0][19]/CP}]  \
  [get_pins {u0/w_reg[0][20]/CP}]  \
  [get_pins {u0/w_reg[0][21]/CP}]  \
  [get_pins {u0/w_reg[0][22]/CP}]  \
  [get_pins {u0/w_reg[0][23]/CP}]  \
  [get_pins {u0/w_reg[0][24]/CP}]  \
  [get_pins {u0/w_reg[0][25]/CP}]  \
  [get_pins {u0/w_reg[0][26]/CP}]  \
  [get_pins {u0/w_reg[0][27]/CP}]  \
  [get_pins {u0/w_reg[0][28]/CP}]  \
  [get_pins {u0/w_reg[0][29]/CP}]  \
  [get_pins {u0/w_reg[0][30]/CP}]  \
  [get_pins {u0/w_reg[0][31]/CP}]  \
  [get_pins {u0/w_reg[1][0]/CP}]  \
  [get_pins {u0/w_reg[1][1]/CP}]  \
  [get_pins {u0/w_reg[1][2]/CP}]  \
  [get_pins {u0/w_reg[1][3]/CP}]  \
  [get_pins {u0/w_reg[1][4]/CP}]  \
  [get_pins {u0/w_reg[1][5]/CP}]  \
  [get_pins {u0/w_reg[1][6]/CP}]  \
  [get_pins {u0/w_reg[1][7]/CP}]  \
  [get_pins {u0/w_reg[1][8]/CP}]  \
  [get_pins {u0/w_reg[1][9]/CP}]  \
  [get_pins {u0/w_reg[1][10]/CP}]  \
  [get_pins {u0/w_reg[1][11]/CP}]  \
  [get_pins {u0/w_reg[1][12]/CP}]  \
  [get_pins {u0/w_reg[1][13]/CP}]  \
  [get_pins {u0/w_reg[1][14]/CP}]  \
  [get_pins {u0/w_reg[1][15]/CP}]  \
  [get_pins {u0/w_reg[1][16]/CP}]  \
  [get_pins {u0/w_reg[1][17]/CP}]  \
  [get_pins {u0/w_reg[1][18]/CP}]  \
  [get_pins {u0/w_reg[1][19]/CP}]  \
  [get_pins {u0/w_reg[1][20]/CP}]  \
  [get_pins {u0/w_reg[1][21]/CP}]  \
  [get_pins {u0/w_reg[1][22]/CP}]  \
  [get_pins {u0/w_reg[1][23]/CP}]  \
  [get_pins {u0/w_reg[1][24]/CP}]  \
  [get_pins {u0/w_reg[1][25]/CP}]  \
  [get_pins {u0/w_reg[1][26]/CP}]  \
  [get_pins {u0/w_reg[1][27]/CP}]  \
  [get_pins {u0/w_reg[1][28]/CP}]  \
  [get_pins {u0/w_reg[1][29]/CP}]  \
  [get_pins {u0/w_reg[1][30]/CP}]  \
  [get_pins {u0/w_reg[1][31]/CP}]  \
  [get_pins {u0/w_reg[2][0]/CP}]  \
  [get_pins {u0/w_reg[2][1]/CP}]  \
  [get_pins {u0/w_reg[2][2]/CP}]  \
  [get_pins {u0/w_reg[2][3]/CP}]  \
  [get_pins {u0/w_reg[2][4]/CP}]  \
  [get_pins {u0/w_reg[2][5]/CP}]  \
  [get_pins {u0/w_reg[2][6]/CP}]  \
  [get_pins {u0/w_reg[2][7]/CP}]  \
  [get_pins {u0/w_reg[2][8]/CP}]  \
  [get_pins {u0/w_reg[2][9]/CP}]  \
  [get_pins {u0/w_reg[2][10]/CP}]  \
  [get_pins {u0/w_reg[2][11]/CP}]  \
  [get_pins {u0/w_reg[2][12]/CP}]  \
  [get_pins {u0/w_reg[2][13]/CP}]  \
  [get_pins {u0/w_reg[2][14]/CP}]  \
  [get_pins {u0/w_reg[2][15]/CP}]  \
  [get_pins {u0/w_reg[2][16]/CP}]  \
  [get_pins {u0/w_reg[2][17]/CP}]  \
  [get_pins {u0/w_reg[2][18]/CP}]  \
  [get_pins {u0/w_reg[2][19]/CP}]  \
  [get_pins {u0/w_reg[2][20]/CP}]  \
  [get_pins {u0/w_reg[2][21]/CP}]  \
  [get_pins {u0/w_reg[2][22]/CP}]  \
  [get_pins {u0/w_reg[2][23]/CP}]  \
  [get_pins {u0/w_reg[2][24]/CP}]  \
  [get_pins {u0/w_reg[2][25]/CP}]  \
  [get_pins {u0/w_reg[2][26]/CP}]  \
  [get_pins {u0/w_reg[2][27]/CP}]  \
  [get_pins {u0/w_reg[2][28]/CP}]  \
  [get_pins {u0/w_reg[2][29]/CP}]  \
  [get_pins {u0/w_reg[2][30]/CP}]  \
  [get_pins {u0/w_reg[2][31]/CP}]  \
  [get_pins {u0/w_reg[3][0]/CP}]  \
  [get_pins {u0/w_reg[3][1]/CP}]  \
  [get_pins {u0/w_reg[3][2]/CP}]  \
  [get_pins {u0/w_reg[3][3]/CP}]  \
  [get_pins {u0/w_reg[3][4]/CP}]  \
  [get_pins {u0/w_reg[3][5]/CP}]  \
  [get_pins {u0/w_reg[3][6]/CP}]  \
  [get_pins {u0/w_reg[3][7]/CP}]  \
  [get_pins {u0/w_reg[3][8]/CP}]  \
  [get_pins {u0/w_reg[3][9]/CP}]  \
  [get_pins {u0/w_reg[3][10]/CP}]  \
  [get_pins {u0/w_reg[3][11]/CP}]  \
  [get_pins {u0/w_reg[3][12]/CP}]  \
  [get_pins {u0/w_reg[3][13]/CP}]  \
  [get_pins {u0/w_reg[3][14]/CP}]  \
  [get_pins {u0/w_reg[3][15]/CP}]  \
  [get_pins {u0/w_reg[3][16]/CP}]  \
  [get_pins {u0/w_reg[3][17]/CP}]  \
  [get_pins {u0/w_reg[3][18]/CP}]  \
  [get_pins {u0/w_reg[3][19]/CP}]  \
  [get_pins {u0/w_reg[3][20]/CP}]  \
  [get_pins {u0/w_reg[3][21]/CP}]  \
  [get_pins {u0/w_reg[3][22]/CP}]  \
  [get_pins {u0/w_reg[3][23]/CP}]  \
  [get_pins {u0/w_reg[3][24]/CP}]  \
  [get_pins {u0/w_reg[3][25]/CP}]  \
  [get_pins {u0/w_reg[3][26]/CP}]  \
  [get_pins {u0/w_reg[3][27]/CP}]  \
  [get_pins {u0/w_reg[3][28]/CP}]  \
  [get_pins {u0/w_reg[3][29]/CP}]  \
  [get_pins {u0/w_reg[3][30]/CP}]  \
  [get_pins {u0/w_reg[3][31]/CP}]  \
  [get_pins done_reg/CP]  \
  [get_pins ld_r_reg/CP]  \
  [get_pins {sa00_reg[0]/CP}]  \
  [get_pins {sa00_reg[1]/CP}]  \
  [get_pins {sa00_reg[2]/CP}]  \
  [get_pins {sa00_reg[3]/CP}]  \
  [get_pins {sa00_reg[4]/CP}]  \
  [get_pins {sa00_reg[5]/CP}]  \
  [get_pins {sa00_reg[6]/CP}]  \
  [get_pins {sa00_reg[7]/CP}]  \
  [get_pins {sa01_reg[0]/CP}]  \
  [get_pins {sa01_reg[1]/CP}]  \
  [get_pins {sa01_reg[2]/CP}]  \
  [get_pins {sa01_reg[3]/CP}]  \
  [get_pins {sa01_reg[4]/CP}]  \
  [get_pins {sa01_reg[5]/CP}]  \
  [get_pins {sa01_reg[6]/CP}]  \
  [get_pins {sa01_reg[7]/CP}]  \
  [get_pins {sa02_reg[0]/CP}]  \
  [get_pins {sa02_reg[1]/CP}]  \
  [get_pins {sa02_reg[2]/CP}]  \
  [get_pins {sa02_reg[3]/CP}]  \
  [get_pins {sa02_reg[4]/CP}]  \
  [get_pins {sa02_reg[5]/CP}]  \
  [get_pins {sa02_reg[6]/CP}]  \
  [get_pins {sa02_reg[7]/CP}]  \
  [get_pins {sa03_reg[0]/CP}]  \
  [get_pins {sa03_reg[1]/CP}]  \
  [get_pins {sa03_reg[2]/CP}]  \
  [get_pins {sa03_reg[3]/CP}]  \
  [get_pins {sa03_reg[4]/CP}]  \
  [get_pins {sa03_reg[5]/CP}]  \
  [get_pins {sa03_reg[6]/CP}]  \
  [get_pins {sa03_reg[7]/CP}]  \
  [get_pins {sa10_reg[0]/CP}]  \
  [get_pins {sa10_reg[1]/CP}]  \
  [get_pins {sa10_reg[2]/CP}]  \
  [get_pins {sa10_reg[3]/CP}]  \
  [get_pins {sa10_reg[4]/CP}]  \
  [get_pins {sa10_reg[5]/CP}]  \
  [get_pins {sa10_reg[6]/CP}]  \
  [get_pins {sa10_reg[7]/CP}]  \
  [get_pins {sa11_reg[0]/CP}]  \
  [get_pins {sa11_reg[1]/CP}]  \
  [get_pins {sa11_reg[2]/CP}]  \
  [get_pins {sa11_reg[3]/CP}]  \
  [get_pins {sa11_reg[4]/CP}]  \
  [get_pins {sa11_reg[5]/CP}]  \
  [get_pins {sa11_reg[6]/CP}]  \
  [get_pins {sa11_reg[7]/CP}]  \
  [get_pins {sa12_reg[0]/CP}]  \
  [get_pins {sa12_reg[1]/CP}]  \
  [get_pins {sa12_reg[2]/CP}]  \
  [get_pins {sa12_reg[3]/CP}]  \
  [get_pins {sa12_reg[4]/CP}]  \
  [get_pins {sa12_reg[5]/CP}]  \
  [get_pins {sa12_reg[6]/CP}]  \
  [get_pins {sa12_reg[7]/CP}]  \
  [get_pins {sa13_reg[0]/CP}]  \
  [get_pins {sa13_reg[1]/CP}]  \
  [get_pins {sa13_reg[2]/CP}]  \
  [get_pins {sa13_reg[3]/CP}]  \
  [get_pins {sa13_reg[4]/CP}]  \
  [get_pins {sa13_reg[5]/CP}]  \
  [get_pins {sa13_reg[6]/CP}]  \
  [get_pins {sa13_reg[7]/CP}]  \
  [get_pins {sa20_reg[0]/CP}]  \
  [get_pins {sa20_reg[1]/CP}]  \
  [get_pins {sa20_reg[2]/CP}]  \
  [get_pins {sa20_reg[3]/CP}]  \
  [get_pins {sa20_reg[4]/CP}]  \
  [get_pins {sa20_reg[5]/CP}]  \
  [get_pins {sa20_reg[6]/CP}]  \
  [get_pins {sa20_reg[7]/CP}]  \
  [get_pins {sa21_reg[0]/CP}]  \
  [get_pins {sa21_reg[1]/CP}]  \
  [get_pins {sa21_reg[2]/CP}]  \
  [get_pins {sa21_reg[3]/CP}]  \
  [get_pins {sa21_reg[4]/CP}]  \
  [get_pins {sa21_reg[5]/CP}]  \
  [get_pins {sa21_reg[6]/CP}]  \
  [get_pins {sa21_reg[7]/CP}]  \
  [get_pins {sa22_reg[0]/CP}]  \
  [get_pins {sa22_reg[1]/CP}]  \
  [get_pins {sa22_reg[2]/CP}]  \
  [get_pins {sa22_reg[3]/CP}]  \
  [get_pins {sa22_reg[4]/CP}]  \
  [get_pins {sa22_reg[5]/CP}]  \
  [get_pins {sa22_reg[6]/CP}]  \
  [get_pins {sa22_reg[7]/CP}]  \
  [get_pins {sa23_reg[0]/CP}]  \
  [get_pins {sa23_reg[1]/CP}]  \
  [get_pins {sa23_reg[2]/CP}]  \
  [get_pins {sa23_reg[3]/CP}]  \
  [get_pins {sa23_reg[4]/CP}]  \
  [get_pins {sa23_reg[5]/CP}]  \
  [get_pins {sa23_reg[6]/CP}]  \
  [get_pins {sa23_reg[7]/CP}]  \
  [get_pins {sa30_reg[0]/CP}]  \
  [get_pins {sa30_reg[1]/CP}]  \
  [get_pins {sa30_reg[2]/CP}]  \
  [get_pins {sa30_reg[3]/CP}]  \
  [get_pins {sa30_reg[4]/CP}]  \
  [get_pins {sa30_reg[5]/CP}]  \
  [get_pins {sa30_reg[6]/CP}]  \
  [get_pins {sa30_reg[7]/CP}]  \
  [get_pins {sa31_reg[0]/CP}]  \
  [get_pins {sa31_reg[1]/CP}]  \
  [get_pins {sa31_reg[2]/CP}]  \
  [get_pins {sa31_reg[3]/CP}]  \
  [get_pins {sa31_reg[4]/CP}]  \
  [get_pins {sa31_reg[5]/CP}]  \
  [get_pins {sa31_reg[6]/CP}]  \
  [get_pins {sa31_reg[7]/CP}]  \
  [get_pins {sa32_reg[0]/CP}]  \
  [get_pins {sa32_reg[1]/CP}]  \
  [get_pins {sa32_reg[2]/CP}]  \
  [get_pins {sa32_reg[3]/CP}]  \
  [get_pins {sa32_reg[4]/CP}]  \
  [get_pins {sa32_reg[5]/CP}]  \
  [get_pins {sa32_reg[6]/CP}]  \
  [get_pins {sa32_reg[7]/CP}]  \
  [get_pins {sa33_reg[0]/CP}]  \
  [get_pins {sa33_reg[1]/CP}]  \
  [get_pins {sa33_reg[2]/CP}]  \
  [get_pins {sa33_reg[3]/CP}]  \
  [get_pins {sa33_reg[4]/CP}]  \
  [get_pins {sa33_reg[5]/CP}]  \
  [get_pins {sa33_reg[6]/CP}]  \
  [get_pins {sa33_reg[7]/CP}]  \
  [get_pins {text_in_r_reg[0]/CP}]  \
  [get_pins {text_in_r_reg[1]/CP}]  \
  [get_pins {text_in_r_reg[2]/CP}]  \
  [get_pins {text_in_r_reg[3]/CP}]  \
  [get_pins {text_in_r_reg[4]/CP}]  \
  [get_pins {text_in_r_reg[5]/CP}]  \
  [get_pins {text_in_r_reg[6]/CP}]  \
  [get_pins {text_in_r_reg[7]/CP}]  \
  [get_pins {text_in_r_reg[8]/CP}]  \
  [get_pins {text_in_r_reg[9]/CP}]  \
  [get_pins {text_in_r_reg[10]/CP}]  \
  [get_pins {text_in_r_reg[11]/CP}]  \
  [get_pins {text_in_r_reg[12]/CP}]  \
  [get_pins {text_in_r_reg[13]/CP}]  \
  [get_pins {text_in_r_reg[14]/CP}]  \
  [get_pins {text_in_r_reg[15]/CP}]  \
  [get_pins {text_in_r_reg[16]/CP}]  \
  [get_pins {text_in_r_reg[17]/CP}]  \
  [get_pins {text_in_r_reg[18]/CP}]  \
  [get_pins {text_in_r_reg[19]/CP}]  \
  [get_pins {text_in_r_reg[20]/CP}]  \
  [get_pins {text_in_r_reg[21]/CP}]  \
  [get_pins {text_in_r_reg[22]/CP}]  \
  [get_pins {text_in_r_reg[23]/CP}]  \
  [get_pins {text_in_r_reg[24]/CP}]  \
  [get_pins {text_in_r_reg[25]/CP}]  \
  [get_pins {text_in_r_reg[26]/CP}]  \
  [get_pins {text_in_r_reg[27]/CP}]  \
  [get_pins {text_in_r_reg[28]/CP}]  \
  [get_pins {text_in_r_reg[29]/CP}]  \
  [get_pins {text_in_r_reg[30]/CP}]  \
  [get_pins {text_in_r_reg[31]/CP}]  \
  [get_pins {text_in_r_reg[32]/CP}]  \
  [get_pins {text_in_r_reg[33]/CP}]  \
  [get_pins {text_in_r_reg[34]/CP}]  \
  [get_pins {text_in_r_reg[35]/CP}]  \
  [get_pins {text_in_r_reg[36]/CP}]  \
  [get_pins {text_in_r_reg[37]/CP}]  \
  [get_pins {text_in_r_reg[38]/CP}]  \
  [get_pins {text_in_r_reg[39]/CP}]  \
  [get_pins {text_in_r_reg[40]/CP}]  \
  [get_pins {text_in_r_reg[41]/CP}]  \
  [get_pins {text_in_r_reg[42]/CP}]  \
  [get_pins {text_in_r_reg[43]/CP}]  \
  [get_pins {text_in_r_reg[44]/CP}]  \
  [get_pins {text_in_r_reg[45]/CP}]  \
  [get_pins {text_in_r_reg[46]/CP}]  \
  [get_pins {text_in_r_reg[47]/CP}]  \
  [get_pins {text_in_r_reg[48]/CP}]  \
  [get_pins {text_in_r_reg[49]/CP}]  \
  [get_pins {text_in_r_reg[50]/CP}]  \
  [get_pins {text_in_r_reg[51]/CP}]  \
  [get_pins {text_in_r_reg[52]/CP}]  \
  [get_pins {text_in_r_reg[53]/CP}]  \
  [get_pins {text_in_r_reg[54]/CP}]  \
  [get_pins {text_in_r_reg[55]/CP}]  \
  [get_pins {text_in_r_reg[56]/CP}]  \
  [get_pins {text_in_r_reg[57]/CP}]  \
  [get_pins {text_in_r_reg[58]/CP}]  \
  [get_pins {text_in_r_reg[59]/CP}]  \
  [get_pins {text_in_r_reg[60]/CP}]  \
  [get_pins {text_in_r_reg[61]/CP}]  \
  [get_pins {text_in_r_reg[62]/CP}]  \
  [get_pins {text_in_r_reg[63]/CP}]  \
  [get_pins {text_in_r_reg[64]/CP}]  \
  [get_pins {text_in_r_reg[65]/CP}]  \
  [get_pins {text_in_r_reg[66]/CP}]  \
  [get_pins {text_in_r_reg[67]/CP}]  \
  [get_pins {text_in_r_reg[68]/CP}]  \
  [get_pins {text_in_r_reg[69]/CP}]  \
  [get_pins {text_in_r_reg[70]/CP}]  \
  [get_pins {text_in_r_reg[71]/CP}]  \
  [get_pins {text_in_r_reg[72]/CP}]  \
  [get_pins {text_in_r_reg[73]/CP}]  \
  [get_pins {text_in_r_reg[74]/CP}]  \
  [get_pins {text_in_r_reg[75]/CP}]  \
  [get_pins {text_in_r_reg[76]/CP}]  \
  [get_pins {text_in_r_reg[77]/CP}]  \
  [get_pins {text_in_r_reg[78]/CP}]  \
  [get_pins {text_in_r_reg[79]/CP}]  \
  [get_pins {text_in_r_reg[80]/CP}]  \
  [get_pins {text_in_r_reg[81]/CP}]  \
  [get_pins {text_in_r_reg[82]/CP}]  \
  [get_pins {text_in_r_reg[83]/CP}]  \
  [get_pins {text_in_r_reg[84]/CP}]  \
  [get_pins {text_in_r_reg[85]/CP}]  \
  [get_pins {text_in_r_reg[86]/CP}]  \
  [get_pins {text_in_r_reg[87]/CP}]  \
  [get_pins {text_in_r_reg[88]/CP}]  \
  [get_pins {text_in_r_reg[89]/CP}]  \
  [get_pins {text_in_r_reg[90]/CP}]  \
  [get_pins {text_in_r_reg[91]/CP}]  \
  [get_pins {text_in_r_reg[92]/CP}]  \
  [get_pins {text_in_r_reg[93]/CP}]  \
  [get_pins {text_in_r_reg[94]/CP}]  \
  [get_pins {text_in_r_reg[95]/CP}]  \
  [get_pins {text_in_r_reg[96]/CP}]  \
  [get_pins {text_in_r_reg[97]/CP}]  \
  [get_pins {text_in_r_reg[98]/CP}]  \
  [get_pins {text_in_r_reg[99]/CP}]  \
  [get_pins {text_in_r_reg[100]/CP}]  \
  [get_pins {text_in_r_reg[101]/CP}]  \
  [get_pins {text_in_r_reg[102]/CP}]  \
  [get_pins {text_in_r_reg[103]/CP}]  \
  [get_pins {text_in_r_reg[104]/CP}]  \
  [get_pins {text_in_r_reg[105]/CP}]  \
  [get_pins {text_in_r_reg[106]/CP}]  \
  [get_pins {text_in_r_reg[107]/CP}]  \
  [get_pins {text_in_r_reg[108]/CP}]  \
  [get_pins {text_in_r_reg[109]/CP}]  \
  [get_pins {text_in_r_reg[110]/CP}]  \
  [get_pins {text_in_r_reg[111]/CP}]  \
  [get_pins {text_in_r_reg[112]/CP}]  \
  [get_pins {text_in_r_reg[113]/CP}]  \
  [get_pins {text_in_r_reg[114]/CP}]  \
  [get_pins {text_in_r_reg[115]/CP}]  \
  [get_pins {text_in_r_reg[116]/CP}]  \
  [get_pins {text_in_r_reg[117]/CP}]  \
  [get_pins {text_in_r_reg[118]/CP}]  \
  [get_pins {text_in_r_reg[119]/CP}]  \
  [get_pins {text_in_r_reg[120]/CP}]  \
  [get_pins {text_in_r_reg[121]/CP}]  \
  [get_pins {text_in_r_reg[122]/CP}]  \
  [get_pins {text_in_r_reg[123]/CP}]  \
  [get_pins {text_in_r_reg[124]/CP}]  \
  [get_pins {text_in_r_reg[125]/CP}]  \
  [get_pins {text_in_r_reg[126]/CP}]  \
  [get_pins {text_in_r_reg[127]/CP}]  \
  [get_pins {text_out_reg[0]/CP}]  \
  [get_pins {text_out_reg[1]/CP}]  \
  [get_pins {text_out_reg[2]/CP}]  \
  [get_pins {text_out_reg[3]/CP}]  \
  [get_pins {text_out_reg[4]/CP}]  \
  [get_pins {text_out_reg[5]/CP}]  \
  [get_pins {text_out_reg[6]/CP}]  \
  [get_pins {text_out_reg[7]/CP}]  \
  [get_pins {text_out_reg[8]/CP}]  \
  [get_pins {text_out_reg[9]/CP}]  \
  [get_pins {text_out_reg[10]/CP}]  \
  [get_pins {text_out_reg[11]/CP}]  \
  [get_pins {text_out_reg[12]/CP}]  \
  [get_pins {text_out_reg[13]/CP}]  \
  [get_pins {text_out_reg[14]/CP}]  \
  [get_pins {text_out_reg[15]/CP}]  \
  [get_pins {text_out_reg[16]/CP}]  \
  [get_pins {text_out_reg[17]/CP}]  \
  [get_pins {text_out_reg[18]/CP}]  \
  [get_pins {text_out_reg[19]/CP}]  \
  [get_pins {text_out_reg[20]/CP}]  \
  [get_pins {text_out_reg[21]/CP}]  \
  [get_pins {text_out_reg[22]/CP}]  \
  [get_pins {text_out_reg[23]/CP}]  \
  [get_pins {text_out_reg[24]/CP}]  \
  [get_pins {text_out_reg[25]/CP}]  \
  [get_pins {text_out_reg[26]/CP}]  \
  [get_pins {text_out_reg[27]/CP}]  \
  [get_pins {text_out_reg[28]/CP}]  \
  [get_pins {text_out_reg[29]/CP}]  \
  [get_pins {text_out_reg[30]/CP}]  \
  [get_pins {text_out_reg[31]/CP}]  \
  [get_pins {text_out_reg[32]/CP}]  \
  [get_pins {text_out_reg[33]/CP}]  \
  [get_pins {text_out_reg[34]/CP}]  \
  [get_pins {text_out_reg[35]/CP}]  \
  [get_pins {text_out_reg[36]/CP}]  \
  [get_pins {text_out_reg[37]/CP}]  \
  [get_pins {text_out_reg[38]/CP}]  \
  [get_pins {text_out_reg[39]/CP}]  \
  [get_pins {text_out_reg[40]/CP}]  \
  [get_pins {text_out_reg[41]/CP}]  \
  [get_pins {text_out_reg[42]/CP}]  \
  [get_pins {text_out_reg[43]/CP}]  \
  [get_pins {text_out_reg[44]/CP}]  \
  [get_pins {text_out_reg[45]/CP}]  \
  [get_pins {text_out_reg[46]/CP}]  \
  [get_pins {text_out_reg[47]/CP}]  \
  [get_pins {text_out_reg[48]/CP}]  \
  [get_pins {text_out_reg[49]/CP}]  \
  [get_pins {text_out_reg[50]/CP}]  \
  [get_pins {text_out_reg[51]/CP}]  \
  [get_pins {text_out_reg[52]/CP}]  \
  [get_pins {text_out_reg[53]/CP}]  \
  [get_pins {text_out_reg[54]/CP}]  \
  [get_pins {text_out_reg[55]/CP}]  \
  [get_pins {text_out_reg[56]/CP}]  \
  [get_pins {text_out_reg[57]/CP}]  \
  [get_pins {text_out_reg[58]/CP}]  \
  [get_pins {text_out_reg[59]/CP}]  \
  [get_pins {text_out_reg[60]/CP}]  \
  [get_pins {text_out_reg[61]/CP}]  \
  [get_pins {text_out_reg[62]/CP}]  \
  [get_pins {text_out_reg[63]/CP}]  \
  [get_pins {text_out_reg[64]/CP}]  \
  [get_pins {text_out_reg[65]/CP}]  \
  [get_pins {text_out_reg[66]/CP}]  \
  [get_pins {text_out_reg[67]/CP}]  \
  [get_pins {text_out_reg[68]/CP}]  \
  [get_pins {text_out_reg[69]/CP}]  \
  [get_pins {text_out_reg[70]/CP}]  \
  [get_pins {text_out_reg[71]/CP}]  \
  [get_pins {text_out_reg[72]/CP}]  \
  [get_pins {text_out_reg[73]/CP}]  \
  [get_pins {text_out_reg[74]/CP}]  \
  [get_pins {text_out_reg[75]/CP}]  \
  [get_pins {text_out_reg[76]/CP}]  \
  [get_pins {text_out_reg[77]/CP}]  \
  [get_pins {text_out_reg[78]/CP}]  \
  [get_pins {text_out_reg[79]/CP}]  \
  [get_pins {text_out_reg[80]/CP}]  \
  [get_pins {text_out_reg[81]/CP}]  \
  [get_pins {text_out_reg[82]/CP}]  \
  [get_pins {text_out_reg[83]/CP}]  \
  [get_pins {text_out_reg[84]/CP}]  \
  [get_pins {text_out_reg[85]/CP}]  \
  [get_pins {text_out_reg[86]/CP}]  \
  [get_pins {text_out_reg[87]/CP}]  \
  [get_pins {text_out_reg[88]/CP}]  \
  [get_pins {text_out_reg[89]/CP}]  \
  [get_pins {text_out_reg[90]/CP}]  \
  [get_pins {text_out_reg[91]/CP}]  \
  [get_pins {text_out_reg[92]/CP}]  \
  [get_pins {text_out_reg[93]/CP}]  \
  [get_pins {text_out_reg[94]/CP}]  \
  [get_pins {text_out_reg[95]/CP}]  \
  [get_pins {text_out_reg[96]/CP}]  \
  [get_pins {text_out_reg[97]/CP}]  \
  [get_pins {text_out_reg[98]/CP}]  \
  [get_pins {text_out_reg[99]/CP}]  \
  [get_pins {text_out_reg[100]/CP}]  \
  [get_pins {text_out_reg[101]/CP}]  \
  [get_pins {text_out_reg[102]/CP}]  \
  [get_pins {text_out_reg[103]/CP}]  \
  [get_pins {text_out_reg[104]/CP}]  \
  [get_pins {text_out_reg[105]/CP}]  \
  [get_pins {text_out_reg[106]/CP}]  \
  [get_pins {text_out_reg[107]/CP}]  \
  [get_pins {text_out_reg[108]/CP}]  \
  [get_pins {text_out_reg[109]/CP}]  \
  [get_pins {text_out_reg[110]/CP}]  \
  [get_pins {text_out_reg[111]/CP}]  \
  [get_pins {text_out_reg[112]/CP}]  \
  [get_pins {text_out_reg[113]/CP}]  \
  [get_pins {text_out_reg[114]/CP}]  \
  [get_pins {text_out_reg[115]/CP}]  \
  [get_pins {text_out_reg[116]/CP}]  \
  [get_pins {text_out_reg[117]/CP}]  \
  [get_pins {text_out_reg[118]/CP}]  \
  [get_pins {text_out_reg[119]/CP}]  \
  [get_pins {text_out_reg[120]/CP}]  \
  [get_pins {text_out_reg[121]/CP}]  \
  [get_pins {text_out_reg[122]/CP}]  \
  [get_pins {text_out_reg[123]/CP}]  \
  [get_pins {text_out_reg[124]/CP}]  \
  [get_pins {text_out_reg[125]/CP}]  \
  [get_pins {text_out_reg[126]/CP}]  \
  [get_pins {text_out_reg[127]/CP}]  \
  [get_pins {dcnt_reg[2]/CP}]  \
  [get_pins {dcnt_reg[3]/CP}]  \
  [get_pins {dcnt_reg[1]/CP}]  \
  [get_pins {dcnt_reg[0]/CP}] ] -to [list \
  [get_pins RC_CG_HIER_INST0/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST0/RC_CGIC_INST/TE]  \
  [get_pins RC_CG_HIER_INST1/RC_CGIC_INST/E]  \
  [get_pins RC_CG_HIER_INST1/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST2/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST2/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST3/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST3/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST4/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST4/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST5/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST5/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST6/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST6/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST7/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST7/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST8/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST8/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST9/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST9/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST10/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST10/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST11/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST11/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST12/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST12/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST13/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST13/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST14/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST14/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST15/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST15/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST16/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST16/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST17/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST17/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST18/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST18/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST19/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST19/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST20/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST20/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST21/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST21/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST22/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST22/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST23/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST23/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST24/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST24/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST25/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST25/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST26/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST26/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST27/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST27/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST28/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST28/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST29/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST29/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST30/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST30/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST31/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST31/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST32/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST32/RC_CGIC_INST/TE]  \
  [get_pins u0/RC_CG_HIER_INST33/RC_CGIC_INST/E]  \
  [get_pins u0/RC_CG_HIER_INST33/RC_CGIC_INST/TE]  \
  [get_pins u0/r0_RC_CG_HIER_INST34/RC_CGIC_INST/E]  \
  [get_pins u0/r0_RC_CG_HIER_INST34/RC_CGIC_INST/TE]  \
  [get_pins {u0/r0_out_reg[24]/D}]  \
  [get_pins {u0/r0_out_reg[25]/CN}]  \
  [get_pins {u0/r0_out_reg[25]/D}]  \
  [get_pins {u0/r0_out_reg[26]/CN}]  \
  [get_pins {u0/r0_out_reg[26]/D}]  \
  [get_pins {u0/r0_out_reg[27]/CN}]  \
  [get_pins {u0/r0_out_reg[27]/D}]  \
  [get_pins {u0/r0_out_reg[28]/CN}]  \
  [get_pins {u0/r0_out_reg[28]/D}]  \
  [get_pins {u0/r0_out_reg[29]/CN}]  \
  [get_pins {u0/r0_out_reg[29]/D}]  \
  [get_pins {u0/r0_out_reg[30]/CN}]  \
  [get_pins {u0/r0_out_reg[30]/D}]  \
  [get_pins {u0/r0_out_reg[31]/CN}]  \
  [get_pins {u0/r0_out_reg[31]/D}]  \
  [get_pins {u0/r0_rcnt_reg[0]/D}]  \
  [get_pins {u0/r0_rcnt_reg[1]/D}]  \
  [get_pins {u0/r0_rcnt_reg[2]/CN}]  \
  [get_pins {u0/r0_rcnt_reg[2]/D}]  \
  [get_pins {u0/r0_rcnt_reg[3]/CN}]  \
  [get_pins {u0/r0_rcnt_reg[3]/D}]  \
  [get_pins {u0/w_reg[0][0]/DA}]  \
  [get_pins {u0/w_reg[0][0]/DB}]  \
  [get_pins {u0/w_reg[0][0]/SA}]  \
  [get_pins {u0/w_reg[0][1]/DA}]  \
  [get_pins {u0/w_reg[0][1]/DB}]  \
  [get_pins {u0/w_reg[0][1]/SA}]  \
  [get_pins {u0/w_reg[0][2]/DA}]  \
  [get_pins {u0/w_reg[0][2]/DB}]  \
  [get_pins {u0/w_reg[0][2]/SA}]  \
  [get_pins {u0/w_reg[0][3]/DA}]  \
  [get_pins {u0/w_reg[0][3]/DB}]  \
  [get_pins {u0/w_reg[0][3]/SA}]  \
  [get_pins {u0/w_reg[0][4]/DA}]  \
  [get_pins {u0/w_reg[0][4]/DB}]  \
  [get_pins {u0/w_reg[0][4]/SA}]  \
  [get_pins {u0/w_reg[0][5]/DA}]  \
  [get_pins {u0/w_reg[0][5]/DB}]  \
  [get_pins {u0/w_reg[0][5]/SA}]  \
  [get_pins {u0/w_reg[0][6]/DA}]  \
  [get_pins {u0/w_reg[0][6]/DB}]  \
  [get_pins {u0/w_reg[0][6]/SA}]  \
  [get_pins {u0/w_reg[0][7]/DA}]  \
  [get_pins {u0/w_reg[0][7]/DB}]  \
  [get_pins {u0/w_reg[0][7]/SA}]  \
  [get_pins {u0/w_reg[0][8]/DA}]  \
  [get_pins {u0/w_reg[0][8]/DB}]  \
  [get_pins {u0/w_reg[0][8]/SA}]  \
  [get_pins {u0/w_reg[0][9]/DA}]  \
  [get_pins {u0/w_reg[0][9]/DB}]  \
  [get_pins {u0/w_reg[0][9]/SA}]  \
  [get_pins {u0/w_reg[0][10]/DA}]  \
  [get_pins {u0/w_reg[0][10]/DB}]  \
  [get_pins {u0/w_reg[0][10]/SA}]  \
  [get_pins {u0/w_reg[0][11]/DA}]  \
  [get_pins {u0/w_reg[0][11]/DB}]  \
  [get_pins {u0/w_reg[0][11]/SA}]  \
  [get_pins {u0/w_reg[0][12]/DA}]  \
  [get_pins {u0/w_reg[0][12]/DB}]  \
  [get_pins {u0/w_reg[0][12]/SA}]  \
  [get_pins {u0/w_reg[0][13]/DA}]  \
  [get_pins {u0/w_reg[0][13]/DB}]  \
  [get_pins {u0/w_reg[0][13]/SA}]  \
  [get_pins {u0/w_reg[0][14]/DA}]  \
  [get_pins {u0/w_reg[0][14]/DB}]  \
  [get_pins {u0/w_reg[0][14]/SA}]  \
  [get_pins {u0/w_reg[0][15]/DA}]  \
  [get_pins {u0/w_reg[0][15]/DB}]  \
  [get_pins {u0/w_reg[0][15]/SA}]  \
  [get_pins {u0/w_reg[0][16]/DA}]  \
  [get_pins {u0/w_reg[0][16]/DB}]  \
  [get_pins {u0/w_reg[0][16]/SA}]  \
  [get_pins {u0/w_reg[0][17]/DA}]  \
  [get_pins {u0/w_reg[0][17]/DB}]  \
  [get_pins {u0/w_reg[0][17]/SA}]  \
  [get_pins {u0/w_reg[0][18]/DA}]  \
  [get_pins {u0/w_reg[0][18]/DB}]  \
  [get_pins {u0/w_reg[0][18]/SA}]  \
  [get_pins {u0/w_reg[0][19]/DA}]  \
  [get_pins {u0/w_reg[0][19]/DB}]  \
  [get_pins {u0/w_reg[0][19]/SA}]  \
  [get_pins {u0/w_reg[0][20]/DA}]  \
  [get_pins {u0/w_reg[0][20]/DB}]  \
  [get_pins {u0/w_reg[0][20]/SA}]  \
  [get_pins {u0/w_reg[0][21]/DA}]  \
  [get_pins {u0/w_reg[0][21]/DB}]  \
  [get_pins {u0/w_reg[0][21]/SA}]  \
  [get_pins {u0/w_reg[0][22]/DA}]  \
  [get_pins {u0/w_reg[0][22]/DB}]  \
  [get_pins {u0/w_reg[0][22]/SA}]  \
  [get_pins {u0/w_reg[0][23]/DA}]  \
  [get_pins {u0/w_reg[0][23]/DB}]  \
  [get_pins {u0/w_reg[0][23]/SA}]  \
  [get_pins {u0/w_reg[0][24]/DA}]  \
  [get_pins {u0/w_reg[0][24]/DB}]  \
  [get_pins {u0/w_reg[0][24]/SA}]  \
  [get_pins {u0/w_reg[0][25]/DA}]  \
  [get_pins {u0/w_reg[0][25]/DB}]  \
  [get_pins {u0/w_reg[0][25]/SA}]  \
  [get_pins {u0/w_reg[0][26]/DA}]  \
  [get_pins {u0/w_reg[0][26]/DB}]  \
  [get_pins {u0/w_reg[0][26]/SA}]  \
  [get_pins {u0/w_reg[0][27]/DA}]  \
  [get_pins {u0/w_reg[0][27]/DB}]  \
  [get_pins {u0/w_reg[0][27]/SA}]  \
  [get_pins {u0/w_reg[0][28]/DA}]  \
  [get_pins {u0/w_reg[0][28]/DB}]  \
  [get_pins {u0/w_reg[0][28]/SA}]  \
  [get_pins {u0/w_reg[0][29]/DA}]  \
  [get_pins {u0/w_reg[0][29]/DB}]  \
  [get_pins {u0/w_reg[0][29]/SA}]  \
  [get_pins {u0/w_reg[0][30]/DA}]  \
  [get_pins {u0/w_reg[0][30]/DB}]  \
  [get_pins {u0/w_reg[0][30]/SA}]  \
  [get_pins {u0/w_reg[0][31]/DA}]  \
  [get_pins {u0/w_reg[0][31]/DB}]  \
  [get_pins {u0/w_reg[0][31]/SA}]  \
  [get_pins {u0/w_reg[1][0]/DA}]  \
  [get_pins {u0/w_reg[1][0]/DB}]  \
  [get_pins {u0/w_reg[1][0]/SA}]  \
  [get_pins {u0/w_reg[1][1]/DA}]  \
  [get_pins {u0/w_reg[1][1]/DB}]  \
  [get_pins {u0/w_reg[1][1]/SA}]  \
  [get_pins {u0/w_reg[1][2]/DA}]  \
  [get_pins {u0/w_reg[1][2]/DB}]  \
  [get_pins {u0/w_reg[1][2]/SA}]  \
  [get_pins {u0/w_reg[1][3]/DA}]  \
  [get_pins {u0/w_reg[1][3]/DB}]  \
  [get_pins {u0/w_reg[1][3]/SA}]  \
  [get_pins {u0/w_reg[1][4]/DA}]  \
  [get_pins {u0/w_reg[1][4]/DB}]  \
  [get_pins {u0/w_reg[1][4]/SA}]  \
  [get_pins {u0/w_reg[1][5]/DA}]  \
  [get_pins {u0/w_reg[1][5]/DB}]  \
  [get_pins {u0/w_reg[1][5]/SA}]  \
  [get_pins {u0/w_reg[1][6]/DA}]  \
  [get_pins {u0/w_reg[1][6]/DB}]  \
  [get_pins {u0/w_reg[1][6]/SA}]  \
  [get_pins {u0/w_reg[1][7]/DA}]  \
  [get_pins {u0/w_reg[1][7]/DB}]  \
  [get_pins {u0/w_reg[1][7]/SA}]  \
  [get_pins {u0/w_reg[1][8]/DA}]  \
  [get_pins {u0/w_reg[1][8]/DB}]  \
  [get_pins {u0/w_reg[1][8]/SA}]  \
  [get_pins {u0/w_reg[1][9]/DA}]  \
  [get_pins {u0/w_reg[1][9]/DB}]  \
  [get_pins {u0/w_reg[1][9]/SA}]  \
  [get_pins {u0/w_reg[1][10]/DA}]  \
  [get_pins {u0/w_reg[1][10]/DB}]  \
  [get_pins {u0/w_reg[1][10]/SA}]  \
  [get_pins {u0/w_reg[1][11]/DA}]  \
  [get_pins {u0/w_reg[1][11]/DB}]  \
  [get_pins {u0/w_reg[1][11]/SA}]  \
  [get_pins {u0/w_reg[1][12]/DA}]  \
  [get_pins {u0/w_reg[1][12]/DB}]  \
  [get_pins {u0/w_reg[1][12]/SA}]  \
  [get_pins {u0/w_reg[1][13]/DA}]  \
  [get_pins {u0/w_reg[1][13]/DB}]  \
  [get_pins {u0/w_reg[1][13]/SA}]  \
  [get_pins {u0/w_reg[1][14]/DA}]  \
  [get_pins {u0/w_reg[1][14]/DB}]  \
  [get_pins {u0/w_reg[1][14]/SA}]  \
  [get_pins {u0/w_reg[1][15]/DA}]  \
  [get_pins {u0/w_reg[1][15]/DB}]  \
  [get_pins {u0/w_reg[1][15]/SA}]  \
  [get_pins {u0/w_reg[1][16]/DA}]  \
  [get_pins {u0/w_reg[1][16]/DB}]  \
  [get_pins {u0/w_reg[1][16]/SA}]  \
  [get_pins {u0/w_reg[1][17]/DA}]  \
  [get_pins {u0/w_reg[1][17]/DB}]  \
  [get_pins {u0/w_reg[1][17]/SA}]  \
  [get_pins {u0/w_reg[1][18]/DA}]  \
  [get_pins {u0/w_reg[1][18]/DB}]  \
  [get_pins {u0/w_reg[1][18]/SA}]  \
  [get_pins {u0/w_reg[1][19]/DA}]  \
  [get_pins {u0/w_reg[1][19]/DB}]  \
  [get_pins {u0/w_reg[1][19]/SA}]  \
  [get_pins {u0/w_reg[1][20]/DA}]  \
  [get_pins {u0/w_reg[1][20]/DB}]  \
  [get_pins {u0/w_reg[1][20]/SA}]  \
  [get_pins {u0/w_reg[1][21]/DA}]  \
  [get_pins {u0/w_reg[1][21]/DB}]  \
  [get_pins {u0/w_reg[1][21]/SA}]  \
  [get_pins {u0/w_reg[1][22]/DA}]  \
  [get_pins {u0/w_reg[1][22]/DB}]  \
  [get_pins {u0/w_reg[1][22]/SA}]  \
  [get_pins {u0/w_reg[1][23]/DA}]  \
  [get_pins {u0/w_reg[1][23]/DB}]  \
  [get_pins {u0/w_reg[1][23]/SA}]  \
  [get_pins {u0/w_reg[1][24]/DA}]  \
  [get_pins {u0/w_reg[1][24]/DB}]  \
  [get_pins {u0/w_reg[1][24]/SA}]  \
  [get_pins {u0/w_reg[1][25]/DA}]  \
  [get_pins {u0/w_reg[1][25]/DB}]  \
  [get_pins {u0/w_reg[1][25]/SA}]  \
  [get_pins {u0/w_reg[1][26]/DA}]  \
  [get_pins {u0/w_reg[1][26]/DB}]  \
  [get_pins {u0/w_reg[1][26]/SA}]  \
  [get_pins {u0/w_reg[1][27]/DA}]  \
  [get_pins {u0/w_reg[1][27]/DB}]  \
  [get_pins {u0/w_reg[1][27]/SA}]  \
  [get_pins {u0/w_reg[1][28]/DA}]  \
  [get_pins {u0/w_reg[1][28]/DB}]  \
  [get_pins {u0/w_reg[1][28]/SA}]  \
  [get_pins {u0/w_reg[1][29]/DA}]  \
  [get_pins {u0/w_reg[1][29]/DB}]  \
  [get_pins {u0/w_reg[1][29]/SA}]  \
  [get_pins {u0/w_reg[1][30]/DA}]  \
  [get_pins {u0/w_reg[1][30]/DB}]  \
  [get_pins {u0/w_reg[1][30]/SA}]  \
  [get_pins {u0/w_reg[1][31]/DA}]  \
  [get_pins {u0/w_reg[1][31]/DB}]  \
  [get_pins {u0/w_reg[1][31]/SA}]  \
  [get_pins {u0/w_reg[2][0]/DA}]  \
  [get_pins {u0/w_reg[2][0]/DB}]  \
  [get_pins {u0/w_reg[2][0]/SA}]  \
  [get_pins {u0/w_reg[2][1]/DA}]  \
  [get_pins {u0/w_reg[2][1]/DB}]  \
  [get_pins {u0/w_reg[2][1]/SA}]  \
  [get_pins {u0/w_reg[2][2]/DA}]  \
  [get_pins {u0/w_reg[2][2]/DB}]  \
  [get_pins {u0/w_reg[2][2]/SA}]  \
  [get_pins {u0/w_reg[2][3]/DA}]  \
  [get_pins {u0/w_reg[2][3]/DB}]  \
  [get_pins {u0/w_reg[2][3]/SA}]  \
  [get_pins {u0/w_reg[2][4]/DA}]  \
  [get_pins {u0/w_reg[2][4]/DB}]  \
  [get_pins {u0/w_reg[2][4]/SA}]  \
  [get_pins {u0/w_reg[2][5]/DA}]  \
  [get_pins {u0/w_reg[2][5]/DB}]  \
  [get_pins {u0/w_reg[2][5]/SA}]  \
  [get_pins {u0/w_reg[2][6]/DA}]  \
  [get_pins {u0/w_reg[2][6]/DB}]  \
  [get_pins {u0/w_reg[2][6]/SA}]  \
  [get_pins {u0/w_reg[2][7]/DA}]  \
  [get_pins {u0/w_reg[2][7]/DB}]  \
  [get_pins {u0/w_reg[2][7]/SA}]  \
  [get_pins {u0/w_reg[2][8]/DA}]  \
  [get_pins {u0/w_reg[2][8]/DB}]  \
  [get_pins {u0/w_reg[2][8]/SA}]  \
  [get_pins {u0/w_reg[2][9]/DA}]  \
  [get_pins {u0/w_reg[2][9]/DB}]  \
  [get_pins {u0/w_reg[2][9]/SA}]  \
  [get_pins {u0/w_reg[2][10]/DA}]  \
  [get_pins {u0/w_reg[2][10]/DB}]  \
  [get_pins {u0/w_reg[2][10]/SA}]  \
  [get_pins {u0/w_reg[2][11]/DA}]  \
  [get_pins {u0/w_reg[2][11]/DB}]  \
  [get_pins {u0/w_reg[2][11]/SA}]  \
  [get_pins {u0/w_reg[2][12]/DA}]  \
  [get_pins {u0/w_reg[2][12]/DB}]  \
  [get_pins {u0/w_reg[2][12]/SA}]  \
  [get_pins {u0/w_reg[2][13]/DA}]  \
  [get_pins {u0/w_reg[2][13]/DB}]  \
  [get_pins {u0/w_reg[2][13]/SA}]  \
  [get_pins {u0/w_reg[2][14]/DA}]  \
  [get_pins {u0/w_reg[2][14]/DB}]  \
  [get_pins {u0/w_reg[2][14]/SA}]  \
  [get_pins {u0/w_reg[2][15]/DA}]  \
  [get_pins {u0/w_reg[2][15]/DB}]  \
  [get_pins {u0/w_reg[2][15]/SA}]  \
  [get_pins {u0/w_reg[2][16]/DA}]  \
  [get_pins {u0/w_reg[2][16]/DB}]  \
  [get_pins {u0/w_reg[2][16]/SA}]  \
  [get_pins {u0/w_reg[2][17]/DA}]  \
  [get_pins {u0/w_reg[2][17]/DB}]  \
  [get_pins {u0/w_reg[2][17]/SA}]  \
  [get_pins {u0/w_reg[2][18]/DA}]  \
  [get_pins {u0/w_reg[2][18]/DB}]  \
  [get_pins {u0/w_reg[2][18]/SA}]  \
  [get_pins {u0/w_reg[2][19]/DA}]  \
  [get_pins {u0/w_reg[2][19]/DB}]  \
  [get_pins {u0/w_reg[2][19]/SA}]  \
  [get_pins {u0/w_reg[2][20]/DA}]  \
  [get_pins {u0/w_reg[2][20]/DB}]  \
  [get_pins {u0/w_reg[2][20]/SA}]  \
  [get_pins {u0/w_reg[2][21]/DA}]  \
  [get_pins {u0/w_reg[2][21]/DB}]  \
  [get_pins {u0/w_reg[2][21]/SA}]  \
  [get_pins {u0/w_reg[2][22]/DA}]  \
  [get_pins {u0/w_reg[2][22]/DB}]  \
  [get_pins {u0/w_reg[2][22]/SA}]  \
  [get_pins {u0/w_reg[2][23]/DA}]  \
  [get_pins {u0/w_reg[2][23]/DB}]  \
  [get_pins {u0/w_reg[2][23]/SA}]  \
  [get_pins {u0/w_reg[2][24]/DA}]  \
  [get_pins {u0/w_reg[2][24]/DB}]  \
  [get_pins {u0/w_reg[2][24]/SA}]  \
  [get_pins {u0/w_reg[2][25]/DA}]  \
  [get_pins {u0/w_reg[2][25]/DB}]  \
  [get_pins {u0/w_reg[2][25]/SA}]  \
  [get_pins {u0/w_reg[2][26]/DA}]  \
  [get_pins {u0/w_reg[2][26]/DB}]  \
  [get_pins {u0/w_reg[2][26]/SA}]  \
  [get_pins {u0/w_reg[2][27]/DA}]  \
  [get_pins {u0/w_reg[2][27]/DB}]  \
  [get_pins {u0/w_reg[2][27]/SA}]  \
  [get_pins {u0/w_reg[2][28]/DA}]  \
  [get_pins {u0/w_reg[2][28]/DB}]  \
  [get_pins {u0/w_reg[2][28]/SA}]  \
  [get_pins {u0/w_reg[2][29]/DA}]  \
  [get_pins {u0/w_reg[2][29]/DB}]  \
  [get_pins {u0/w_reg[2][29]/SA}]  \
  [get_pins {u0/w_reg[2][30]/DA}]  \
  [get_pins {u0/w_reg[2][30]/DB}]  \
  [get_pins {u0/w_reg[2][30]/SA}]  \
  [get_pins {u0/w_reg[2][31]/DA}]  \
  [get_pins {u0/w_reg[2][31]/DB}]  \
  [get_pins {u0/w_reg[2][31]/SA}]  \
  [get_pins {u0/w_reg[3][0]/DA}]  \
  [get_pins {u0/w_reg[3][0]/DB}]  \
  [get_pins {u0/w_reg[3][0]/SA}]  \
  [get_pins {u0/w_reg[3][1]/DA}]  \
  [get_pins {u0/w_reg[3][1]/DB}]  \
  [get_pins {u0/w_reg[3][1]/SA}]  \
  [get_pins {u0/w_reg[3][2]/DA}]  \
  [get_pins {u0/w_reg[3][2]/DB}]  \
  [get_pins {u0/w_reg[3][2]/SA}]  \
  [get_pins {u0/w_reg[3][3]/DA}]  \
  [get_pins {u0/w_reg[3][3]/DB}]  \
  [get_pins {u0/w_reg[3][3]/SA}]  \
  [get_pins {u0/w_reg[3][4]/DA}]  \
  [get_pins {u0/w_reg[3][4]/DB}]  \
  [get_pins {u0/w_reg[3][4]/SA}]  \
  [get_pins {u0/w_reg[3][5]/DA}]  \
  [get_pins {u0/w_reg[3][5]/DB}]  \
  [get_pins {u0/w_reg[3][5]/SA}]  \
  [get_pins {u0/w_reg[3][6]/DA}]  \
  [get_pins {u0/w_reg[3][6]/DB}]  \
  [get_pins {u0/w_reg[3][6]/SA}]  \
  [get_pins {u0/w_reg[3][7]/DA}]  \
  [get_pins {u0/w_reg[3][7]/DB}]  \
  [get_pins {u0/w_reg[3][7]/SA}]  \
  [get_pins {u0/w_reg[3][8]/DA}]  \
  [get_pins {u0/w_reg[3][8]/DB}]  \
  [get_pins {u0/w_reg[3][8]/SA}]  \
  [get_pins {u0/w_reg[3][9]/DA}]  \
  [get_pins {u0/w_reg[3][9]/DB}]  \
  [get_pins {u0/w_reg[3][9]/SA}]  \
  [get_pins {u0/w_reg[3][10]/DA}]  \
  [get_pins {u0/w_reg[3][10]/DB}]  \
  [get_pins {u0/w_reg[3][10]/SA}]  \
  [get_pins {u0/w_reg[3][11]/DA}]  \
  [get_pins {u0/w_reg[3][11]/DB}]  \
  [get_pins {u0/w_reg[3][11]/SA}]  \
  [get_pins {u0/w_reg[3][12]/DA}]  \
  [get_pins {u0/w_reg[3][12]/DB}]  \
  [get_pins {u0/w_reg[3][12]/SA}]  \
  [get_pins {u0/w_reg[3][13]/DA}]  \
  [get_pins {u0/w_reg[3][13]/DB}]  \
  [get_pins {u0/w_reg[3][13]/SA}]  \
  [get_pins {u0/w_reg[3][14]/DA}]  \
  [get_pins {u0/w_reg[3][14]/DB}]  \
  [get_pins {u0/w_reg[3][14]/SA}]  \
  [get_pins {u0/w_reg[3][15]/DA}]  \
  [get_pins {u0/w_reg[3][15]/DB}]  \
  [get_pins {u0/w_reg[3][15]/SA}]  \
  [get_pins {u0/w_reg[3][16]/DA}]  \
  [get_pins {u0/w_reg[3][16]/DB}]  \
  [get_pins {u0/w_reg[3][16]/SA}]  \
  [get_pins {u0/w_reg[3][17]/DA}]  \
  [get_pins {u0/w_reg[3][17]/DB}]  \
  [get_pins {u0/w_reg[3][17]/SA}]  \
  [get_pins {u0/w_reg[3][18]/DA}]  \
  [get_pins {u0/w_reg[3][18]/DB}]  \
  [get_pins {u0/w_reg[3][18]/SA}]  \
  [get_pins {u0/w_reg[3][19]/DA}]  \
  [get_pins {u0/w_reg[3][19]/DB}]  \
  [get_pins {u0/w_reg[3][19]/SA}]  \
  [get_pins {u0/w_reg[3][20]/DA}]  \
  [get_pins {u0/w_reg[3][20]/DB}]  \
  [get_pins {u0/w_reg[3][20]/SA}]  \
  [get_pins {u0/w_reg[3][21]/DA}]  \
  [get_pins {u0/w_reg[3][21]/DB}]  \
  [get_pins {u0/w_reg[3][21]/SA}]  \
  [get_pins {u0/w_reg[3][22]/DA}]  \
  [get_pins {u0/w_reg[3][22]/DB}]  \
  [get_pins {u0/w_reg[3][22]/SA}]  \
  [get_pins {u0/w_reg[3][23]/DA}]  \
  [get_pins {u0/w_reg[3][23]/DB}]  \
  [get_pins {u0/w_reg[3][23]/SA}]  \
  [get_pins {u0/w_reg[3][24]/DA}]  \
  [get_pins {u0/w_reg[3][24]/DB}]  \
  [get_pins {u0/w_reg[3][24]/SA}]  \
  [get_pins {u0/w_reg[3][25]/DA}]  \
  [get_pins {u0/w_reg[3][25]/DB}]  \
  [get_pins {u0/w_reg[3][25]/SA}]  \
  [get_pins {u0/w_reg[3][26]/DA}]  \
  [get_pins {u0/w_reg[3][26]/DB}]  \
  [get_pins {u0/w_reg[3][26]/SA}]  \
  [get_pins {u0/w_reg[3][27]/DA}]  \
  [get_pins {u0/w_reg[3][27]/DB}]  \
  [get_pins {u0/w_reg[3][27]/SA}]  \
  [get_pins {u0/w_reg[3][28]/DA}]  \
  [get_pins {u0/w_reg[3][28]/DB}]  \
  [get_pins {u0/w_reg[3][28]/SA}]  \
  [get_pins {u0/w_reg[3][29]/DA}]  \
  [get_pins {u0/w_reg[3][29]/DB}]  \
  [get_pins {u0/w_reg[3][29]/SA}]  \
  [get_pins {u0/w_reg[3][30]/DA}]  \
  [get_pins {u0/w_reg[3][30]/DB}]  \
  [get_pins {u0/w_reg[3][30]/SA}]  \
  [get_pins {u0/w_reg[3][31]/DA}]  \
  [get_pins {u0/w_reg[3][31]/DB}]  \
  [get_pins {u0/w_reg[3][31]/SA}]  \
  [get_pins done_reg/CN]  \
  [get_pins done_reg/D]  \
  [get_pins ld_r_reg/D]  \
  [get_pins {sa00_reg[0]/DA}]  \
  [get_pins {sa00_reg[0]/DB}]  \
  [get_pins {sa00_reg[0]/SA}]  \
  [get_pins {sa00_reg[1]/DA}]  \
  [get_pins {sa00_reg[1]/DB}]  \
  [get_pins {sa00_reg[1]/SA}]  \
  [get_pins {sa00_reg[2]/DA}]  \
  [get_pins {sa00_reg[2]/DB}]  \
  [get_pins {sa00_reg[2]/SA}]  \
  [get_pins {sa00_reg[3]/DA}]  \
  [get_pins {sa00_reg[3]/DB}]  \
  [get_pins {sa00_reg[3]/SA}]  \
  [get_pins {sa00_reg[4]/DA}]  \
  [get_pins {sa00_reg[4]/DB}]  \
  [get_pins {sa00_reg[4]/SA}]  \
  [get_pins {sa00_reg[5]/DA}]  \
  [get_pins {sa00_reg[5]/DB}]  \
  [get_pins {sa00_reg[5]/SA}]  \
  [get_pins {sa00_reg[6]/DA}]  \
  [get_pins {sa00_reg[6]/DB}]  \
  [get_pins {sa00_reg[6]/SA}]  \
  [get_pins {sa00_reg[7]/DA}]  \
  [get_pins {sa00_reg[7]/DB}]  \
  [get_pins {sa00_reg[7]/SA}]  \
  [get_pins {sa01_reg[0]/DA}]  \
  [get_pins {sa01_reg[0]/DB}]  \
  [get_pins {sa01_reg[0]/SA}]  \
  [get_pins {sa01_reg[1]/DA}]  \
  [get_pins {sa01_reg[1]/DB}]  \
  [get_pins {sa01_reg[1]/SA}]  \
  [get_pins {sa01_reg[2]/DA}]  \
  [get_pins {sa01_reg[2]/DB}]  \
  [get_pins {sa01_reg[2]/SA}]  \
  [get_pins {sa01_reg[3]/DA}]  \
  [get_pins {sa01_reg[3]/DB}]  \
  [get_pins {sa01_reg[3]/SA}]  \
  [get_pins {sa01_reg[4]/DA}]  \
  [get_pins {sa01_reg[4]/DB}]  \
  [get_pins {sa01_reg[4]/SA}]  \
  [get_pins {sa01_reg[5]/DA}]  \
  [get_pins {sa01_reg[5]/DB}]  \
  [get_pins {sa01_reg[5]/SA}]  \
  [get_pins {sa01_reg[6]/DA}]  \
  [get_pins {sa01_reg[6]/DB}]  \
  [get_pins {sa01_reg[6]/SA}]  \
  [get_pins {sa01_reg[7]/DA}]  \
  [get_pins {sa01_reg[7]/DB}]  \
  [get_pins {sa01_reg[7]/SA}]  \
  [get_pins {sa02_reg[0]/DA}]  \
  [get_pins {sa02_reg[0]/DB}]  \
  [get_pins {sa02_reg[0]/SA}]  \
  [get_pins {sa02_reg[1]/DA}]  \
  [get_pins {sa02_reg[1]/DB}]  \
  [get_pins {sa02_reg[1]/SA}]  \
  [get_pins {sa02_reg[2]/DA}]  \
  [get_pins {sa02_reg[2]/DB}]  \
  [get_pins {sa02_reg[2]/SA}]  \
  [get_pins {sa02_reg[3]/DA}]  \
  [get_pins {sa02_reg[3]/DB}]  \
  [get_pins {sa02_reg[3]/SA}]  \
  [get_pins {sa02_reg[4]/DA}]  \
  [get_pins {sa02_reg[4]/DB}]  \
  [get_pins {sa02_reg[4]/SA}]  \
  [get_pins {sa02_reg[5]/DA}]  \
  [get_pins {sa02_reg[5]/DB}]  \
  [get_pins {sa02_reg[5]/SA}]  \
  [get_pins {sa02_reg[6]/DA}]  \
  [get_pins {sa02_reg[6]/DB}]  \
  [get_pins {sa02_reg[6]/SA}]  \
  [get_pins {sa02_reg[7]/DA}]  \
  [get_pins {sa02_reg[7]/DB}]  \
  [get_pins {sa02_reg[7]/SA}]  \
  [get_pins {sa03_reg[0]/DA}]  \
  [get_pins {sa03_reg[0]/DB}]  \
  [get_pins {sa03_reg[0]/SA}]  \
  [get_pins {sa03_reg[1]/DA}]  \
  [get_pins {sa03_reg[1]/DB}]  \
  [get_pins {sa03_reg[1]/SA}]  \
  [get_pins {sa03_reg[2]/DA}]  \
  [get_pins {sa03_reg[2]/DB}]  \
  [get_pins {sa03_reg[2]/SA}]  \
  [get_pins {sa03_reg[3]/DA}]  \
  [get_pins {sa03_reg[3]/DB}]  \
  [get_pins {sa03_reg[3]/SA}]  \
  [get_pins {sa03_reg[4]/DA}]  \
  [get_pins {sa03_reg[4]/DB}]  \
  [get_pins {sa03_reg[4]/SA}]  \
  [get_pins {sa03_reg[5]/DA}]  \
  [get_pins {sa03_reg[5]/DB}]  \
  [get_pins {sa03_reg[5]/SA}]  \
  [get_pins {sa03_reg[6]/DA}]  \
  [get_pins {sa03_reg[6]/DB}]  \
  [get_pins {sa03_reg[6]/SA}]  \
  [get_pins {sa03_reg[7]/DA}]  \
  [get_pins {sa03_reg[7]/DB}]  \
  [get_pins {sa03_reg[7]/SA}]  \
  [get_pins {sa10_reg[0]/DA}]  \
  [get_pins {sa10_reg[0]/DB}]  \
  [get_pins {sa10_reg[0]/SA}]  \
  [get_pins {sa10_reg[1]/DA}]  \
  [get_pins {sa10_reg[1]/DB}]  \
  [get_pins {sa10_reg[1]/SA}]  \
  [get_pins {sa10_reg[2]/DA}]  \
  [get_pins {sa10_reg[2]/DB}]  \
  [get_pins {sa10_reg[2]/SA}]  \
  [get_pins {sa10_reg[3]/DA}]  \
  [get_pins {sa10_reg[3]/DB}]  \
  [get_pins {sa10_reg[3]/SA}]  \
  [get_pins {sa10_reg[4]/DA}]  \
  [get_pins {sa10_reg[4]/DB}]  \
  [get_pins {sa10_reg[4]/SA}]  \
  [get_pins {sa10_reg[5]/DA}]  \
  [get_pins {sa10_reg[5]/DB}]  \
  [get_pins {sa10_reg[5]/SA}]  \
  [get_pins {sa10_reg[6]/DA}]  \
  [get_pins {sa10_reg[6]/DB}]  \
  [get_pins {sa10_reg[6]/SA}]  \
  [get_pins {sa10_reg[7]/DA}]  \
  [get_pins {sa10_reg[7]/DB}]  \
  [get_pins {sa10_reg[7]/SA}]  \
  [get_pins {sa11_reg[0]/DA}]  \
  [get_pins {sa11_reg[0]/DB}]  \
  [get_pins {sa11_reg[0]/SA}]  \
  [get_pins {sa11_reg[1]/DA}]  \
  [get_pins {sa11_reg[1]/DB}]  \
  [get_pins {sa11_reg[1]/SA}]  \
  [get_pins {sa11_reg[2]/DA}]  \
  [get_pins {sa11_reg[2]/DB}]  \
  [get_pins {sa11_reg[2]/SA}]  \
  [get_pins {sa11_reg[3]/DA}]  \
  [get_pins {sa11_reg[3]/DB}]  \
  [get_pins {sa11_reg[3]/SA}]  \
  [get_pins {sa11_reg[4]/DA}]  \
  [get_pins {sa11_reg[4]/DB}]  \
  [get_pins {sa11_reg[4]/SA}]  \
  [get_pins {sa11_reg[5]/DA}]  \
  [get_pins {sa11_reg[5]/DB}]  \
  [get_pins {sa11_reg[5]/SA}]  \
  [get_pins {sa11_reg[6]/DA}]  \
  [get_pins {sa11_reg[6]/DB}]  \
  [get_pins {sa11_reg[6]/SA}]  \
  [get_pins {sa11_reg[7]/DA}]  \
  [get_pins {sa11_reg[7]/DB}]  \
  [get_pins {sa11_reg[7]/SA}]  \
  [get_pins {sa12_reg[0]/DA}]  \
  [get_pins {sa12_reg[0]/DB}]  \
  [get_pins {sa12_reg[0]/SA}]  \
  [get_pins {sa12_reg[1]/DA}]  \
  [get_pins {sa12_reg[1]/DB}]  \
  [get_pins {sa12_reg[1]/SA}]  \
  [get_pins {sa12_reg[2]/DA}]  \
  [get_pins {sa12_reg[2]/DB}]  \
  [get_pins {sa12_reg[2]/SA}]  \
  [get_pins {sa12_reg[3]/DA}]  \
  [get_pins {sa12_reg[3]/DB}]  \
  [get_pins {sa12_reg[3]/SA}]  \
  [get_pins {sa12_reg[4]/DA}]  \
  [get_pins {sa12_reg[4]/DB}]  \
  [get_pins {sa12_reg[4]/SA}]  \
  [get_pins {sa12_reg[5]/DA}]  \
  [get_pins {sa12_reg[5]/DB}]  \
  [get_pins {sa12_reg[5]/SA}]  \
  [get_pins {sa12_reg[6]/DA}]  \
  [get_pins {sa12_reg[6]/DB}]  \
  [get_pins {sa12_reg[6]/SA}]  \
  [get_pins {sa12_reg[7]/DA}]  \
  [get_pins {sa12_reg[7]/DB}]  \
  [get_pins {sa12_reg[7]/SA}]  \
  [get_pins {sa13_reg[0]/DA}]  \
  [get_pins {sa13_reg[0]/DB}]  \
  [get_pins {sa13_reg[0]/SA}]  \
  [get_pins {sa13_reg[1]/DA}]  \
  [get_pins {sa13_reg[1]/DB}]  \
  [get_pins {sa13_reg[1]/SA}]  \
  [get_pins {sa13_reg[2]/DA}]  \
  [get_pins {sa13_reg[2]/DB}]  \
  [get_pins {sa13_reg[2]/SA}]  \
  [get_pins {sa13_reg[3]/DA}]  \
  [get_pins {sa13_reg[3]/DB}]  \
  [get_pins {sa13_reg[3]/SA}]  \
  [get_pins {sa13_reg[4]/DA}]  \
  [get_pins {sa13_reg[4]/DB}]  \
  [get_pins {sa13_reg[4]/SA}]  \
  [get_pins {sa13_reg[5]/DA}]  \
  [get_pins {sa13_reg[5]/DB}]  \
  [get_pins {sa13_reg[5]/SA}]  \
  [get_pins {sa13_reg[6]/DA}]  \
  [get_pins {sa13_reg[6]/DB}]  \
  [get_pins {sa13_reg[6]/SA}]  \
  [get_pins {sa13_reg[7]/DA}]  \
  [get_pins {sa13_reg[7]/DB}]  \
  [get_pins {sa13_reg[7]/SA}]  \
  [get_pins {sa20_reg[0]/DA}]  \
  [get_pins {sa20_reg[0]/DB}]  \
  [get_pins {sa20_reg[0]/SA}]  \
  [get_pins {sa20_reg[1]/DA}]  \
  [get_pins {sa20_reg[1]/DB}]  \
  [get_pins {sa20_reg[1]/SA}]  \
  [get_pins {sa20_reg[2]/DA}]  \
  [get_pins {sa20_reg[2]/DB}]  \
  [get_pins {sa20_reg[2]/SA}]  \
  [get_pins {sa20_reg[3]/DA}]  \
  [get_pins {sa20_reg[3]/DB}]  \
  [get_pins {sa20_reg[3]/SA}]  \
  [get_pins {sa20_reg[4]/DA}]  \
  [get_pins {sa20_reg[4]/DB}]  \
  [get_pins {sa20_reg[4]/SA}]  \
  [get_pins {sa20_reg[5]/DA}]  \
  [get_pins {sa20_reg[5]/DB}]  \
  [get_pins {sa20_reg[5]/SA}]  \
  [get_pins {sa20_reg[6]/DA}]  \
  [get_pins {sa20_reg[6]/DB}]  \
  [get_pins {sa20_reg[6]/SA}]  \
  [get_pins {sa20_reg[7]/DA}]  \
  [get_pins {sa20_reg[7]/DB}]  \
  [get_pins {sa20_reg[7]/SA}]  \
  [get_pins {sa21_reg[0]/DA}]  \
  [get_pins {sa21_reg[0]/DB}]  \
  [get_pins {sa21_reg[0]/SA}]  \
  [get_pins {sa21_reg[1]/DA}]  \
  [get_pins {sa21_reg[1]/DB}]  \
  [get_pins {sa21_reg[1]/SA}]  \
  [get_pins {sa21_reg[2]/DA}]  \
  [get_pins {sa21_reg[2]/DB}]  \
  [get_pins {sa21_reg[2]/SA}]  \
  [get_pins {sa21_reg[3]/DA}]  \
  [get_pins {sa21_reg[3]/DB}]  \
  [get_pins {sa21_reg[3]/SA}]  \
  [get_pins {sa21_reg[4]/DA}]  \
  [get_pins {sa21_reg[4]/DB}]  \
  [get_pins {sa21_reg[4]/SA}]  \
  [get_pins {sa21_reg[5]/DA}]  \
  [get_pins {sa21_reg[5]/DB}]  \
  [get_pins {sa21_reg[5]/SA}]  \
  [get_pins {sa21_reg[6]/DA}]  \
  [get_pins {sa21_reg[6]/DB}]  \
  [get_pins {sa21_reg[6]/SA}]  \
  [get_pins {sa21_reg[7]/DA}]  \
  [get_pins {sa21_reg[7]/DB}]  \
  [get_pins {sa21_reg[7]/SA}]  \
  [get_pins {sa22_reg[0]/DA}]  \
  [get_pins {sa22_reg[0]/DB}]  \
  [get_pins {sa22_reg[0]/SA}]  \
  [get_pins {sa22_reg[1]/DA}]  \
  [get_pins {sa22_reg[1]/DB}]  \
  [get_pins {sa22_reg[1]/SA}]  \
  [get_pins {sa22_reg[2]/DA}]  \
  [get_pins {sa22_reg[2]/DB}]  \
  [get_pins {sa22_reg[2]/SA}]  \
  [get_pins {sa22_reg[3]/DA}]  \
  [get_pins {sa22_reg[3]/DB}]  \
  [get_pins {sa22_reg[3]/SA}]  \
  [get_pins {sa22_reg[4]/DA}]  \
  [get_pins {sa22_reg[4]/DB}]  \
  [get_pins {sa22_reg[4]/SA}]  \
  [get_pins {sa22_reg[5]/DA}]  \
  [get_pins {sa22_reg[5]/DB}]  \
  [get_pins {sa22_reg[5]/SA}]  \
  [get_pins {sa22_reg[6]/DA}]  \
  [get_pins {sa22_reg[6]/DB}]  \
  [get_pins {sa22_reg[6]/SA}]  \
  [get_pins {sa22_reg[7]/DA}]  \
  [get_pins {sa22_reg[7]/DB}]  \
  [get_pins {sa22_reg[7]/SA}]  \
  [get_pins {sa23_reg[0]/DA}]  \
  [get_pins {sa23_reg[0]/DB}]  \
  [get_pins {sa23_reg[0]/SA}]  \
  [get_pins {sa23_reg[1]/DA}]  \
  [get_pins {sa23_reg[1]/DB}]  \
  [get_pins {sa23_reg[1]/SA}]  \
  [get_pins {sa23_reg[2]/DA}]  \
  [get_pins {sa23_reg[2]/DB}]  \
  [get_pins {sa23_reg[2]/SA}]  \
  [get_pins {sa23_reg[3]/DA}]  \
  [get_pins {sa23_reg[3]/DB}]  \
  [get_pins {sa23_reg[3]/SA}]  \
  [get_pins {sa23_reg[4]/DA}]  \
  [get_pins {sa23_reg[4]/DB}]  \
  [get_pins {sa23_reg[4]/SA}]  \
  [get_pins {sa23_reg[5]/DA}]  \
  [get_pins {sa23_reg[5]/DB}]  \
  [get_pins {sa23_reg[5]/SA}]  \
  [get_pins {sa23_reg[6]/DA}]  \
  [get_pins {sa23_reg[6]/DB}]  \
  [get_pins {sa23_reg[6]/SA}]  \
  [get_pins {sa23_reg[7]/DA}]  \
  [get_pins {sa23_reg[7]/DB}]  \
  [get_pins {sa23_reg[7]/SA}]  \
  [get_pins {sa30_reg[0]/DA}]  \
  [get_pins {sa30_reg[0]/DB}]  \
  [get_pins {sa30_reg[0]/SA}]  \
  [get_pins {sa30_reg[1]/DA}]  \
  [get_pins {sa30_reg[1]/DB}]  \
  [get_pins {sa30_reg[1]/SA}]  \
  [get_pins {sa30_reg[2]/DA}]  \
  [get_pins {sa30_reg[2]/DB}]  \
  [get_pins {sa30_reg[2]/SA}]  \
  [get_pins {sa30_reg[3]/DA}]  \
  [get_pins {sa30_reg[3]/DB}]  \
  [get_pins {sa30_reg[3]/SA}]  \
  [get_pins {sa30_reg[4]/DA}]  \
  [get_pins {sa30_reg[4]/DB}]  \
  [get_pins {sa30_reg[4]/SA}]  \
  [get_pins {sa30_reg[5]/DA}]  \
  [get_pins {sa30_reg[5]/DB}]  \
  [get_pins {sa30_reg[5]/SA}]  \
  [get_pins {sa30_reg[6]/DA}]  \
  [get_pins {sa30_reg[6]/DB}]  \
  [get_pins {sa30_reg[6]/SA}]  \
  [get_pins {sa30_reg[7]/DA}]  \
  [get_pins {sa30_reg[7]/DB}]  \
  [get_pins {sa30_reg[7]/SA}]  \
  [get_pins {sa31_reg[0]/DA}]  \
  [get_pins {sa31_reg[0]/DB}]  \
  [get_pins {sa31_reg[0]/SA}]  \
  [get_pins {sa31_reg[1]/DA}]  \
  [get_pins {sa31_reg[1]/DB}]  \
  [get_pins {sa31_reg[1]/SA}]  \
  [get_pins {sa31_reg[2]/DA}]  \
  [get_pins {sa31_reg[2]/DB}]  \
  [get_pins {sa31_reg[2]/SA}]  \
  [get_pins {sa31_reg[3]/DA}]  \
  [get_pins {sa31_reg[3]/DB}]  \
  [get_pins {sa31_reg[3]/SA}]  \
  [get_pins {sa31_reg[4]/DA}]  \
  [get_pins {sa31_reg[4]/DB}]  \
  [get_pins {sa31_reg[4]/SA}]  \
  [get_pins {sa31_reg[5]/DA}]  \
  [get_pins {sa31_reg[5]/DB}]  \
  [get_pins {sa31_reg[5]/SA}]  \
  [get_pins {sa31_reg[6]/DA}]  \
  [get_pins {sa31_reg[6]/DB}]  \
  [get_pins {sa31_reg[6]/SA}]  \
  [get_pins {sa31_reg[7]/DA}]  \
  [get_pins {sa31_reg[7]/DB}]  \
  [get_pins {sa31_reg[7]/SA}]  \
  [get_pins {sa32_reg[0]/DA}]  \
  [get_pins {sa32_reg[0]/DB}]  \
  [get_pins {sa32_reg[0]/SA}]  \
  [get_pins {sa32_reg[1]/DA}]  \
  [get_pins {sa32_reg[1]/DB}]  \
  [get_pins {sa32_reg[1]/SA}]  \
  [get_pins {sa32_reg[2]/DA}]  \
  [get_pins {sa32_reg[2]/DB}]  \
  [get_pins {sa32_reg[2]/SA}]  \
  [get_pins {sa32_reg[3]/DA}]  \
  [get_pins {sa32_reg[3]/DB}]  \
  [get_pins {sa32_reg[3]/SA}]  \
  [get_pins {sa32_reg[4]/DA}]  \
  [get_pins {sa32_reg[4]/DB}]  \
  [get_pins {sa32_reg[4]/SA}]  \
  [get_pins {sa32_reg[5]/DA}]  \
  [get_pins {sa32_reg[5]/DB}]  \
  [get_pins {sa32_reg[5]/SA}]  \
  [get_pins {sa32_reg[6]/DA}]  \
  [get_pins {sa32_reg[6]/DB}]  \
  [get_pins {sa32_reg[6]/SA}]  \
  [get_pins {sa32_reg[7]/DA}]  \
  [get_pins {sa32_reg[7]/DB}]  \
  [get_pins {sa32_reg[7]/SA}]  \
  [get_pins {sa33_reg[0]/DA}]  \
  [get_pins {sa33_reg[0]/DB}]  \
  [get_pins {sa33_reg[0]/SA}]  \
  [get_pins {sa33_reg[1]/DA}]  \
  [get_pins {sa33_reg[1]/DB}]  \
  [get_pins {sa33_reg[1]/SA}]  \
  [get_pins {sa33_reg[2]/DA}]  \
  [get_pins {sa33_reg[2]/DB}]  \
  [get_pins {sa33_reg[2]/SA}]  \
  [get_pins {sa33_reg[3]/DA}]  \
  [get_pins {sa33_reg[3]/DB}]  \
  [get_pins {sa33_reg[3]/SA}]  \
  [get_pins {sa33_reg[4]/DA}]  \
  [get_pins {sa33_reg[4]/DB}]  \
  [get_pins {sa33_reg[4]/SA}]  \
  [get_pins {sa33_reg[5]/DA}]  \
  [get_pins {sa33_reg[5]/DB}]  \
  [get_pins {sa33_reg[5]/SA}]  \
  [get_pins {sa33_reg[6]/DA}]  \
  [get_pins {sa33_reg[6]/DB}]  \
  [get_pins {sa33_reg[6]/SA}]  \
  [get_pins {sa33_reg[7]/DA}]  \
  [get_pins {sa33_reg[7]/DB}]  \
  [get_pins {sa33_reg[7]/SA}]  \
  [get_pins {text_in_r_reg[0]/D}]  \
  [get_pins {text_in_r_reg[1]/D}]  \
  [get_pins {text_in_r_reg[2]/D}]  \
  [get_pins {text_in_r_reg[3]/D}]  \
  [get_pins {text_in_r_reg[4]/D}]  \
  [get_pins {text_in_r_reg[5]/D}]  \
  [get_pins {text_in_r_reg[6]/D}]  \
  [get_pins {text_in_r_reg[7]/D}]  \
  [get_pins {text_in_r_reg[8]/D}]  \
  [get_pins {text_in_r_reg[9]/D}]  \
  [get_pins {text_in_r_reg[10]/D}]  \
  [get_pins {text_in_r_reg[11]/D}]  \
  [get_pins {text_in_r_reg[12]/D}]  \
  [get_pins {text_in_r_reg[13]/D}]  \
  [get_pins {text_in_r_reg[14]/D}]  \
  [get_pins {text_in_r_reg[15]/D}]  \
  [get_pins {text_in_r_reg[16]/D}]  \
  [get_pins {text_in_r_reg[17]/D}]  \
  [get_pins {text_in_r_reg[18]/D}]  \
  [get_pins {text_in_r_reg[19]/D}]  \
  [get_pins {text_in_r_reg[20]/D}]  \
  [get_pins {text_in_r_reg[21]/D}]  \
  [get_pins {text_in_r_reg[22]/D}]  \
  [get_pins {text_in_r_reg[23]/D}]  \
  [get_pins {text_in_r_reg[24]/D}]  \
  [get_pins {text_in_r_reg[25]/D}]  \
  [get_pins {text_in_r_reg[26]/D}]  \
  [get_pins {text_in_r_reg[27]/D}]  \
  [get_pins {text_in_r_reg[28]/D}]  \
  [get_pins {text_in_r_reg[29]/D}]  \
  [get_pins {text_in_r_reg[30]/D}]  \
  [get_pins {text_in_r_reg[31]/D}]  \
  [get_pins {text_in_r_reg[32]/D}]  \
  [get_pins {text_in_r_reg[33]/D}]  \
  [get_pins {text_in_r_reg[34]/D}]  \
  [get_pins {text_in_r_reg[35]/D}]  \
  [get_pins {text_in_r_reg[36]/D}]  \
  [get_pins {text_in_r_reg[37]/D}]  \
  [get_pins {text_in_r_reg[38]/D}]  \
  [get_pins {text_in_r_reg[39]/D}]  \
  [get_pins {text_in_r_reg[40]/D}]  \
  [get_pins {text_in_r_reg[41]/D}]  \
  [get_pins {text_in_r_reg[42]/D}]  \
  [get_pins {text_in_r_reg[43]/D}]  \
  [get_pins {text_in_r_reg[44]/D}]  \
  [get_pins {text_in_r_reg[45]/D}]  \
  [get_pins {text_in_r_reg[46]/D}]  \
  [get_pins {text_in_r_reg[47]/D}]  \
  [get_pins {text_in_r_reg[48]/D}]  \
  [get_pins {text_in_r_reg[49]/D}]  \
  [get_pins {text_in_r_reg[50]/D}]  \
  [get_pins {text_in_r_reg[51]/D}]  \
  [get_pins {text_in_r_reg[52]/D}]  \
  [get_pins {text_in_r_reg[53]/D}]  \
  [get_pins {text_in_r_reg[54]/D}]  \
  [get_pins {text_in_r_reg[55]/D}]  \
  [get_pins {text_in_r_reg[56]/D}]  \
  [get_pins {text_in_r_reg[57]/D}]  \
  [get_pins {text_in_r_reg[58]/D}]  \
  [get_pins {text_in_r_reg[59]/D}]  \
  [get_pins {text_in_r_reg[60]/D}]  \
  [get_pins {text_in_r_reg[61]/D}]  \
  [get_pins {text_in_r_reg[62]/D}]  \
  [get_pins {text_in_r_reg[63]/D}]  \
  [get_pins {text_in_r_reg[64]/D}]  \
  [get_pins {text_in_r_reg[65]/D}]  \
  [get_pins {text_in_r_reg[66]/D}]  \
  [get_pins {text_in_r_reg[67]/D}]  \
  [get_pins {text_in_r_reg[68]/D}]  \
  [get_pins {text_in_r_reg[69]/D}]  \
  [get_pins {text_in_r_reg[70]/D}]  \
  [get_pins {text_in_r_reg[71]/D}]  \
  [get_pins {text_in_r_reg[72]/D}]  \
  [get_pins {text_in_r_reg[73]/D}]  \
  [get_pins {text_in_r_reg[74]/D}]  \
  [get_pins {text_in_r_reg[75]/D}]  \
  [get_pins {text_in_r_reg[76]/D}]  \
  [get_pins {text_in_r_reg[77]/D}]  \
  [get_pins {text_in_r_reg[78]/D}]  \
  [get_pins {text_in_r_reg[79]/D}]  \
  [get_pins {text_in_r_reg[80]/D}]  \
  [get_pins {text_in_r_reg[81]/D}]  \
  [get_pins {text_in_r_reg[82]/D}]  \
  [get_pins {text_in_r_reg[83]/D}]  \
  [get_pins {text_in_r_reg[84]/D}]  \
  [get_pins {text_in_r_reg[85]/D}]  \
  [get_pins {text_in_r_reg[86]/D}]  \
  [get_pins {text_in_r_reg[87]/D}]  \
  [get_pins {text_in_r_reg[88]/D}]  \
  [get_pins {text_in_r_reg[89]/D}]  \
  [get_pins {text_in_r_reg[90]/D}]  \
  [get_pins {text_in_r_reg[91]/D}]  \
  [get_pins {text_in_r_reg[92]/D}]  \
  [get_pins {text_in_r_reg[93]/D}]  \
  [get_pins {text_in_r_reg[94]/D}]  \
  [get_pins {text_in_r_reg[95]/D}]  \
  [get_pins {text_in_r_reg[96]/D}]  \
  [get_pins {text_in_r_reg[97]/D}]  \
  [get_pins {text_in_r_reg[98]/D}]  \
  [get_pins {text_in_r_reg[99]/D}]  \
  [get_pins {text_in_r_reg[100]/D}]  \
  [get_pins {text_in_r_reg[101]/D}]  \
  [get_pins {text_in_r_reg[102]/D}]  \
  [get_pins {text_in_r_reg[103]/D}]  \
  [get_pins {text_in_r_reg[104]/D}]  \
  [get_pins {text_in_r_reg[105]/D}]  \
  [get_pins {text_in_r_reg[106]/D}]  \
  [get_pins {text_in_r_reg[107]/D}]  \
  [get_pins {text_in_r_reg[108]/D}]  \
  [get_pins {text_in_r_reg[109]/D}]  \
  [get_pins {text_in_r_reg[110]/D}]  \
  [get_pins {text_in_r_reg[111]/D}]  \
  [get_pins {text_in_r_reg[112]/D}]  \
  [get_pins {text_in_r_reg[113]/D}]  \
  [get_pins {text_in_r_reg[114]/D}]  \
  [get_pins {text_in_r_reg[115]/D}]  \
  [get_pins {text_in_r_reg[116]/D}]  \
  [get_pins {text_in_r_reg[117]/D}]  \
  [get_pins {text_in_r_reg[118]/D}]  \
  [get_pins {text_in_r_reg[119]/D}]  \
  [get_pins {text_in_r_reg[120]/D}]  \
  [get_pins {text_in_r_reg[121]/D}]  \
  [get_pins {text_in_r_reg[122]/D}]  \
  [get_pins {text_in_r_reg[123]/D}]  \
  [get_pins {text_in_r_reg[124]/D}]  \
  [get_pins {text_in_r_reg[125]/D}]  \
  [get_pins {text_in_r_reg[126]/D}]  \
  [get_pins {text_in_r_reg[127]/D}]  \
  [get_pins {text_out_reg[0]/DA}]  \
  [get_pins {text_out_reg[0]/DB}]  \
  [get_pins {text_out_reg[0]/SA}]  \
  [get_pins {text_out_reg[1]/DA}]  \
  [get_pins {text_out_reg[1]/DB}]  \
  [get_pins {text_out_reg[1]/SA}]  \
  [get_pins {text_out_reg[2]/DA}]  \
  [get_pins {text_out_reg[2]/DB}]  \
  [get_pins {text_out_reg[2]/SA}]  \
  [get_pins {text_out_reg[3]/DA}]  \
  [get_pins {text_out_reg[3]/DB}]  \
  [get_pins {text_out_reg[3]/SA}]  \
  [get_pins {text_out_reg[4]/DA}]  \
  [get_pins {text_out_reg[4]/DB}]  \
  [get_pins {text_out_reg[4]/SA}]  \
  [get_pins {text_out_reg[5]/DA}]  \
  [get_pins {text_out_reg[5]/DB}]  \
  [get_pins {text_out_reg[5]/SA}]  \
  [get_pins {text_out_reg[6]/DA}]  \
  [get_pins {text_out_reg[6]/DB}]  \
  [get_pins {text_out_reg[6]/SA}]  \
  [get_pins {text_out_reg[7]/DA}]  \
  [get_pins {text_out_reg[7]/DB}]  \
  [get_pins {text_out_reg[7]/SA}]  \
  [get_pins {text_out_reg[8]/DA}]  \
  [get_pins {text_out_reg[8]/DB}]  \
  [get_pins {text_out_reg[8]/SA}]  \
  [get_pins {text_out_reg[9]/DA}]  \
  [get_pins {text_out_reg[9]/DB}]  \
  [get_pins {text_out_reg[9]/SA}]  \
  [get_pins {text_out_reg[10]/DA}]  \
  [get_pins {text_out_reg[10]/DB}]  \
  [get_pins {text_out_reg[10]/SA}]  \
  [get_pins {text_out_reg[11]/DA}]  \
  [get_pins {text_out_reg[11]/DB}]  \
  [get_pins {text_out_reg[11]/SA}]  \
  [get_pins {text_out_reg[12]/DA}]  \
  [get_pins {text_out_reg[12]/DB}]  \
  [get_pins {text_out_reg[12]/SA}]  \
  [get_pins {text_out_reg[13]/DA}]  \
  [get_pins {text_out_reg[13]/DB}]  \
  [get_pins {text_out_reg[13]/SA}]  \
  [get_pins {text_out_reg[14]/DA}]  \
  [get_pins {text_out_reg[14]/DB}]  \
  [get_pins {text_out_reg[14]/SA}]  \
  [get_pins {text_out_reg[15]/DA}]  \
  [get_pins {text_out_reg[15]/DB}]  \
  [get_pins {text_out_reg[15]/SA}]  \
  [get_pins {text_out_reg[16]/DA}]  \
  [get_pins {text_out_reg[16]/DB}]  \
  [get_pins {text_out_reg[16]/SA}]  \
  [get_pins {text_out_reg[17]/DA}]  \
  [get_pins {text_out_reg[17]/DB}]  \
  [get_pins {text_out_reg[17]/SA}]  \
  [get_pins {text_out_reg[18]/DA}]  \
  [get_pins {text_out_reg[18]/DB}]  \
  [get_pins {text_out_reg[18]/SA}]  \
  [get_pins {text_out_reg[19]/DA}]  \
  [get_pins {text_out_reg[19]/DB}]  \
  [get_pins {text_out_reg[19]/SA}]  \
  [get_pins {text_out_reg[20]/DA}]  \
  [get_pins {text_out_reg[20]/DB}]  \
  [get_pins {text_out_reg[20]/SA}]  \
  [get_pins {text_out_reg[21]/DA}]  \
  [get_pins {text_out_reg[21]/DB}]  \
  [get_pins {text_out_reg[21]/SA}]  \
  [get_pins {text_out_reg[22]/DA}]  \
  [get_pins {text_out_reg[22]/DB}]  \
  [get_pins {text_out_reg[22]/SA}]  \
  [get_pins {text_out_reg[23]/DA}]  \
  [get_pins {text_out_reg[23]/DB}]  \
  [get_pins {text_out_reg[23]/SA}]  \
  [get_pins {text_out_reg[24]/DA}]  \
  [get_pins {text_out_reg[24]/DB}]  \
  [get_pins {text_out_reg[24]/SA}]  \
  [get_pins {text_out_reg[25]/DA}]  \
  [get_pins {text_out_reg[25]/DB}]  \
  [get_pins {text_out_reg[25]/SA}]  \
  [get_pins {text_out_reg[26]/DA}]  \
  [get_pins {text_out_reg[26]/DB}]  \
  [get_pins {text_out_reg[26]/SA}]  \
  [get_pins {text_out_reg[27]/DA}]  \
  [get_pins {text_out_reg[27]/DB}]  \
  [get_pins {text_out_reg[27]/SA}]  \
  [get_pins {text_out_reg[28]/DA}]  \
  [get_pins {text_out_reg[28]/DB}]  \
  [get_pins {text_out_reg[28]/SA}]  \
  [get_pins {text_out_reg[29]/DA}]  \
  [get_pins {text_out_reg[29]/DB}]  \
  [get_pins {text_out_reg[29]/SA}]  \
  [get_pins {text_out_reg[30]/DA}]  \
  [get_pins {text_out_reg[30]/DB}]  \
  [get_pins {text_out_reg[30]/SA}]  \
  [get_pins {text_out_reg[31]/DA}]  \
  [get_pins {text_out_reg[31]/DB}]  \
  [get_pins {text_out_reg[31]/SA}]  \
  [get_pins {text_out_reg[32]/DA}]  \
  [get_pins {text_out_reg[32]/DB}]  \
  [get_pins {text_out_reg[32]/SA}]  \
  [get_pins {text_out_reg[33]/DA}]  \
  [get_pins {text_out_reg[33]/DB}]  \
  [get_pins {text_out_reg[33]/SA}]  \
  [get_pins {text_out_reg[34]/DA}]  \
  [get_pins {text_out_reg[34]/DB}]  \
  [get_pins {text_out_reg[34]/SA}]  \
  [get_pins {text_out_reg[35]/DA}]  \
  [get_pins {text_out_reg[35]/DB}]  \
  [get_pins {text_out_reg[35]/SA}]  \
  [get_pins {text_out_reg[36]/DA}]  \
  [get_pins {text_out_reg[36]/DB}]  \
  [get_pins {text_out_reg[36]/SA}]  \
  [get_pins {text_out_reg[37]/DA}]  \
  [get_pins {text_out_reg[37]/DB}]  \
  [get_pins {text_out_reg[37]/SA}]  \
  [get_pins {text_out_reg[38]/DA}]  \
  [get_pins {text_out_reg[38]/DB}]  \
  [get_pins {text_out_reg[38]/SA}]  \
  [get_pins {text_out_reg[39]/DA}]  \
  [get_pins {text_out_reg[39]/DB}]  \
  [get_pins {text_out_reg[39]/SA}]  \
  [get_pins {text_out_reg[40]/DA}]  \
  [get_pins {text_out_reg[40]/DB}]  \
  [get_pins {text_out_reg[40]/SA}]  \
  [get_pins {text_out_reg[41]/DA}]  \
  [get_pins {text_out_reg[41]/DB}]  \
  [get_pins {text_out_reg[41]/SA}]  \
  [get_pins {text_out_reg[42]/DA}]  \
  [get_pins {text_out_reg[42]/DB}]  \
  [get_pins {text_out_reg[42]/SA}]  \
  [get_pins {text_out_reg[43]/DA}]  \
  [get_pins {text_out_reg[43]/DB}]  \
  [get_pins {text_out_reg[43]/SA}]  \
  [get_pins {text_out_reg[44]/DA}]  \
  [get_pins {text_out_reg[44]/DB}]  \
  [get_pins {text_out_reg[44]/SA}]  \
  [get_pins {text_out_reg[45]/DA}]  \
  [get_pins {text_out_reg[45]/DB}]  \
  [get_pins {text_out_reg[45]/SA}]  \
  [get_pins {text_out_reg[46]/DA}]  \
  [get_pins {text_out_reg[46]/DB}]  \
  [get_pins {text_out_reg[46]/SA}]  \
  [get_pins {text_out_reg[47]/DA}]  \
  [get_pins {text_out_reg[47]/DB}]  \
  [get_pins {text_out_reg[47]/SA}]  \
  [get_pins {text_out_reg[48]/DA}]  \
  [get_pins {text_out_reg[48]/DB}]  \
  [get_pins {text_out_reg[48]/SA}]  \
  [get_pins {text_out_reg[49]/DA}]  \
  [get_pins {text_out_reg[49]/DB}]  \
  [get_pins {text_out_reg[49]/SA}]  \
  [get_pins {text_out_reg[50]/DA}]  \
  [get_pins {text_out_reg[50]/DB}]  \
  [get_pins {text_out_reg[50]/SA}]  \
  [get_pins {text_out_reg[51]/DA}]  \
  [get_pins {text_out_reg[51]/DB}]  \
  [get_pins {text_out_reg[51]/SA}]  \
  [get_pins {text_out_reg[52]/DA}]  \
  [get_pins {text_out_reg[52]/DB}]  \
  [get_pins {text_out_reg[52]/SA}]  \
  [get_pins {text_out_reg[53]/DA}]  \
  [get_pins {text_out_reg[53]/DB}]  \
  [get_pins {text_out_reg[53]/SA}]  \
  [get_pins {text_out_reg[54]/DA}]  \
  [get_pins {text_out_reg[54]/DB}]  \
  [get_pins {text_out_reg[54]/SA}]  \
  [get_pins {text_out_reg[55]/DA}]  \
  [get_pins {text_out_reg[55]/DB}]  \
  [get_pins {text_out_reg[55]/SA}]  \
  [get_pins {text_out_reg[56]/DA}]  \
  [get_pins {text_out_reg[56]/DB}]  \
  [get_pins {text_out_reg[56]/SA}]  \
  [get_pins {text_out_reg[57]/DA}]  \
  [get_pins {text_out_reg[57]/DB}]  \
  [get_pins {text_out_reg[57]/SA}]  \
  [get_pins {text_out_reg[58]/DA}]  \
  [get_pins {text_out_reg[58]/DB}]  \
  [get_pins {text_out_reg[58]/SA}]  \
  [get_pins {text_out_reg[59]/DA}]  \
  [get_pins {text_out_reg[59]/DB}]  \
  [get_pins {text_out_reg[59]/SA}]  \
  [get_pins {text_out_reg[60]/DA}]  \
  [get_pins {text_out_reg[60]/DB}]  \
  [get_pins {text_out_reg[60]/SA}]  \
  [get_pins {text_out_reg[61]/DA}]  \
  [get_pins {text_out_reg[61]/DB}]  \
  [get_pins {text_out_reg[61]/SA}]  \
  [get_pins {text_out_reg[62]/DA}]  \
  [get_pins {text_out_reg[62]/DB}]  \
  [get_pins {text_out_reg[62]/SA}]  \
  [get_pins {text_out_reg[63]/DA}]  \
  [get_pins {text_out_reg[63]/DB}]  \
  [get_pins {text_out_reg[63]/SA}]  \
  [get_pins {text_out_reg[64]/DA}]  \
  [get_pins {text_out_reg[64]/DB}]  \
  [get_pins {text_out_reg[64]/SA}]  \
  [get_pins {text_out_reg[65]/DA}]  \
  [get_pins {text_out_reg[65]/DB}]  \
  [get_pins {text_out_reg[65]/SA}]  \
  [get_pins {text_out_reg[66]/DA}]  \
  [get_pins {text_out_reg[66]/DB}]  \
  [get_pins {text_out_reg[66]/SA}]  \
  [get_pins {text_out_reg[67]/DA}]  \
  [get_pins {text_out_reg[67]/DB}]  \
  [get_pins {text_out_reg[67]/SA}]  \
  [get_pins {text_out_reg[68]/DA}]  \
  [get_pins {text_out_reg[68]/DB}]  \
  [get_pins {text_out_reg[68]/SA}]  \
  [get_pins {text_out_reg[69]/DA}]  \
  [get_pins {text_out_reg[69]/DB}]  \
  [get_pins {text_out_reg[69]/SA}]  \
  [get_pins {text_out_reg[70]/DA}]  \
  [get_pins {text_out_reg[70]/DB}]  \
  [get_pins {text_out_reg[70]/SA}]  \
  [get_pins {text_out_reg[71]/DA}]  \
  [get_pins {text_out_reg[71]/DB}]  \
  [get_pins {text_out_reg[71]/SA}]  \
  [get_pins {text_out_reg[72]/DA}]  \
  [get_pins {text_out_reg[72]/DB}]  \
  [get_pins {text_out_reg[72]/SA}]  \
  [get_pins {text_out_reg[73]/DA}]  \
  [get_pins {text_out_reg[73]/DB}]  \
  [get_pins {text_out_reg[73]/SA}]  \
  [get_pins {text_out_reg[74]/DA}]  \
  [get_pins {text_out_reg[74]/DB}]  \
  [get_pins {text_out_reg[74]/SA}]  \
  [get_pins {text_out_reg[75]/DA}]  \
  [get_pins {text_out_reg[75]/DB}]  \
  [get_pins {text_out_reg[75]/SA}]  \
  [get_pins {text_out_reg[76]/DA}]  \
  [get_pins {text_out_reg[76]/DB}]  \
  [get_pins {text_out_reg[76]/SA}]  \
  [get_pins {text_out_reg[77]/DA}]  \
  [get_pins {text_out_reg[77]/DB}]  \
  [get_pins {text_out_reg[77]/SA}]  \
  [get_pins {text_out_reg[78]/DA}]  \
  [get_pins {text_out_reg[78]/DB}]  \
  [get_pins {text_out_reg[78]/SA}]  \
  [get_pins {text_out_reg[79]/DA}]  \
  [get_pins {text_out_reg[79]/DB}]  \
  [get_pins {text_out_reg[79]/SA}]  \
  [get_pins {text_out_reg[80]/DA}]  \
  [get_pins {text_out_reg[80]/DB}]  \
  [get_pins {text_out_reg[80]/SA}]  \
  [get_pins {text_out_reg[81]/DA}]  \
  [get_pins {text_out_reg[81]/DB}]  \
  [get_pins {text_out_reg[81]/SA}]  \
  [get_pins {text_out_reg[82]/DA}]  \
  [get_pins {text_out_reg[82]/DB}]  \
  [get_pins {text_out_reg[82]/SA}]  \
  [get_pins {text_out_reg[83]/DA}]  \
  [get_pins {text_out_reg[83]/DB}]  \
  [get_pins {text_out_reg[83]/SA}]  \
  [get_pins {text_out_reg[84]/DA}]  \
  [get_pins {text_out_reg[84]/DB}]  \
  [get_pins {text_out_reg[84]/SA}]  \
  [get_pins {text_out_reg[85]/DA}]  \
  [get_pins {text_out_reg[85]/DB}]  \
  [get_pins {text_out_reg[85]/SA}]  \
  [get_pins {text_out_reg[86]/DA}]  \
  [get_pins {text_out_reg[86]/DB}]  \
  [get_pins {text_out_reg[86]/SA}]  \
  [get_pins {text_out_reg[87]/DA}]  \
  [get_pins {text_out_reg[87]/DB}]  \
  [get_pins {text_out_reg[87]/SA}]  \
  [get_pins {text_out_reg[88]/DA}]  \
  [get_pins {text_out_reg[88]/DB}]  \
  [get_pins {text_out_reg[88]/SA}]  \
  [get_pins {text_out_reg[89]/DA}]  \
  [get_pins {text_out_reg[89]/DB}]  \
  [get_pins {text_out_reg[89]/SA}]  \
  [get_pins {text_out_reg[90]/DA}]  \
  [get_pins {text_out_reg[90]/DB}]  \
  [get_pins {text_out_reg[90]/SA}]  \
  [get_pins {text_out_reg[91]/DA}]  \
  [get_pins {text_out_reg[91]/DB}]  \
  [get_pins {text_out_reg[91]/SA}]  \
  [get_pins {text_out_reg[92]/DA}]  \
  [get_pins {text_out_reg[92]/DB}]  \
  [get_pins {text_out_reg[92]/SA}]  \
  [get_pins {text_out_reg[93]/DA}]  \
  [get_pins {text_out_reg[93]/DB}]  \
  [get_pins {text_out_reg[93]/SA}]  \
  [get_pins {text_out_reg[94]/DA}]  \
  [get_pins {text_out_reg[94]/DB}]  \
  [get_pins {text_out_reg[94]/SA}]  \
  [get_pins {text_out_reg[95]/DA}]  \
  [get_pins {text_out_reg[95]/DB}]  \
  [get_pins {text_out_reg[95]/SA}]  \
  [get_pins {text_out_reg[96]/DA}]  \
  [get_pins {text_out_reg[96]/DB}]  \
  [get_pins {text_out_reg[96]/SA}]  \
  [get_pins {text_out_reg[97]/DA}]  \
  [get_pins {text_out_reg[97]/DB}]  \
  [get_pins {text_out_reg[97]/SA}]  \
  [get_pins {text_out_reg[98]/DA}]  \
  [get_pins {text_out_reg[98]/DB}]  \
  [get_pins {text_out_reg[98]/SA}]  \
  [get_pins {text_out_reg[99]/DA}]  \
  [get_pins {text_out_reg[99]/DB}]  \
  [get_pins {text_out_reg[99]/SA}]  \
  [get_pins {text_out_reg[100]/DA}]  \
  [get_pins {text_out_reg[100]/DB}]  \
  [get_pins {text_out_reg[100]/SA}]  \
  [get_pins {text_out_reg[101]/DA}]  \
  [get_pins {text_out_reg[101]/DB}]  \
  [get_pins {text_out_reg[101]/SA}]  \
  [get_pins {text_out_reg[102]/DA}]  \
  [get_pins {text_out_reg[102]/DB}]  \
  [get_pins {text_out_reg[102]/SA}]  \
  [get_pins {text_out_reg[103]/DA}]  \
  [get_pins {text_out_reg[103]/DB}]  \
  [get_pins {text_out_reg[103]/SA}]  \
  [get_pins {text_out_reg[104]/DA}]  \
  [get_pins {text_out_reg[104]/DB}]  \
  [get_pins {text_out_reg[104]/SA}]  \
  [get_pins {text_out_reg[105]/DA}]  \
  [get_pins {text_out_reg[105]/DB}]  \
  [get_pins {text_out_reg[105]/SA}]  \
  [get_pins {text_out_reg[106]/DA}]  \
  [get_pins {text_out_reg[106]/DB}]  \
  [get_pins {text_out_reg[106]/SA}]  \
  [get_pins {text_out_reg[107]/DA}]  \
  [get_pins {text_out_reg[107]/DB}]  \
  [get_pins {text_out_reg[107]/SA}]  \
  [get_pins {text_out_reg[108]/DA}]  \
  [get_pins {text_out_reg[108]/DB}]  \
  [get_pins {text_out_reg[108]/SA}]  \
  [get_pins {text_out_reg[109]/DA}]  \
  [get_pins {text_out_reg[109]/DB}]  \
  [get_pins {text_out_reg[109]/SA}]  \
  [get_pins {text_out_reg[110]/DA}]  \
  [get_pins {text_out_reg[110]/DB}]  \
  [get_pins {text_out_reg[110]/SA}]  \
  [get_pins {text_out_reg[111]/DA}]  \
  [get_pins {text_out_reg[111]/DB}]  \
  [get_pins {text_out_reg[111]/SA}]  \
  [get_pins {text_out_reg[112]/DA}]  \
  [get_pins {text_out_reg[112]/DB}]  \
  [get_pins {text_out_reg[112]/SA}]  \
  [get_pins {text_out_reg[113]/DA}]  \
  [get_pins {text_out_reg[113]/DB}]  \
  [get_pins {text_out_reg[113]/SA}]  \
  [get_pins {text_out_reg[114]/DA}]  \
  [get_pins {text_out_reg[114]/DB}]  \
  [get_pins {text_out_reg[114]/SA}]  \
  [get_pins {text_out_reg[115]/DA}]  \
  [get_pins {text_out_reg[115]/DB}]  \
  [get_pins {text_out_reg[115]/SA}]  \
  [get_pins {text_out_reg[116]/DA}]  \
  [get_pins {text_out_reg[116]/DB}]  \
  [get_pins {text_out_reg[116]/SA}]  \
  [get_pins {text_out_reg[117]/DA}]  \
  [get_pins {text_out_reg[117]/DB}]  \
  [get_pins {text_out_reg[117]/SA}]  \
  [get_pins {text_out_reg[118]/DA}]  \
  [get_pins {text_out_reg[118]/DB}]  \
  [get_pins {text_out_reg[118]/SA}]  \
  [get_pins {text_out_reg[119]/DA}]  \
  [get_pins {text_out_reg[119]/DB}]  \
  [get_pins {text_out_reg[119]/SA}]  \
  [get_pins {text_out_reg[120]/DA}]  \
  [get_pins {text_out_reg[120]/DB}]  \
  [get_pins {text_out_reg[120]/SA}]  \
  [get_pins {text_out_reg[121]/DA}]  \
  [get_pins {text_out_reg[121]/DB}]  \
  [get_pins {text_out_reg[121]/SA}]  \
  [get_pins {text_out_reg[122]/DA}]  \
  [get_pins {text_out_reg[122]/DB}]  \
  [get_pins {text_out_reg[122]/SA}]  \
  [get_pins {text_out_reg[123]/DA}]  \
  [get_pins {text_out_reg[123]/DB}]  \
  [get_pins {text_out_reg[123]/SA}]  \
  [get_pins {text_out_reg[124]/DA}]  \
  [get_pins {text_out_reg[124]/DB}]  \
  [get_pins {text_out_reg[124]/SA}]  \
  [get_pins {text_out_reg[125]/DA}]  \
  [get_pins {text_out_reg[125]/DB}]  \
  [get_pins {text_out_reg[125]/SA}]  \
  [get_pins {text_out_reg[126]/DA}]  \
  [get_pins {text_out_reg[126]/DB}]  \
  [get_pins {text_out_reg[126]/SA}]  \
  [get_pins {text_out_reg[127]/DA}]  \
  [get_pins {text_out_reg[127]/DB}]  \
  [get_pins {text_out_reg[127]/SA}]  \
  [get_pins {dcnt_reg[2]/CN}]  \
  [get_pins {dcnt_reg[2]/D}]  \
  [get_pins {dcnt_reg[3]/DA}]  \
  [get_pins {dcnt_reg[3]/DB}]  \
  [get_pins {dcnt_reg[3]/SA}]  \
  [get_pins {dcnt_reg[1]/DA}]  \
  [get_pins {dcnt_reg[1]/DB}]  \
  [get_pins {dcnt_reg[1]/SA}]  \
  [get_pins {dcnt_reg[0]/DA}]  \
  [get_pins {dcnt_reg[0]/DB}]  \
  [get_pins {dcnt_reg[0]/SA}] ]
group_path -weight 1.000000 -name reg2out -from [list \
  [get_pins RC_CG_HIER_INST0/RC_CGIC_INST/CP]  \
  [get_pins RC_CG_HIER_INST1/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST2/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST3/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST4/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST5/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST6/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST7/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST8/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST9/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST10/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST11/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST12/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST13/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST14/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST15/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST16/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST17/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST18/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST19/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST20/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST21/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST22/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST23/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST24/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST25/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST26/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST27/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST28/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST29/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST30/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST31/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST32/RC_CGIC_INST/CP]  \
  [get_pins u0/RC_CG_HIER_INST33/RC_CGIC_INST/CP]  \
  [get_pins u0/r0_RC_CG_HIER_INST34/RC_CGIC_INST/CP]  \
  [get_pins {u0/r0_out_reg[24]/CP}]  \
  [get_pins {u0/r0_out_reg[25]/CP}]  \
  [get_pins {u0/r0_out_reg[26]/CP}]  \
  [get_pins {u0/r0_out_reg[27]/CP}]  \
  [get_pins {u0/r0_out_reg[28]/CP}]  \
  [get_pins {u0/r0_out_reg[29]/CP}]  \
  [get_pins {u0/r0_out_reg[30]/CP}]  \
  [get_pins {u0/r0_out_reg[31]/CP}]  \
  [get_pins {u0/r0_rcnt_reg[0]/CP}]  \
  [get_pins {u0/r0_rcnt_reg[1]/CP}]  \
  [get_pins {u0/r0_rcnt_reg[2]/CP}]  \
  [get_pins {u0/r0_rcnt_reg[3]/CP}]  \
  [get_pins {u0/w_reg[0][0]/CP}]  \
  [get_pins {u0/w_reg[0][1]/CP}]  \
  [get_pins {u0/w_reg[0][2]/CP}]  \
  [get_pins {u0/w_reg[0][3]/CP}]  \
  [get_pins {u0/w_reg[0][4]/CP}]  \
  [get_pins {u0/w_reg[0][5]/CP}]  \
  [get_pins {u0/w_reg[0][6]/CP}]  \
  [get_pins {u0/w_reg[0][7]/CP}]  \
  [get_pins {u0/w_reg[0][8]/CP}]  \
  [get_pins {u0/w_reg[0][9]/CP}]  \
  [get_pins {u0/w_reg[0][10]/CP}]  \
  [get_pins {u0/w_reg[0][11]/CP}]  \
  [get_pins {u0/w_reg[0][12]/CP}]  \
  [get_pins {u0/w_reg[0][13]/CP}]  \
  [get_pins {u0/w_reg[0][14]/CP}]  \
  [get_pins {u0/w_reg[0][15]/CP}]  \
  [get_pins {u0/w_reg[0][16]/CP}]  \
  [get_pins {u0/w_reg[0][17]/CP}]  \
  [get_pins {u0/w_reg[0][18]/CP}]  \
  [get_pins {u0/w_reg[0][19]/CP}]  \
  [get_pins {u0/w_reg[0][20]/CP}]  \
  [get_pins {u0/w_reg[0][21]/CP}]  \
  [get_pins {u0/w_reg[0][22]/CP}]  \
  [get_pins {u0/w_reg[0][23]/CP}]  \
  [get_pins {u0/w_reg[0][24]/CP}]  \
  [get_pins {u0/w_reg[0][25]/CP}]  \
  [get_pins {u0/w_reg[0][26]/CP}]  \
  [get_pins {u0/w_reg[0][27]/CP}]  \
  [get_pins {u0/w_reg[0][28]/CP}]  \
  [get_pins {u0/w_reg[0][29]/CP}]  \
  [get_pins {u0/w_reg[0][30]/CP}]  \
  [get_pins {u0/w_reg[0][31]/CP}]  \
  [get_pins {u0/w_reg[1][0]/CP}]  \
  [get_pins {u0/w_reg[1][1]/CP}]  \
  [get_pins {u0/w_reg[1][2]/CP}]  \
  [get_pins {u0/w_reg[1][3]/CP}]  \
  [get_pins {u0/w_reg[1][4]/CP}]  \
  [get_pins {u0/w_reg[1][5]/CP}]  \
  [get_pins {u0/w_reg[1][6]/CP}]  \
  [get_pins {u0/w_reg[1][7]/CP}]  \
  [get_pins {u0/w_reg[1][8]/CP}]  \
  [get_pins {u0/w_reg[1][9]/CP}]  \
  [get_pins {u0/w_reg[1][10]/CP}]  \
  [get_pins {u0/w_reg[1][11]/CP}]  \
  [get_pins {u0/w_reg[1][12]/CP}]  \
  [get_pins {u0/w_reg[1][13]/CP}]  \
  [get_pins {u0/w_reg[1][14]/CP}]  \
  [get_pins {u0/w_reg[1][15]/CP}]  \
  [get_pins {u0/w_reg[1][16]/CP}]  \
  [get_pins {u0/w_reg[1][17]/CP}]  \
  [get_pins {u0/w_reg[1][18]/CP}]  \
  [get_pins {u0/w_reg[1][19]/CP}]  \
  [get_pins {u0/w_reg[1][20]/CP}]  \
  [get_pins {u0/w_reg[1][21]/CP}]  \
  [get_pins {u0/w_reg[1][22]/CP}]  \
  [get_pins {u0/w_reg[1][23]/CP}]  \
  [get_pins {u0/w_reg[1][24]/CP}]  \
  [get_pins {u0/w_reg[1][25]/CP}]  \
  [get_pins {u0/w_reg[1][26]/CP}]  \
  [get_pins {u0/w_reg[1][27]/CP}]  \
  [get_pins {u0/w_reg[1][28]/CP}]  \
  [get_pins {u0/w_reg[1][29]/CP}]  \
  [get_pins {u0/w_reg[1][30]/CP}]  \
  [get_pins {u0/w_reg[1][31]/CP}]  \
  [get_pins {u0/w_reg[2][0]/CP}]  \
  [get_pins {u0/w_reg[2][1]/CP}]  \
  [get_pins {u0/w_reg[2][2]/CP}]  \
  [get_pins {u0/w_reg[2][3]/CP}]  \
  [get_pins {u0/w_reg[2][4]/CP}]  \
  [get_pins {u0/w_reg[2][5]/CP}]  \
  [get_pins {u0/w_reg[2][6]/CP}]  \
  [get_pins {u0/w_reg[2][7]/CP}]  \
  [get_pins {u0/w_reg[2][8]/CP}]  \
  [get_pins {u0/w_reg[2][9]/CP}]  \
  [get_pins {u0/w_reg[2][10]/CP}]  \
  [get_pins {u0/w_reg[2][11]/CP}]  \
  [get_pins {u0/w_reg[2][12]/CP}]  \
  [get_pins {u0/w_reg[2][13]/CP}]  \
  [get_pins {u0/w_reg[2][14]/CP}]  \
  [get_pins {u0/w_reg[2][15]/CP}]  \
  [get_pins {u0/w_reg[2][16]/CP}]  \
  [get_pins {u0/w_reg[2][17]/CP}]  \
  [get_pins {u0/w_reg[2][18]/CP}]  \
  [get_pins {u0/w_reg[2][19]/CP}]  \
  [get_pins {u0/w_reg[2][20]/CP}]  \
  [get_pins {u0/w_reg[2][21]/CP}]  \
  [get_pins {u0/w_reg[2][22]/CP}]  \
  [get_pins {u0/w_reg[2][23]/CP}]  \
  [get_pins {u0/w_reg[2][24]/CP}]  \
  [get_pins {u0/w_reg[2][25]/CP}]  \
  [get_pins {u0/w_reg[2][26]/CP}]  \
  [get_pins {u0/w_reg[2][27]/CP}]  \
  [get_pins {u0/w_reg[2][28]/CP}]  \
  [get_pins {u0/w_reg[2][29]/CP}]  \
  [get_pins {u0/w_reg[2][30]/CP}]  \
  [get_pins {u0/w_reg[2][31]/CP}]  \
  [get_pins {u0/w_reg[3][0]/CP}]  \
  [get_pins {u0/w_reg[3][1]/CP}]  \
  [get_pins {u0/w_reg[3][2]/CP}]  \
  [get_pins {u0/w_reg[3][3]/CP}]  \
  [get_pins {u0/w_reg[3][4]/CP}]  \
  [get_pins {u0/w_reg[3][5]/CP}]  \
  [get_pins {u0/w_reg[3][6]/CP}]  \
  [get_pins {u0/w_reg[3][7]/CP}]  \
  [get_pins {u0/w_reg[3][8]/CP}]  \
  [get_pins {u0/w_reg[3][9]/CP}]  \
  [get_pins {u0/w_reg[3][10]/CP}]  \
  [get_pins {u0/w_reg[3][11]/CP}]  \
  [get_pins {u0/w_reg[3][12]/CP}]  \
  [get_pins {u0/w_reg[3][13]/CP}]  \
  [get_pins {u0/w_reg[3][14]/CP}]  \
  [get_pins {u0/w_reg[3][15]/CP}]  \
  [get_pins {u0/w_reg[3][16]/CP}]  \
  [get_pins {u0/w_reg[3][17]/CP}]  \
  [get_pins {u0/w_reg[3][18]/CP}]  \
  [get_pins {u0/w_reg[3][19]/CP}]  \
  [get_pins {u0/w_reg[3][20]/CP}]  \
  [get_pins {u0/w_reg[3][21]/CP}]  \
  [get_pins {u0/w_reg[3][22]/CP}]  \
  [get_pins {u0/w_reg[3][23]/CP}]  \
  [get_pins {u0/w_reg[3][24]/CP}]  \
  [get_pins {u0/w_reg[3][25]/CP}]  \
  [get_pins {u0/w_reg[3][26]/CP}]  \
  [get_pins {u0/w_reg[3][27]/CP}]  \
  [get_pins {u0/w_reg[3][28]/CP}]  \
  [get_pins {u0/w_reg[3][29]/CP}]  \
  [get_pins {u0/w_reg[3][30]/CP}]  \
  [get_pins {u0/w_reg[3][31]/CP}]  \
  [get_pins done_reg/CP]  \
  [get_pins ld_r_reg/CP]  \
  [get_pins {sa00_reg[0]/CP}]  \
  [get_pins {sa00_reg[1]/CP}]  \
  [get_pins {sa00_reg[2]/CP}]  \
  [get_pins {sa00_reg[3]/CP}]  \
  [get_pins {sa00_reg[4]/CP}]  \
  [get_pins {sa00_reg[5]/CP}]  \
  [get_pins {sa00_reg[6]/CP}]  \
  [get_pins {sa00_reg[7]/CP}]  \
  [get_pins {sa01_reg[0]/CP}]  \
  [get_pins {sa01_reg[1]/CP}]  \
  [get_pins {sa01_reg[2]/CP}]  \
  [get_pins {sa01_reg[3]/CP}]  \
  [get_pins {sa01_reg[4]/CP}]  \
  [get_pins {sa01_reg[5]/CP}]  \
  [get_pins {sa01_reg[6]/CP}]  \
  [get_pins {sa01_reg[7]/CP}]  \
  [get_pins {sa02_reg[0]/CP}]  \
  [get_pins {sa02_reg[1]/CP}]  \
  [get_pins {sa02_reg[2]/CP}]  \
  [get_pins {sa02_reg[3]/CP}]  \
  [get_pins {sa02_reg[4]/CP}]  \
  [get_pins {sa02_reg[5]/CP}]  \
  [get_pins {sa02_reg[6]/CP}]  \
  [get_pins {sa02_reg[7]/CP}]  \
  [get_pins {sa03_reg[0]/CP}]  \
  [get_pins {sa03_reg[1]/CP}]  \
  [get_pins {sa03_reg[2]/CP}]  \
  [get_pins {sa03_reg[3]/CP}]  \
  [get_pins {sa03_reg[4]/CP}]  \
  [get_pins {sa03_reg[5]/CP}]  \
  [get_pins {sa03_reg[6]/CP}]  \
  [get_pins {sa03_reg[7]/CP}]  \
  [get_pins {sa10_reg[0]/CP}]  \
  [get_pins {sa10_reg[1]/CP}]  \
  [get_pins {sa10_reg[2]/CP}]  \
  [get_pins {sa10_reg[3]/CP}]  \
  [get_pins {sa10_reg[4]/CP}]  \
  [get_pins {sa10_reg[5]/CP}]  \
  [get_pins {sa10_reg[6]/CP}]  \
  [get_pins {sa10_reg[7]/CP}]  \
  [get_pins {sa11_reg[0]/CP}]  \
  [get_pins {sa11_reg[1]/CP}]  \
  [get_pins {sa11_reg[2]/CP}]  \
  [get_pins {sa11_reg[3]/CP}]  \
  [get_pins {sa11_reg[4]/CP}]  \
  [get_pins {sa11_reg[5]/CP}]  \
  [get_pins {sa11_reg[6]/CP}]  \
  [get_pins {sa11_reg[7]/CP}]  \
  [get_pins {sa12_reg[0]/CP}]  \
  [get_pins {sa12_reg[1]/CP}]  \
  [get_pins {sa12_reg[2]/CP}]  \
  [get_pins {sa12_reg[3]/CP}]  \
  [get_pins {sa12_reg[4]/CP}]  \
  [get_pins {sa12_reg[5]/CP}]  \
  [get_pins {sa12_reg[6]/CP}]  \
  [get_pins {sa12_reg[7]/CP}]  \
  [get_pins {sa13_reg[0]/CP}]  \
  [get_pins {sa13_reg[1]/CP}]  \
  [get_pins {sa13_reg[2]/CP}]  \
  [get_pins {sa13_reg[3]/CP}]  \
  [get_pins {sa13_reg[4]/CP}]  \
  [get_pins {sa13_reg[5]/CP}]  \
  [get_pins {sa13_reg[6]/CP}]  \
  [get_pins {sa13_reg[7]/CP}]  \
  [get_pins {sa20_reg[0]/CP}]  \
  [get_pins {sa20_reg[1]/CP}]  \
  [get_pins {sa20_reg[2]/CP}]  \
  [get_pins {sa20_reg[3]/CP}]  \
  [get_pins {sa20_reg[4]/CP}]  \
  [get_pins {sa20_reg[5]/CP}]  \
  [get_pins {sa20_reg[6]/CP}]  \
  [get_pins {sa20_reg[7]/CP}]  \
  [get_pins {sa21_reg[0]/CP}]  \
  [get_pins {sa21_reg[1]/CP}]  \
  [get_pins {sa21_reg[2]/CP}]  \
  [get_pins {sa21_reg[3]/CP}]  \
  [get_pins {sa21_reg[4]/CP}]  \
  [get_pins {sa21_reg[5]/CP}]  \
  [get_pins {sa21_reg[6]/CP}]  \
  [get_pins {sa21_reg[7]/CP}]  \
  [get_pins {sa22_reg[0]/CP}]  \
  [get_pins {sa22_reg[1]/CP}]  \
  [get_pins {sa22_reg[2]/CP}]  \
  [get_pins {sa22_reg[3]/CP}]  \
  [get_pins {sa22_reg[4]/CP}]  \
  [get_pins {sa22_reg[5]/CP}]  \
  [get_pins {sa22_reg[6]/CP}]  \
  [get_pins {sa22_reg[7]/CP}]  \
  [get_pins {sa23_reg[0]/CP}]  \
  [get_pins {sa23_reg[1]/CP}]  \
  [get_pins {sa23_reg[2]/CP}]  \
  [get_pins {sa23_reg[3]/CP}]  \
  [get_pins {sa23_reg[4]/CP}]  \
  [get_pins {sa23_reg[5]/CP}]  \
  [get_pins {sa23_reg[6]/CP}]  \
  [get_pins {sa23_reg[7]/CP}]  \
  [get_pins {sa30_reg[0]/CP}]  \
  [get_pins {sa30_reg[1]/CP}]  \
  [get_pins {sa30_reg[2]/CP}]  \
  [get_pins {sa30_reg[3]/CP}]  \
  [get_pins {sa30_reg[4]/CP}]  \
  [get_pins {sa30_reg[5]/CP}]  \
  [get_pins {sa30_reg[6]/CP}]  \
  [get_pins {sa30_reg[7]/CP}]  \
  [get_pins {sa31_reg[0]/CP}]  \
  [get_pins {sa31_reg[1]/CP}]  \
  [get_pins {sa31_reg[2]/CP}]  \
  [get_pins {sa31_reg[3]/CP}]  \
  [get_pins {sa31_reg[4]/CP}]  \
  [get_pins {sa31_reg[5]/CP}]  \
  [get_pins {sa31_reg[6]/CP}]  \
  [get_pins {sa31_reg[7]/CP}]  \
  [get_pins {sa32_reg[0]/CP}]  \
  [get_pins {sa32_reg[1]/CP}]  \
  [get_pins {sa32_reg[2]/CP}]  \
  [get_pins {sa32_reg[3]/CP}]  \
  [get_pins {sa32_reg[4]/CP}]  \
  [get_pins {sa32_reg[5]/CP}]  \
  [get_pins {sa32_reg[6]/CP}]  \
  [get_pins {sa32_reg[7]/CP}]  \
  [get_pins {sa33_reg[0]/CP}]  \
  [get_pins {sa33_reg[1]/CP}]  \
  [get_pins {sa33_reg[2]/CP}]  \
  [get_pins {sa33_reg[3]/CP}]  \
  [get_pins {sa33_reg[4]/CP}]  \
  [get_pins {sa33_reg[5]/CP}]  \
  [get_pins {sa33_reg[6]/CP}]  \
  [get_pins {sa33_reg[7]/CP}]  \
  [get_pins {text_in_r_reg[0]/CP}]  \
  [get_pins {text_in_r_reg[1]/CP}]  \
  [get_pins {text_in_r_reg[2]/CP}]  \
  [get_pins {text_in_r_reg[3]/CP}]  \
  [get_pins {text_in_r_reg[4]/CP}]  \
  [get_pins {text_in_r_reg[5]/CP}]  \
  [get_pins {text_in_r_reg[6]/CP}]  \
  [get_pins {text_in_r_reg[7]/CP}]  \
  [get_pins {text_in_r_reg[8]/CP}]  \
  [get_pins {text_in_r_reg[9]/CP}]  \
  [get_pins {text_in_r_reg[10]/CP}]  \
  [get_pins {text_in_r_reg[11]/CP}]  \
  [get_pins {text_in_r_reg[12]/CP}]  \
  [get_pins {text_in_r_reg[13]/CP}]  \
  [get_pins {text_in_r_reg[14]/CP}]  \
  [get_pins {text_in_r_reg[15]/CP}]  \
  [get_pins {text_in_r_reg[16]/CP}]  \
  [get_pins {text_in_r_reg[17]/CP}]  \
  [get_pins {text_in_r_reg[18]/CP}]  \
  [get_pins {text_in_r_reg[19]/CP}]  \
  [get_pins {text_in_r_reg[20]/CP}]  \
  [get_pins {text_in_r_reg[21]/CP}]  \
  [get_pins {text_in_r_reg[22]/CP}]  \
  [get_pins {text_in_r_reg[23]/CP}]  \
  [get_pins {text_in_r_reg[24]/CP}]  \
  [get_pins {text_in_r_reg[25]/CP}]  \
  [get_pins {text_in_r_reg[26]/CP}]  \
  [get_pins {text_in_r_reg[27]/CP}]  \
  [get_pins {text_in_r_reg[28]/CP}]  \
  [get_pins {text_in_r_reg[29]/CP}]  \
  [get_pins {text_in_r_reg[30]/CP}]  \
  [get_pins {text_in_r_reg[31]/CP}]  \
  [get_pins {text_in_r_reg[32]/CP}]  \
  [get_pins {text_in_r_reg[33]/CP}]  \
  [get_pins {text_in_r_reg[34]/CP}]  \
  [get_pins {text_in_r_reg[35]/CP}]  \
  [get_pins {text_in_r_reg[36]/CP}]  \
  [get_pins {text_in_r_reg[37]/CP}]  \
  [get_pins {text_in_r_reg[38]/CP}]  \
  [get_pins {text_in_r_reg[39]/CP}]  \
  [get_pins {text_in_r_reg[40]/CP}]  \
  [get_pins {text_in_r_reg[41]/CP}]  \
  [get_pins {text_in_r_reg[42]/CP}]  \
  [get_pins {text_in_r_reg[43]/CP}]  \
  [get_pins {text_in_r_reg[44]/CP}]  \
  [get_pins {text_in_r_reg[45]/CP}]  \
  [get_pins {text_in_r_reg[46]/CP}]  \
  [get_pins {text_in_r_reg[47]/CP}]  \
  [get_pins {text_in_r_reg[48]/CP}]  \
  [get_pins {text_in_r_reg[49]/CP}]  \
  [get_pins {text_in_r_reg[50]/CP}]  \
  [get_pins {text_in_r_reg[51]/CP}]  \
  [get_pins {text_in_r_reg[52]/CP}]  \
  [get_pins {text_in_r_reg[53]/CP}]  \
  [get_pins {text_in_r_reg[54]/CP}]  \
  [get_pins {text_in_r_reg[55]/CP}]  \
  [get_pins {text_in_r_reg[56]/CP}]  \
  [get_pins {text_in_r_reg[57]/CP}]  \
  [get_pins {text_in_r_reg[58]/CP}]  \
  [get_pins {text_in_r_reg[59]/CP}]  \
  [get_pins {text_in_r_reg[60]/CP}]  \
  [get_pins {text_in_r_reg[61]/CP}]  \
  [get_pins {text_in_r_reg[62]/CP}]  \
  [get_pins {text_in_r_reg[63]/CP}]  \
  [get_pins {text_in_r_reg[64]/CP}]  \
  [get_pins {text_in_r_reg[65]/CP}]  \
  [get_pins {text_in_r_reg[66]/CP}]  \
  [get_pins {text_in_r_reg[67]/CP}]  \
  [get_pins {text_in_r_reg[68]/CP}]  \
  [get_pins {text_in_r_reg[69]/CP}]  \
  [get_pins {text_in_r_reg[70]/CP}]  \
  [get_pins {text_in_r_reg[71]/CP}]  \
  [get_pins {text_in_r_reg[72]/CP}]  \
  [get_pins {text_in_r_reg[73]/CP}]  \
  [get_pins {text_in_r_reg[74]/CP}]  \
  [get_pins {text_in_r_reg[75]/CP}]  \
  [get_pins {text_in_r_reg[76]/CP}]  \
  [get_pins {text_in_r_reg[77]/CP}]  \
  [get_pins {text_in_r_reg[78]/CP}]  \
  [get_pins {text_in_r_reg[79]/CP}]  \
  [get_pins {text_in_r_reg[80]/CP}]  \
  [get_pins {text_in_r_reg[81]/CP}]  \
  [get_pins {text_in_r_reg[82]/CP}]  \
  [get_pins {text_in_r_reg[83]/CP}]  \
  [get_pins {text_in_r_reg[84]/CP}]  \
  [get_pins {text_in_r_reg[85]/CP}]  \
  [get_pins {text_in_r_reg[86]/CP}]  \
  [get_pins {text_in_r_reg[87]/CP}]  \
  [get_pins {text_in_r_reg[88]/CP}]  \
  [get_pins {text_in_r_reg[89]/CP}]  \
  [get_pins {text_in_r_reg[90]/CP}]  \
  [get_pins {text_in_r_reg[91]/CP}]  \
  [get_pins {text_in_r_reg[92]/CP}]  \
  [get_pins {text_in_r_reg[93]/CP}]  \
  [get_pins {text_in_r_reg[94]/CP}]  \
  [get_pins {text_in_r_reg[95]/CP}]  \
  [get_pins {text_in_r_reg[96]/CP}]  \
  [get_pins {text_in_r_reg[97]/CP}]  \
  [get_pins {text_in_r_reg[98]/CP}]  \
  [get_pins {text_in_r_reg[99]/CP}]  \
  [get_pins {text_in_r_reg[100]/CP}]  \
  [get_pins {text_in_r_reg[101]/CP}]  \
  [get_pins {text_in_r_reg[102]/CP}]  \
  [get_pins {text_in_r_reg[103]/CP}]  \
  [get_pins {text_in_r_reg[104]/CP}]  \
  [get_pins {text_in_r_reg[105]/CP}]  \
  [get_pins {text_in_r_reg[106]/CP}]  \
  [get_pins {text_in_r_reg[107]/CP}]  \
  [get_pins {text_in_r_reg[108]/CP}]  \
  [get_pins {text_in_r_reg[109]/CP}]  \
  [get_pins {text_in_r_reg[110]/CP}]  \
  [get_pins {text_in_r_reg[111]/CP}]  \
  [get_pins {text_in_r_reg[112]/CP}]  \
  [get_pins {text_in_r_reg[113]/CP}]  \
  [get_pins {text_in_r_reg[114]/CP}]  \
  [get_pins {text_in_r_reg[115]/CP}]  \
  [get_pins {text_in_r_reg[116]/CP}]  \
  [get_pins {text_in_r_reg[117]/CP}]  \
  [get_pins {text_in_r_reg[118]/CP}]  \
  [get_pins {text_in_r_reg[119]/CP}]  \
  [get_pins {text_in_r_reg[120]/CP}]  \
  [get_pins {text_in_r_reg[121]/CP}]  \
  [get_pins {text_in_r_reg[122]/CP}]  \
  [get_pins {text_in_r_reg[123]/CP}]  \
  [get_pins {text_in_r_reg[124]/CP}]  \
  [get_pins {text_in_r_reg[125]/CP}]  \
  [get_pins {text_in_r_reg[126]/CP}]  \
  [get_pins {text_in_r_reg[127]/CP}]  \
  [get_pins {text_out_reg[0]/CP}]  \
  [get_pins {text_out_reg[1]/CP}]  \
  [get_pins {text_out_reg[2]/CP}]  \
  [get_pins {text_out_reg[3]/CP}]  \
  [get_pins {text_out_reg[4]/CP}]  \
  [get_pins {text_out_reg[5]/CP}]  \
  [get_pins {text_out_reg[6]/CP}]  \
  [get_pins {text_out_reg[7]/CP}]  \
  [get_pins {text_out_reg[8]/CP}]  \
  [get_pins {text_out_reg[9]/CP}]  \
  [get_pins {text_out_reg[10]/CP}]  \
  [get_pins {text_out_reg[11]/CP}]  \
  [get_pins {text_out_reg[12]/CP}]  \
  [get_pins {text_out_reg[13]/CP}]  \
  [get_pins {text_out_reg[14]/CP}]  \
  [get_pins {text_out_reg[15]/CP}]  \
  [get_pins {text_out_reg[16]/CP}]  \
  [get_pins {text_out_reg[17]/CP}]  \
  [get_pins {text_out_reg[18]/CP}]  \
  [get_pins {text_out_reg[19]/CP}]  \
  [get_pins {text_out_reg[20]/CP}]  \
  [get_pins {text_out_reg[21]/CP}]  \
  [get_pins {text_out_reg[22]/CP}]  \
  [get_pins {text_out_reg[23]/CP}]  \
  [get_pins {text_out_reg[24]/CP}]  \
  [get_pins {text_out_reg[25]/CP}]  \
  [get_pins {text_out_reg[26]/CP}]  \
  [get_pins {text_out_reg[27]/CP}]  \
  [get_pins {text_out_reg[28]/CP}]  \
  [get_pins {text_out_reg[29]/CP}]  \
  [get_pins {text_out_reg[30]/CP}]  \
  [get_pins {text_out_reg[31]/CP}]  \
  [get_pins {text_out_reg[32]/CP}]  \
  [get_pins {text_out_reg[33]/CP}]  \
  [get_pins {text_out_reg[34]/CP}]  \
  [get_pins {text_out_reg[35]/CP}]  \
  [get_pins {text_out_reg[36]/CP}]  \
  [get_pins {text_out_reg[37]/CP}]  \
  [get_pins {text_out_reg[38]/CP}]  \
  [get_pins {text_out_reg[39]/CP}]  \
  [get_pins {text_out_reg[40]/CP}]  \
  [get_pins {text_out_reg[41]/CP}]  \
  [get_pins {text_out_reg[42]/CP}]  \
  [get_pins {text_out_reg[43]/CP}]  \
  [get_pins {text_out_reg[44]/CP}]  \
  [get_pins {text_out_reg[45]/CP}]  \
  [get_pins {text_out_reg[46]/CP}]  \
  [get_pins {text_out_reg[47]/CP}]  \
  [get_pins {text_out_reg[48]/CP}]  \
  [get_pins {text_out_reg[49]/CP}]  \
  [get_pins {text_out_reg[50]/CP}]  \
  [get_pins {text_out_reg[51]/CP}]  \
  [get_pins {text_out_reg[52]/CP}]  \
  [get_pins {text_out_reg[53]/CP}]  \
  [get_pins {text_out_reg[54]/CP}]  \
  [get_pins {text_out_reg[55]/CP}]  \
  [get_pins {text_out_reg[56]/CP}]  \
  [get_pins {text_out_reg[57]/CP}]  \
  [get_pins {text_out_reg[58]/CP}]  \
  [get_pins {text_out_reg[59]/CP}]  \
  [get_pins {text_out_reg[60]/CP}]  \
  [get_pins {text_out_reg[61]/CP}]  \
  [get_pins {text_out_reg[62]/CP}]  \
  [get_pins {text_out_reg[63]/CP}]  \
  [get_pins {text_out_reg[64]/CP}]  \
  [get_pins {text_out_reg[65]/CP}]  \
  [get_pins {text_out_reg[66]/CP}]  \
  [get_pins {text_out_reg[67]/CP}]  \
  [get_pins {text_out_reg[68]/CP}]  \
  [get_pins {text_out_reg[69]/CP}]  \
  [get_pins {text_out_reg[70]/CP}]  \
  [get_pins {text_out_reg[71]/CP}]  \
  [get_pins {text_out_reg[72]/CP}]  \
  [get_pins {text_out_reg[73]/CP}]  \
  [get_pins {text_out_reg[74]/CP}]  \
  [get_pins {text_out_reg[75]/CP}]  \
  [get_pins {text_out_reg[76]/CP}]  \
  [get_pins {text_out_reg[77]/CP}]  \
  [get_pins {text_out_reg[78]/CP}]  \
  [get_pins {text_out_reg[79]/CP}]  \
  [get_pins {text_out_reg[80]/CP}]  \
  [get_pins {text_out_reg[81]/CP}]  \
  [get_pins {text_out_reg[82]/CP}]  \
  [get_pins {text_out_reg[83]/CP}]  \
  [get_pins {text_out_reg[84]/CP}]  \
  [get_pins {text_out_reg[85]/CP}]  \
  [get_pins {text_out_reg[86]/CP}]  \
  [get_pins {text_out_reg[87]/CP}]  \
  [get_pins {text_out_reg[88]/CP}]  \
  [get_pins {text_out_reg[89]/CP}]  \
  [get_pins {text_out_reg[90]/CP}]  \
  [get_pins {text_out_reg[91]/CP}]  \
  [get_pins {text_out_reg[92]/CP}]  \
  [get_pins {text_out_reg[93]/CP}]  \
  [get_pins {text_out_reg[94]/CP}]  \
  [get_pins {text_out_reg[95]/CP}]  \
  [get_pins {text_out_reg[96]/CP}]  \
  [get_pins {text_out_reg[97]/CP}]  \
  [get_pins {text_out_reg[98]/CP}]  \
  [get_pins {text_out_reg[99]/CP}]  \
  [get_pins {text_out_reg[100]/CP}]  \
  [get_pins {text_out_reg[101]/CP}]  \
  [get_pins {text_out_reg[102]/CP}]  \
  [get_pins {text_out_reg[103]/CP}]  \
  [get_pins {text_out_reg[104]/CP}]  \
  [get_pins {text_out_reg[105]/CP}]  \
  [get_pins {text_out_reg[106]/CP}]  \
  [get_pins {text_out_reg[107]/CP}]  \
  [get_pins {text_out_reg[108]/CP}]  \
  [get_pins {text_out_reg[109]/CP}]  \
  [get_pins {text_out_reg[110]/CP}]  \
  [get_pins {text_out_reg[111]/CP}]  \
  [get_pins {text_out_reg[112]/CP}]  \
  [get_pins {text_out_reg[113]/CP}]  \
  [get_pins {text_out_reg[114]/CP}]  \
  [get_pins {text_out_reg[115]/CP}]  \
  [get_pins {text_out_reg[116]/CP}]  \
  [get_pins {text_out_reg[117]/CP}]  \
  [get_pins {text_out_reg[118]/CP}]  \
  [get_pins {text_out_reg[119]/CP}]  \
  [get_pins {text_out_reg[120]/CP}]  \
  [get_pins {text_out_reg[121]/CP}]  \
  [get_pins {text_out_reg[122]/CP}]  \
  [get_pins {text_out_reg[123]/CP}]  \
  [get_pins {text_out_reg[124]/CP}]  \
  [get_pins {text_out_reg[125]/CP}]  \
  [get_pins {text_out_reg[126]/CP}]  \
  [get_pins {text_out_reg[127]/CP}]  \
  [get_pins {dcnt_reg[2]/CP}]  \
  [get_pins {dcnt_reg[3]/CP}]  \
  [get_pins {dcnt_reg[1]/CP}]  \
  [get_pins {dcnt_reg[0]/CP}] ] -to [list \
  [get_ports done]  \
  [get_ports {text_out[127]}]  \
  [get_ports {text_out[126]}]  \
  [get_ports {text_out[125]}]  \
  [get_ports {text_out[124]}]  \
  [get_ports {text_out[123]}]  \
  [get_ports {text_out[122]}]  \
  [get_ports {text_out[121]}]  \
  [get_ports {text_out[120]}]  \
  [get_ports {text_out[119]}]  \
  [get_ports {text_out[118]}]  \
  [get_ports {text_out[117]}]  \
  [get_ports {text_out[116]}]  \
  [get_ports {text_out[115]}]  \
  [get_ports {text_out[114]}]  \
  [get_ports {text_out[113]}]  \
  [get_ports {text_out[112]}]  \
  [get_ports {text_out[111]}]  \
  [get_ports {text_out[110]}]  \
  [get_ports {text_out[109]}]  \
  [get_ports {text_out[108]}]  \
  [get_ports {text_out[107]}]  \
  [get_ports {text_out[106]}]  \
  [get_ports {text_out[105]}]  \
  [get_ports {text_out[104]}]  \
  [get_ports {text_out[103]}]  \
  [get_ports {text_out[102]}]  \
  [get_ports {text_out[101]}]  \
  [get_ports {text_out[100]}]  \
  [get_ports {text_out[99]}]  \
  [get_ports {text_out[98]}]  \
  [get_ports {text_out[97]}]  \
  [get_ports {text_out[96]}]  \
  [get_ports {text_out[95]}]  \
  [get_ports {text_out[94]}]  \
  [get_ports {text_out[93]}]  \
  [get_ports {text_out[92]}]  \
  [get_ports {text_out[91]}]  \
  [get_ports {text_out[90]}]  \
  [get_ports {text_out[89]}]  \
  [get_ports {text_out[88]}]  \
  [get_ports {text_out[87]}]  \
  [get_ports {text_out[86]}]  \
  [get_ports {text_out[85]}]  \
  [get_ports {text_out[84]}]  \
  [get_ports {text_out[83]}]  \
  [get_ports {text_out[82]}]  \
  [get_ports {text_out[81]}]  \
  [get_ports {text_out[80]}]  \
  [get_ports {text_out[79]}]  \
  [get_ports {text_out[78]}]  \
  [get_ports {text_out[77]}]  \
  [get_ports {text_out[76]}]  \
  [get_ports {text_out[75]}]  \
  [get_ports {text_out[74]}]  \
  [get_ports {text_out[73]}]  \
  [get_ports {text_out[72]}]  \
  [get_ports {text_out[71]}]  \
  [get_ports {text_out[70]}]  \
  [get_ports {text_out[69]}]  \
  [get_ports {text_out[68]}]  \
  [get_ports {text_out[67]}]  \
  [get_ports {text_out[66]}]  \
  [get_ports {text_out[65]}]  \
  [get_ports {text_out[64]}]  \
  [get_ports {text_out[63]}]  \
  [get_ports {text_out[62]}]  \
  [get_ports {text_out[61]}]  \
  [get_ports {text_out[60]}]  \
  [get_ports {text_out[59]}]  \
  [get_ports {text_out[58]}]  \
  [get_ports {text_out[57]}]  \
  [get_ports {text_out[56]}]  \
  [get_ports {text_out[55]}]  \
  [get_ports {text_out[54]}]  \
  [get_ports {text_out[53]}]  \
  [get_ports {text_out[52]}]  \
  [get_ports {text_out[51]}]  \
  [get_ports {text_out[50]}]  \
  [get_ports {text_out[49]}]  \
  [get_ports {text_out[48]}]  \
  [get_ports {text_out[47]}]  \
  [get_ports {text_out[46]}]  \
  [get_ports {text_out[45]}]  \
  [get_ports {text_out[44]}]  \
  [get_ports {text_out[43]}]  \
  [get_ports {text_out[42]}]  \
  [get_ports {text_out[41]}]  \
  [get_ports {text_out[40]}]  \
  [get_ports {text_out[39]}]  \
  [get_ports {text_out[38]}]  \
  [get_ports {text_out[37]}]  \
  [get_ports {text_out[36]}]  \
  [get_ports {text_out[35]}]  \
  [get_ports {text_out[34]}]  \
  [get_ports {text_out[33]}]  \
  [get_ports {text_out[32]}]  \
  [get_ports {text_out[31]}]  \
  [get_ports {text_out[30]}]  \
  [get_ports {text_out[29]}]  \
  [get_ports {text_out[28]}]  \
  [get_ports {text_out[27]}]  \
  [get_ports {text_out[26]}]  \
  [get_ports {text_out[25]}]  \
  [get_ports {text_out[24]}]  \
  [get_ports {text_out[23]}]  \
  [get_ports {text_out[22]}]  \
  [get_ports {text_out[21]}]  \
  [get_ports {text_out[20]}]  \
  [get_ports {text_out[19]}]  \
  [get_ports {text_out[18]}]  \
  [get_ports {text_out[17]}]  \
  [get_ports {text_out[16]}]  \
  [get_ports {text_out[15]}]  \
  [get_ports {text_out[14]}]  \
  [get_ports {text_out[13]}]  \
  [get_ports {text_out[12]}]  \
  [get_ports {text_out[11]}]  \
  [get_ports {text_out[10]}]  \
  [get_ports {text_out[9]}]  \
  [get_ports {text_out[8]}]  \
  [get_ports {text_out[7]}]  \
  [get_ports {text_out[6]}]  \
  [get_ports {text_out[5]}]  \
  [get_ports {text_out[4]}]  \
  [get_ports {text_out[3]}]  \
  [get_ports {text_out[2]}]  \
  [get_ports {text_out[1]}]  \
  [get_ports {text_out[0]}] ]
group_path -weight 1.000000 -name in2out -from [list \
  [get_ports rst]  \
  [get_ports ld]  \
  [get_ports {key[127]}]  \
  [get_ports {key[126]}]  \
  [get_ports {key[125]}]  \
  [get_ports {key[124]}]  \
  [get_ports {key[123]}]  \
  [get_ports {key[122]}]  \
  [get_ports {key[121]}]  \
  [get_ports {key[120]}]  \
  [get_ports {key[119]}]  \
  [get_ports {key[118]}]  \
  [get_ports {key[117]}]  \
  [get_ports {key[116]}]  \
  [get_ports {key[115]}]  \
  [get_ports {key[114]}]  \
  [get_ports {key[113]}]  \
  [get_ports {key[112]}]  \
  [get_ports {key[111]}]  \
  [get_ports {key[110]}]  \
  [get_ports {key[109]}]  \
  [get_ports {key[108]}]  \
  [get_ports {key[107]}]  \
  [get_ports {key[106]}]  \
  [get_ports {key[105]}]  \
  [get_ports {key[104]}]  \
  [get_ports {key[103]}]  \
  [get_ports {key[102]}]  \
  [get_ports {key[101]}]  \
  [get_ports {key[100]}]  \
  [get_ports {key[99]}]  \
  [get_ports {key[98]}]  \
  [get_ports {key[97]}]  \
  [get_ports {key[96]}]  \
  [get_ports {key[95]}]  \
  [get_ports {key[94]}]  \
  [get_ports {key[93]}]  \
  [get_ports {key[92]}]  \
  [get_ports {key[91]}]  \
  [get_ports {key[90]}]  \
  [get_ports {key[89]}]  \
  [get_ports {key[88]}]  \
  [get_ports {key[87]}]  \
  [get_ports {key[86]}]  \
  [get_ports {key[85]}]  \
  [get_ports {key[84]}]  \
  [get_ports {key[83]}]  \
  [get_ports {key[82]}]  \
  [get_ports {key[81]}]  \
  [get_ports {key[80]}]  \
  [get_ports {key[79]}]  \
  [get_ports {key[78]}]  \
  [get_ports {key[77]}]  \
  [get_ports {key[76]}]  \
  [get_ports {key[75]}]  \
  [get_ports {key[74]}]  \
  [get_ports {key[73]}]  \
  [get_ports {key[72]}]  \
  [get_ports {key[71]}]  \
  [get_ports {key[70]}]  \
  [get_ports {key[69]}]  \
  [get_ports {key[68]}]  \
  [get_ports {key[67]}]  \
  [get_ports {key[66]}]  \
  [get_ports {key[65]}]  \
  [get_ports {key[64]}]  \
  [get_ports {key[63]}]  \
  [get_ports {key[62]}]  \
  [get_ports {key[61]}]  \
  [get_ports {key[60]}]  \
  [get_ports {key[59]}]  \
  [get_ports {key[58]}]  \
  [get_ports {key[57]}]  \
  [get_ports {key[56]}]  \
  [get_ports {key[55]}]  \
  [get_ports {key[54]}]  \
  [get_ports {key[53]}]  \
  [get_ports {key[52]}]  \
  [get_ports {key[51]}]  \
  [get_ports {key[50]}]  \
  [get_ports {key[49]}]  \
  [get_ports {key[48]}]  \
  [get_ports {key[47]}]  \
  [get_ports {key[46]}]  \
  [get_ports {key[45]}]  \
  [get_ports {key[44]}]  \
  [get_ports {key[43]}]  \
  [get_ports {key[42]}]  \
  [get_ports {key[41]}]  \
  [get_ports {key[40]}]  \
  [get_ports {key[39]}]  \
  [get_ports {key[38]}]  \
  [get_ports {key[37]}]  \
  [get_ports {key[36]}]  \
  [get_ports {key[35]}]  \
  [get_ports {key[34]}]  \
  [get_ports {key[33]}]  \
  [get_ports {key[32]}]  \
  [get_ports {key[31]}]  \
  [get_ports {key[30]}]  \
  [get_ports {key[29]}]  \
  [get_ports {key[28]}]  \
  [get_ports {key[27]}]  \
  [get_ports {key[26]}]  \
  [get_ports {key[25]}]  \
  [get_ports {key[24]}]  \
  [get_ports {key[23]}]  \
  [get_ports {key[22]}]  \
  [get_ports {key[21]}]  \
  [get_ports {key[20]}]  \
  [get_ports {key[19]}]  \
  [get_ports {key[18]}]  \
  [get_ports {key[17]}]  \
  [get_ports {key[16]}]  \
  [get_ports {key[15]}]  \
  [get_ports {key[14]}]  \
  [get_ports {key[13]}]  \
  [get_ports {key[12]}]  \
  [get_ports {key[11]}]  \
  [get_ports {key[10]}]  \
  [get_ports {key[9]}]  \
  [get_ports {key[8]}]  \
  [get_ports {key[7]}]  \
  [get_ports {key[6]}]  \
  [get_ports {key[5]}]  \
  [get_ports {key[4]}]  \
  [get_ports {key[3]}]  \
  [get_ports {key[2]}]  \
  [get_ports {key[1]}]  \
  [get_ports {key[0]}]  \
  [get_ports {text_in[127]}]  \
  [get_ports {text_in[126]}]  \
  [get_ports {text_in[125]}]  \
  [get_ports {text_in[124]}]  \
  [get_ports {text_in[123]}]  \
  [get_ports {text_in[122]}]  \
  [get_ports {text_in[121]}]  \
  [get_ports {text_in[120]}]  \
  [get_ports {text_in[119]}]  \
  [get_ports {text_in[118]}]  \
  [get_ports {text_in[117]}]  \
  [get_ports {text_in[116]}]  \
  [get_ports {text_in[115]}]  \
  [get_ports {text_in[114]}]  \
  [get_ports {text_in[113]}]  \
  [get_ports {text_in[112]}]  \
  [get_ports {text_in[111]}]  \
  [get_ports {text_in[110]}]  \
  [get_ports {text_in[109]}]  \
  [get_ports {text_in[108]}]  \
  [get_ports {text_in[107]}]  \
  [get_ports {text_in[106]}]  \
  [get_ports {text_in[105]}]  \
  [get_ports {text_in[104]}]  \
  [get_ports {text_in[103]}]  \
  [get_ports {text_in[102]}]  \
  [get_ports {text_in[101]}]  \
  [get_ports {text_in[100]}]  \
  [get_ports {text_in[99]}]  \
  [get_ports {text_in[98]}]  \
  [get_ports {text_in[97]}]  \
  [get_ports {text_in[96]}]  \
  [get_ports {text_in[95]}]  \
  [get_ports {text_in[94]}]  \
  [get_ports {text_in[93]}]  \
  [get_ports {text_in[92]}]  \
  [get_ports {text_in[91]}]  \
  [get_ports {text_in[90]}]  \
  [get_ports {text_in[89]}]  \
  [get_ports {text_in[88]}]  \
  [get_ports {text_in[87]}]  \
  [get_ports {text_in[86]}]  \
  [get_ports {text_in[85]}]  \
  [get_ports {text_in[84]}]  \
  [get_ports {text_in[83]}]  \
  [get_ports {text_in[82]}]  \
  [get_ports {text_in[81]}]  \
  [get_ports {text_in[80]}]  \
  [get_ports {text_in[79]}]  \
  [get_ports {text_in[78]}]  \
  [get_ports {text_in[77]}]  \
  [get_ports {text_in[76]}]  \
  [get_ports {text_in[75]}]  \
  [get_ports {text_in[74]}]  \
  [get_ports {text_in[73]}]  \
  [get_ports {text_in[72]}]  \
  [get_ports {text_in[71]}]  \
  [get_ports {text_in[70]}]  \
  [get_ports {text_in[69]}]  \
  [get_ports {text_in[68]}]  \
  [get_ports {text_in[67]}]  \
  [get_ports {text_in[66]}]  \
  [get_ports {text_in[65]}]  \
  [get_ports {text_in[64]}]  \
  [get_ports {text_in[63]}]  \
  [get_ports {text_in[62]}]  \
  [get_ports {text_in[61]}]  \
  [get_ports {text_in[60]}]  \
  [get_ports {text_in[59]}]  \
  [get_ports {text_in[58]}]  \
  [get_ports {text_in[57]}]  \
  [get_ports {text_in[56]}]  \
  [get_ports {text_in[55]}]  \
  [get_ports {text_in[54]}]  \
  [get_ports {text_in[53]}]  \
  [get_ports {text_in[52]}]  \
  [get_ports {text_in[51]}]  \
  [get_ports {text_in[50]}]  \
  [get_ports {text_in[49]}]  \
  [get_ports {text_in[48]}]  \
  [get_ports {text_in[47]}]  \
  [get_ports {text_in[46]}]  \
  [get_ports {text_in[45]}]  \
  [get_ports {text_in[44]}]  \
  [get_ports {text_in[43]}]  \
  [get_ports {text_in[42]}]  \
  [get_ports {text_in[41]}]  \
  [get_ports {text_in[40]}]  \
  [get_ports {text_in[39]}]  \
  [get_ports {text_in[38]}]  \
  [get_ports {text_in[37]}]  \
  [get_ports {text_in[36]}]  \
  [get_ports {text_in[35]}]  \
  [get_ports {text_in[34]}]  \
  [get_ports {text_in[33]}]  \
  [get_ports {text_in[32]}]  \
  [get_ports {text_in[31]}]  \
  [get_ports {text_in[30]}]  \
  [get_ports {text_in[29]}]  \
  [get_ports {text_in[28]}]  \
  [get_ports {text_in[27]}]  \
  [get_ports {text_in[26]}]  \
  [get_ports {text_in[25]}]  \
  [get_ports {text_in[24]}]  \
  [get_ports {text_in[23]}]  \
  [get_ports {text_in[22]}]  \
  [get_ports {text_in[21]}]  \
  [get_ports {text_in[20]}]  \
  [get_ports {text_in[19]}]  \
  [get_ports {text_in[18]}]  \
  [get_ports {text_in[17]}]  \
  [get_ports {text_in[16]}]  \
  [get_ports {text_in[15]}]  \
  [get_ports {text_in[14]}]  \
  [get_ports {text_in[13]}]  \
  [get_ports {text_in[12]}]  \
  [get_ports {text_in[11]}]  \
  [get_ports {text_in[10]}]  \
  [get_ports {text_in[9]}]  \
  [get_ports {text_in[8]}]  \
  [get_ports {text_in[7]}]  \
  [get_ports {text_in[6]}]  \
  [get_ports {text_in[5]}]  \
  [get_ports {text_in[4]}]  \
  [get_ports {text_in[3]}]  \
  [get_ports {text_in[2]}]  \
  [get_ports {text_in[1]}]  \
  [get_ports {text_in[0]}] ] -to [list \
  [get_ports done]  \
  [get_ports {text_out[127]}]  \
  [get_ports {text_out[126]}]  \
  [get_ports {text_out[125]}]  \
  [get_ports {text_out[124]}]  \
  [get_ports {text_out[123]}]  \
  [get_ports {text_out[122]}]  \
  [get_ports {text_out[121]}]  \
  [get_ports {text_out[120]}]  \
  [get_ports {text_out[119]}]  \
  [get_ports {text_out[118]}]  \
  [get_ports {text_out[117]}]  \
  [get_ports {text_out[116]}]  \
  [get_ports {text_out[115]}]  \
  [get_ports {text_out[114]}]  \
  [get_ports {text_out[113]}]  \
  [get_ports {text_out[112]}]  \
  [get_ports {text_out[111]}]  \
  [get_ports {text_out[110]}]  \
  [get_ports {text_out[109]}]  \
  [get_ports {text_out[108]}]  \
  [get_ports {text_out[107]}]  \
  [get_ports {text_out[106]}]  \
  [get_ports {text_out[105]}]  \
  [get_ports {text_out[104]}]  \
  [get_ports {text_out[103]}]  \
  [get_ports {text_out[102]}]  \
  [get_ports {text_out[101]}]  \
  [get_ports {text_out[100]}]  \
  [get_ports {text_out[99]}]  \
  [get_ports {text_out[98]}]  \
  [get_ports {text_out[97]}]  \
  [get_ports {text_out[96]}]  \
  [get_ports {text_out[95]}]  \
  [get_ports {text_out[94]}]  \
  [get_ports {text_out[93]}]  \
  [get_ports {text_out[92]}]  \
  [get_ports {text_out[91]}]  \
  [get_ports {text_out[90]}]  \
  [get_ports {text_out[89]}]  \
  [get_ports {text_out[88]}]  \
  [get_ports {text_out[87]}]  \
  [get_ports {text_out[86]}]  \
  [get_ports {text_out[85]}]  \
  [get_ports {text_out[84]}]  \
  [get_ports {text_out[83]}]  \
  [get_ports {text_out[82]}]  \
  [get_ports {text_out[81]}]  \
  [get_ports {text_out[80]}]  \
  [get_ports {text_out[79]}]  \
  [get_ports {text_out[78]}]  \
  [get_ports {text_out[77]}]  \
  [get_ports {text_out[76]}]  \
  [get_ports {text_out[75]}]  \
  [get_ports {text_out[74]}]  \
  [get_ports {text_out[73]}]  \
  [get_ports {text_out[72]}]  \
  [get_ports {text_out[71]}]  \
  [get_ports {text_out[70]}]  \
  [get_ports {text_out[69]}]  \
  [get_ports {text_out[68]}]  \
  [get_ports {text_out[67]}]  \
  [get_ports {text_out[66]}]  \
  [get_ports {text_out[65]}]  \
  [get_ports {text_out[64]}]  \
  [get_ports {text_out[63]}]  \
  [get_ports {text_out[62]}]  \
  [get_ports {text_out[61]}]  \
  [get_ports {text_out[60]}]  \
  [get_ports {text_out[59]}]  \
  [get_ports {text_out[58]}]  \
  [get_ports {text_out[57]}]  \
  [get_ports {text_out[56]}]  \
  [get_ports {text_out[55]}]  \
  [get_ports {text_out[54]}]  \
  [get_ports {text_out[53]}]  \
  [get_ports {text_out[52]}]  \
  [get_ports {text_out[51]}]  \
  [get_ports {text_out[50]}]  \
  [get_ports {text_out[49]}]  \
  [get_ports {text_out[48]}]  \
  [get_ports {text_out[47]}]  \
  [get_ports {text_out[46]}]  \
  [get_ports {text_out[45]}]  \
  [get_ports {text_out[44]}]  \
  [get_ports {text_out[43]}]  \
  [get_ports {text_out[42]}]  \
  [get_ports {text_out[41]}]  \
  [get_ports {text_out[40]}]  \
  [get_ports {text_out[39]}]  \
  [get_ports {text_out[38]}]  \
  [get_ports {text_out[37]}]  \
  [get_ports {text_out[36]}]  \
  [get_ports {text_out[35]}]  \
  [get_ports {text_out[34]}]  \
  [get_ports {text_out[33]}]  \
  [get_ports {text_out[32]}]  \
  [get_ports {text_out[31]}]  \
  [get_ports {text_out[30]}]  \
  [get_ports {text_out[29]}]  \
  [get_ports {text_out[28]}]  \
  [get_ports {text_out[27]}]  \
  [get_ports {text_out[26]}]  \
  [get_ports {text_out[25]}]  \
  [get_ports {text_out[24]}]  \
  [get_ports {text_out[23]}]  \
  [get_ports {text_out[22]}]  \
  [get_ports {text_out[21]}]  \
  [get_ports {text_out[20]}]  \
  [get_ports {text_out[19]}]  \
  [get_ports {text_out[18]}]  \
  [get_ports {text_out[17]}]  \
  [get_ports {text_out[16]}]  \
  [get_ports {text_out[15]}]  \
  [get_ports {text_out[14]}]  \
  [get_ports {text_out[13]}]  \
  [get_ports {text_out[12]}]  \
  [get_ports {text_out[11]}]  \
  [get_ports {text_out[10]}]  \
  [get_ports {text_out[9]}]  \
  [get_ports {text_out[8]}]  \
  [get_ports {text_out[7]}]  \
  [get_ports {text_out[6]}]  \
  [get_ports {text_out[5]}]  \
  [get_ports {text_out[4]}]  \
  [get_ports {text_out[3]}]  \
  [get_ports {text_out[2]}]  \
  [get_ports {text_out[1]}]  \
  [get_ports {text_out[0]}] ]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[127]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[126]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[125]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[124]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[123]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[122]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[121]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[120]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[119]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[118]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[117]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[116]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[115]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[114]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[113]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[112]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[111]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[110]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[109]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[108]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[107]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[106]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[105]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[104]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[103]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[102]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[101]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[100]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[99]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[98]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[97]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[96]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[95]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[94]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[93]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[92]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[91]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[90]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[89]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[88]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[87]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[86]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[85]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[84]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[83]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[82]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[81]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[80]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[79]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[78]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[77]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[76]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[75]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[74]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[73]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[72]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[71]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[70]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[69]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[68]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[67]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[66]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[65]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[64]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[63]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[62]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[61]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[60]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[59]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[58]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[57]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[56]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[55]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[54]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[53]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[52]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[51]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[50]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[49]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[48]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[47]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[46]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[45]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[44]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[43]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[42]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[41]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[40]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[39]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[38]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[37]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[36]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[35]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[34]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[33]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[32]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[31]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[30]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[29]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[28]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[27]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[26]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[25]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[24]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[23]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[22]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[21]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[20]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[19]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[18]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[17]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[16]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[15]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[14]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[13]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[12]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[11]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[10]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[9]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[8]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[7]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {key[0]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[127]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[126]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[125]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[124]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[123]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[122]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[121]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[120]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[119]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[118]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[117]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[116]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[115]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[114]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[113]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[112]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[111]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[110]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[109]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[108]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[107]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[106]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[105]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[104]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[103]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[102]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[101]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[100]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[99]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[98]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[97]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[96]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[95]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[94]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[93]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[92]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[91]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[90]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[89]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[88]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[87]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[86]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[85]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[84]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[83]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[82]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[81]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[80]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[79]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[78]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[77]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[76]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[75]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[74]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[73]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[72]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[71]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[70]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[69]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[68]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[67]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[66]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[65]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[64]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[63]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[62]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[61]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[60]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[59]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[58]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[57]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[56]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[55]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[54]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[53]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[52]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[51]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[50]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[49]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[48]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[47]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[46]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[45]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[44]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[43]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[42]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[41]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[40]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[39]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[38]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[37]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[36]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[35]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[34]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[33]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[32]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[31]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[30]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[29]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[28]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[27]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[26]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[25]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[24]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[23]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[22]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[21]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[20]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[19]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[18]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[17]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[16]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[15]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[14]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[13]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[12]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[11]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[10]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[9]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[8]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[7]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {key[0]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[127]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[126]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[125]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[124]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[123]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[122]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[121]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[120]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[119]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[118]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[117]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[116]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[115]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[114]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[113]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[112]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[111]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[110]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[109]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[108]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[107]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[106]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[105]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[104]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[103]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[102]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[101]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[100]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[99]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[98]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[97]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[96]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[95]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[94]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[93]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[92]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[91]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[90]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[89]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[88]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[87]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[86]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[85]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[84]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[83]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[82]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[81]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[80]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[79]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[78]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[77]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[76]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[75]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[74]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[73]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[72]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[71]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[70]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[69]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[68]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[67]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[66]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[65]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[64]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[63]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[62]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[61]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[60]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[59]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[58]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[57]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[56]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[55]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[54]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[53]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[52]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[51]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[50]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[49]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[48]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[47]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[46]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[45]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[44]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[43]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[42]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[41]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[40]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[39]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[38]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[37]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[36]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[35]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[34]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[33]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[32]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[31]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[30]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[29]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[28]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[27]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[26]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[25]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[24]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[23]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[22]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[21]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[20]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[19]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[18]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[17]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[16]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[15]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[14]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[13]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[12]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[11]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[10]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[9]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[8]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[7]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[6]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[5]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[4]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[3]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[2]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[1]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 2.0 [get_ports {text_out[0]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[127]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[126]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[125]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[124]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[123]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[122]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[121]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[120]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[119]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[118]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[117]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[116]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[115]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[114]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[113]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[112]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[111]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[110]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[109]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[108]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[107]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[106]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[105]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[104]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[103]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[102]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[101]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[100]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[99]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[98]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[97]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[96]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[95]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[94]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[93]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[92]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[91]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[90]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[89]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[88]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[87]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[86]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[85]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[84]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[83]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[82]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[81]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[80]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[79]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[78]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[77]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[76]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[75]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[74]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[73]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[72]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[71]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[70]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[69]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[68]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[67]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[66]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[65]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[64]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[63]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[62]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[61]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[60]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[59]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[58]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[57]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[56]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[55]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[54]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[53]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[52]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[51]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[50]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[49]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[48]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[47]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[46]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[45]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[44]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[43]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[42]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[41]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[40]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[39]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[38]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[37]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[36]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[35]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[34]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[33]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[32]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[31]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[30]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[29]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[28]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[27]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[26]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[25]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[24]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[23]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[22]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[21]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[20]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[19]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[18]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[17]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[16]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[15]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[14]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[13]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[12]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[11]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[10]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[9]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[8]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[7]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[6]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[5]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[4]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[3]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[2]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[1]}]
set_output_delay -clock [get_clocks clk] -add_delay -min 0.0 [get_ports {text_out[0]}]
set_max_fanout 32.000 [current_design]
set_drive 0.0 [get_ports clk]
set_drive 0.0 [get_ports rst]
set_ideal_network -no_propagate [get_nets clk]
set_ideal_network -no_propagate [get_nets rst]
set_dont_touch_network [get_ports rst]
set_wire_load_mode "segmented"
set_clock_latency -max 1.0 [get_clocks clk]
set_clock_latency -source -max 1.0 [get_clocks clk]
set_clock_uncertainty -setup 0.5 [get_clocks clk]
set_clock_uncertainty -hold 0.5 [get_clocks clk]
