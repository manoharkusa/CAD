# Timing constraints


set DFF_CLK_PIN clocked_on
set DFF_DATA_PIN next_state
set DFF_OUTP_PIN Q

set MUX_CONTROL_PIN S


#############################
## Driving Cells and Loads ##
#############################

set pin_cap [get_attribute [get_lib_pins tcbn28hpcplusbwp40p140ssg0p81vm40c/BUFFD4BWP40P140/I] capacitance]
set_load [expr 5 * $pin_cap] [all_outputs]
set_driving_cell [all_inputs] -lib_cell BUFFD4BWP40P140 -pin Z -no_design_rule

##################
## Input Clocks ##
##################
puts "Clocks..."

set TCK_SYS 11.0
create_clock -name clk_sys -period $TCK_SYS [get_ports clk_i]

set TCK_JTG 40.0
create_clock -name clk_jtg -period $TCK_JTG [get_ports jtag_tck_i]

set TCK_RTC 50.0
create_clock -name clk_rtc -period $TCK_RTC [get_ports rtc_i]

set TCK_SLI [expr 4 * $TCK_SYS]
create_clock -name clk_sli -period $TCK_SLI [get_ports slink_rcv_clk_i[0]]

set TCK_USB [expr 1000/48]
create_clock -name clk_usb -period $TCK_USB [get_ports usb_clk_i]

set HYP_TGT_DLY 3.8
set HYP_ASM_RTT [expr fmod(0.9 + $HYP_TGT_DLY + 3.2 + 5.75 + 1.04, $TCK_SYS)]
set HYP_RWDSI_FORM [list [expr $HYP_ASM_RTT] [expr $HYP_ASM_RTT + $TCK_SYS / 2]]
create_clock -name clk_hyp_rwdsi -period $TCK_SYS -waveform $HYP_RWDSI_FORM [get_ports hyper_rwds_i[0]]


set HYP_MIN_DLY 3.5

######################
## Generated Clocks ##
######################


set SLO_PHY_TCLK_REG [get_cells -hierarchical *clk_slow_reg*]
set SLO_PHY_TCLK_Q   [get_pins -of_objects $SLO_PHY_TCLK_REG -filter "name == $DFF_OUTP_PIN"]
set SLO_PHY_TCLK_CLK [get_pins -of_objects $SLO_PHY_TCLK_REG -filter "name == $DFF_CLK_PIN"]

# Create slow clock driving TX output (worst case: divided by 4)
puts "SLINK slow TX clk: master-clk from [get_object_name $SLO_PHY_TCLK_CLK] & drives pins [get_object_name $SLO_PHY_TCLK_Q]"
create_generated_clock -name clk_gen_slo_drv -edges {1 5 9} -source $SLO_PHY_TCLK_CLK $SLO_PHY_TCLK_Q


set SLO_PHY_RCLK_REG [get_flat_cells *ddr_rcv_clk_o*]
set SLO_PHY_RCLK_Q   [get_pins -of_objects $SLO_PHY_RCLK_REG -filter "name == $DFF_OUTP_PIN"]
set SLO_PHY_RCLK_CLK [get_pins -of_objects $SLO_PHY_RCLK_REG -filter "name == $DFF_CLK_PIN"]

# Create clock for serial link TX (worst case: divided by 4, +90 deg)
puts "SLINK slow RX clk: master-clk from [get_object_name $SLO_PHY_RCLK_CLK] & drives pins [get_object_name $SLO_PHY_RCLK_Q]"
create_generated_clock -name clk_gen_slo -edges {3 7 11} -source $SLO_PHY_RCLK_CLK $SLO_PHY_RCLK_Q

# Do not produce timing arcs from the TX back to the RX clock or from the RX clock to its TX-timed IO
  #set_false_path -from [get_ports hyper_rwds_io] -through [get_pins pad_hyper_rwds.i_pad/PAD]
  #set_false_path -from [get_clocks clk_hyp_rwdsi] -to [get_ports hyper_rwds_io]

##################################
## Clock Groups & Uncertainties ##
##################################

# Define which collections of clocks are asynchronous to each other
# 'allow_paths' re-activates checks on datapaths between clock domains
# this way we must constrain them seperately or we get unmet timings
set_clock_groups -asynchronous -name clk_groups_async \
     -group {clk_rtc} \
     -group {clk_jtg} \
     -group {clk_sys clk_gen_slo clk_gen_slo_drv clk_hyp_rwdsi} \
     -group {clk_sli} \
     -group {clk_usb} 

# We set reasonable uncertainties and transitions for all nonvirtual clocks
set CLK_UNCERTAINTY   0.1
set_clock_uncertainty $CLK_UNCERTAINTY [all_clocks]
set_clock_transition  0.2 [all_clocks]


####################
## Cdcs and ASyncs ##
####################
puts "CDC/ASync..."

# Constrain `cdc_2phase` for DMI request
set_max_delay [expr $TCK_SYS * 0.20] -through [get_pins -of [get_nets i_cheshire_soc/i_dbg_dmi_jtag/i_dmi_cdc/i_cdc_req/*async_*] -filter "direction==out"] -ignore_clock_latency
# Constrain `cdc_2phase` for DMI response
set_max_delay [expr $TCK_SYS * 0.20] -through [get_pins -of [get_nets i_cheshire_soc/i_dbg_dmi_jtag/i_dmi_cdc/i_cdc_resp/*async_*] -filter "direction==out"] -ignore_clock_latency

# Constrain `cdc_fifo_gray` for serial link in
set_max_delay [expr $TCK_SYS * 0.20] -through [get_pins -of [get_nets i_cheshire_soc/gen_serial_link.i_serial_link/gen_phy_channels.__0.i_serial_link_physical/i_serial_link_physical_rx*/i_cdc_in/*async_*] -filter "direction==out"] -ignore_clock_latency

# Constrain CLINT RTC sync
set_max_delay [expr $TCK_SYS * 0.20] -to [get_pins  i_cheshire_soc/i_clint/i_sync_edge/i_sync/reg_q_reg[0]/${DFF_DATA_PIN}] -ignore_clock_latency

#############
## I/O delays ##
#############
puts "Input/Outputs..."

# We assume test mode is disabled. This is required to stop spurious clock propagation at some muxes
# set_case_analysis 0 [get_ports test_mode_i]

# Reset and boot mode should propagate to system domain within a clock cycle.
# the reset synchronizer makes sure de-assertion should be within the first clock half-cycle
# `network_latency_included` ensures IO timing w.r.t. the *externally applied*
# clock (i.e. the one at the clock pad_instead of the internal clock tree.
set_input_delay -max -clock clk_sys [ expr $TCK_SYS * 0.50 ] [get_ports {rst_ni boot_mode_*}]
set_input_delay -min -clock clk_sys [ expr $TCK_SYS * 0.50 ] [get_ports {rst_ni boot_mode_*}]
 set_input_delay -max -clock clk_sys [ expr $TCK_SYS * 0.50 ] [get_ports test_mode_i]
set_input_delay -min -clock clk_sys [ expr $TCK_SYS * 0.50 ] [get_ports test_mode_i]


# Test mode can propagate to all domains within reasonable delay
# set_false_path -hold                    -from [get_ports test_mode_i]
# set_max_delay  [ expr $TCK_SYS * 0.75 ] -from [get_ports test_mode_i]

##########
## JTAG ##
##########
puts "JTAG..."

set_input_delay  -max -clock clk_jtg [ expr $TCK_JTG * 0.50 ]     [get_ports {jtag_tdi_i jtag_tms_i}]
set_input_delay  -min -clock clk_jtg [ expr $TCK_JTG * 0.50 ]     [get_ports {jtag_tdi_i jtag_tms_i}]

set_output_delay -max -clock clk_jtg [ expr $TCK_JTG * 0.50 / 2 ] [get_ports jtag_tdo_o]
set_output_delay -max -clock clk_jtg [ expr $TCK_JTG * 0.50 / 2 ] [get_ports jtag_tdo_*]

set_input_delay  -min -clock clk_jtg [ expr $TCK_JTG * 0.50 ]     [get_ports jtag_trst_ni]
set_input_delay  -max -clock clk_jtg [ expr $TCK_JTG * 0.50 ]     [get_ports jtag_trst_ni ]
##Jtag reset
set_max_delay $TCK_JTG  -from [get_ports jtag_trst_ni]
set_false_path -hold    -from [get_ports jtag_trst_ni]


########
## VGA ##
#########
puts "VGA..."

# Allow VGA IO to take two cycles to propagate
set VGA_IO_CYC 2

set_multicycle_path -setup $VGA_IO_CYC              -to [get_ports vga_*]
set_multicycle_path -hold  [ expr $VGA_IO_CYC - 1 ] -to [get_ports vga_*]


set_output_delay -max -clock clk_sys [expr $TCK_SYS * $VGA_IO_CYC * 0.35] [get_ports vga_*]


##############
## SPI Host ##
##############
puts "SPI..."

# Allow SPI Host IO to take two cycles to propagate
set SPIH_IO_CYC 2

# Time all IO (*including* generated clock) with the system clock which launches and captures it
set_multicycle_path -setup $SPIH_IO_CYC -to [get_ports spih* -filter "direction==out"]
set_multicycle_path -hold  [ expr $SPIH_IO_CYC - 1 ] -to [get_ports spih* -filter "direction==out"]

set_input_delay  -max -clock clk_sys [ expr $TCK_SYS * $SPIH_IO_CYC * 0.35 ] [get_ports spih_sd* -filter "direction==in"]
set_input_delay  -min -clock clk_sys [ expr $TCK_SYS * $SPIH_IO_CYC * 0.35 ] [get_ports spih_sd* -filter "direction==in"]

set_output_delay -max -clock clk_sys [ expr $TCK_SYS * $SPIH_IO_CYC * 0.35 ] [get_ports {spih_sck_o spih_sd* spih_csb*} -filter "direction==out"]

# The data pins are bidirectional, output-enable should not arrive before output-data as to not cause problems (setup)
# similarly data should be stable while OE switches the pad back to being an input (hold)
# We have OE-negative so rise and fall are flipped


#########
## I2C ##
#########
puts "I2C..."

set_input_delay  -max -clock clk_sys [ expr $TCK_SYS * 0.35 ] [get_ports i2c_* -filter "direction==in"]
set_input_delay  -min -clock clk_sys [ expr $TCK_SYS * 0.35 ] [get_ports i2c_* -filter "direction==in"]

set_output_delay -max -clock clk_sys [ expr $TCK_SYS * 0.35 ] [get_ports i2c_* -filter "direction==out"]

###Bharath comment below
# output enable shuld toggle while data is stable see SPI for full reasoning
#foreach pad [get_cells pad_i2c*.i_pad] {
#  set oen [get_pins -of_objects $pad -filter "name == OEN"]
#  set din [get_pins -of_objects $pad -filter "name == DIN"]
#  set_data_check -fall_from $oen -to $din -clock clk_sys -setup [ expr $TCK_SYS * 0.10 ]
#  set_data_check -rise_from $oen -to $din -clock clk_sys -hold  [ expr $TCK_SYS * 0.10 ]
#}


##########
## UART ##
##########
puts "UART..."

set_input_delay  -max -clock clk_sys [ expr $TCK_SYS * 0.35 ] [get_ports uart_rx_i]
set_input_delay  -min -clock clk_sys [ expr $TCK_SYS * 0.35 ] [get_ports uart_rx_i]

set_output_delay -max -clock clk_sys [ expr $TCK_SYS * 0.35 ] [get_ports uart_tx_o]


##########
## GPIO ##
##########
puts "GPIO..."

set_input_delay  -max -clock clk_sys [ expr $TCK_SYS * 0.35 ] [get_ports gpio_* -filter "direction==in"]
set_input_delay  -min -clock clk_sys [ expr $TCK_SYS * 0.35 ] [get_ports gpio_* -filter "direction==in"]

set_output_delay -max -clock clk_sys [ expr $TCK_SYS * 0.35 ] [get_ports gpio_* -filter "direction==out"]

set_output_delay -min -clock clk_sys [ expr $TCK_SYS * 0.35 ] [get_ports gpio_* -filter "direction==out"]

##########
## USB  ##
##########


#################
## Serial Link ##
#################
puts "Serial Link..."

set SL_MAX_SKEW 0.55
set SL_IN       [get_ports slink_i*]
set SL_OUT      [get_ports slink_o*]
set SL_OUT_CLK  [get_ports slink_rcv_clk_o[0]]

# DDR Input: Maximize assumed *transition* (unstable) interval by maximizing input delay span.
# Transitions happen *between* sampling input clock edges, so centered around T/4 *after* sampling edges.
# We assume that the transition takes up almost a full half period, so (T/4 - (T/4-skew), T/4 + (T/4-skew)).
set_input_delay -max -add_delay             -clock clk_sli [expr  $TCK_SLI / 2 -1.5 - $SL_MAX_SKEW] $SL_IN
set_input_delay -min -add_delay             -clock clk_sli [expr  $TCK_SLI / 2 -1.5 - $SL_MAX_SKEW] $SL_IN

set_input_delay -max -add_delay -clock_fall -clock clk_sli [expr  $TCK_SLI / 2 -1.5 - $SL_MAX_SKEW] $SL_IN
set_input_delay -min -add_delay -clock_fall -clock clk_sli [expr  $TCK_SLI / 2 -1.5 - $SL_MAX_SKEW] $SL_IN


# DDR Output: Maximize *stable* interval we provide by maximizing output delay span (i.e. range in
# which the target device may sample). This allows our outputs to transition only in a small margin.
# The stable interval is centered around the centered clock sent for sampling, so (-T/4+skew, T/4-skew)
set_output_delay -max -add_delay             -clock clk_gen_slo [expr  $TCK_SLI / 4 - $SL_MAX_SKEW] $SL_OUT
set_output_delay -max -add_delay -clock_fall -clock clk_gen_slo [expr  $TCK_SLI / 4 - $SL_MAX_SKEW] $SL_OUT
set_output_delay -max -add_delay -clock_fall -clock clk_gen_slo [expr  $TCK_SLI / 4 - $SL_MAX_SKEW] $SL_OUT_CLK
# Do not consider noncritical edges between driving and sent TX clock
set_false_path -setup -rise_from [get_clocks clk_gen_slo_drv] -rise_to [get_clocks clk_gen_slo]
set_false_path -setup -fall_from [get_clocks clk_gen_slo_drv] -fall_to [get_clocks clk_gen_slo]
set_false_path -hold  -rise_from [get_clocks clk_gen_slo_drv] -fall_to [get_clocks clk_gen_slo]
set_false_path -hold  -fall_from [get_clocks clk_gen_slo_drv] -rise_to [get_clocks clk_gen_slo]

###CHECK: If below path create any clock leaks through mux select pin
#set SLO_CLK_CELLS     [all_fanout -from $SLO_PHY_TCLK_Q -only_cells]
#set SLO_CLK_MUX_PINS  [get_pins -of_objects $SLO_CLK_CELLS -filter "name == $MUX_CONTROL_PIN"]
#set_sense -clock -stop_propagation $SLO_CLK_MUX_PINS


##############
## Hyperbus ##
##############
  puts "Hyperbus..."
  set HYP_MAX_SLEW 0.55
  set HYP_OUT_CLK  [get_ports hyper_ck_o*]

  # DDR Input: As for serial link, maximize the assumed *transition* interval by maximizing input delay span.
  # However here, transitions happen *at* edge-aligned input clock edges, so they are centered *at* the edges.
  # Therefore, the input transition interval becomes (T/4 - (T/4-skew), T/4 + (T/4-skew)).
   set_input_delay -max -add_delay -clock clk_hyp_rwdsi [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] [get_ports {hyper_dq* hyper_rwds*} -filter "direction==in"] 
   set_input_delay -min -add_delay -clock clk_hyp_rwdsi [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] [get_ports {hyper_dq* hyper_rwds*} -filter "direction==in"] 
   set_input_delay -max -add_delay -clock_fall -clock clk_hyp_rwdsi [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] [get_ports {hyper_dq* hyper_rwds*} -filter "direction==in"]
   set_input_delay -min -add_delay -clock_fall -clock clk_hyp_rwdsi [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] [get_ports {hyper_dq* hyper_rwds*} -filter "direction==in"]

  # DDR Output: Maximize *stable* interval we provide by maximizing output delay span.
  # This is exactly analogous to the serial link case, as the sending clock is center-aligned with data.
  # We carefully *exclude* the output enable here by using pre-pad timing.
  set_output_delay -max -add_delay             -clock clk_sys [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] [get_ports {hyper_dq* hyper_rwds*} -filter "direction==out"]
  set_output_delay -max -add_delay -clock_fall -clock clk_sys [expr  $TCK_SYS / 4 - $HYP_MAX_SLEW] [get_ports {hyper_dq* hyper_rwds*} -filter "direction==out"]

  # CS is *synchronous* (edge aligned) with output clock at pad, *not* DDR
  set_output_delay -max -add_delay -clock clk_sys [expr $TCK_SYS / 2 - $HYP_MAX_SLEW] [get_ports {hyper_cs_*} -filter "direction==out"]

   set_output_delay -max -add_delay -clock clk_sys [expr $TCK_SYS / 2 - $HYP_MAX_SLEW] [get_ports {hyper_ck_*} -filter "direction==out"]
  # Do not allow PHY (System) clock to leak to DDR outputs and be timed as output transitions
  # the clk is used to mux between output data (to make it double-data rate)
  # this makes sure the clock-tree does not bleed through the mux into the data paths
  set HYP_DDR_DATA_MUXES [get_object_name [get_cells i_hyperbus/i_phy/genblk1.i_phy/i_trx/gen_ddr_tx_data**.i_ddr_tx_data/i_ddrmux/i_mux]]
  set HYP_DDR_RWDS_MUX [get_object_name [get_cells i_hyperbus/i_phy/genblk1.i_phy/i_trx/i_ddr_tx_rwds/i_ddrmux/i_mux]]

  set_sense -clocks [get_clocks *] -stop_propagation [get_pins -of_objects [get_cells $HYP_DDR_DATA_MUXES] -filter "name==S"]

  # the clk is now stopped and doesn't bleed through but the paths gets timed as a data-path instead
  # this is fine but only produces reasonable results after CTS, before CTS it misleads repair_timing into erroneously placing buffers in the clock net
  # IMPORTANT!!!!! remove these false paths post-CTS via unset_path_exceptions
  set_false_path -from clk_i -through [get_pins -of_objects [get_cells $HYP_DDR_DATA_MUXES] -filter "name==S"]
  set_false_path -from clk_i -through [get_pins -of_objects [get_cells $HYP_DDR_RWDS_MUX] -filter "name==S"]


  # We multicycle the passthrough reset as it does not quite reach through the chip in one cycle
  set HYP_RST      [get_ports hyper_reset_no*]
  set_multicycle_path -setup 2 -to $HYP_RST 
  set_multicycle_path -hold  1 -to $HYP_RST
  set_output_delay -max -clock clk_sys [expr $TCK_SYS * 2 * 0.35] $HYP_RST

  #set HYPER_CS_REG [get_object_name [get_cells -hierarchical *hyper_cs_no_reg*]]
  #group_path -name "Hyper90degCS" -to [get_pins -of_objects [get_cells $HYPER_CS_REG] -filter "name == $DFF_DATA_PIN"]
  #set_multicycle_path -setup 0 -to [get_pins -of_objects [get_cells $HYPER_CS_REG] -filter "name == $DFF_DATA_PIN"]
  #set_multicycle_path -hold 0 -to [get_pins -of_objects [get_cells $HYPER_CS_REG] -filter "name == $DFF_DATA_PIN"]
 
  #set HYPER_CS_CG_CELL [get_object_name [get_cells i_hyperbus/i_phy/genblk1.i_phy/i_trx/i_clock_diff_out/i_hyper_ck_gating/i_clkgate]] 
  #group_path -name "Hyper90degClkGate" -to [get_pins -of_objects $HYPER_CS_CG_CELL -filter "name == E"]
  #set_multicycle_path -setup 0 -to [get_pins -of_objects $HYPER_CS_CG_CELL -filter "name == E"]
  #set_multicycle_path -hold 0 -to [get_pins -of_objects $HYPER_CS_CG_CELL -filter "name == E"]
