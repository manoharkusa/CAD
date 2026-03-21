# Flowkit v0.2
# Lib paths
set svt_std_lib_path /proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140_180b/AN61001_20180509/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp40p140_180a 
set hvt_std_lib_path /proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140hvt_180a/AN61001_20180829/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp40p140hvt_180a
set lvt_std_lib_path /proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140lvt_180b/AN61001_20180509/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp40p140lvt_180a 
set sdc_file $env(BLOCK_INPUTS)/${design_name}.sdc
set qrc_tech_path /proj1/dataIn/Rock_R2G/release_9_2_2021/qrc
##############################################################################
## LIBRARY SETS
##############################################################################
create_library_set -name fast0p99vm40c_libs -timing [list \
$svt_std_lib_path/tcbn28hpcplusbwp40p140ffg0p99vm40c.lib \
$hvt_std_lib_path/tcbn28hpcplusbwp40p140hvtffg0p99vm40c.lib \
$lvt_std_lib_path/tcbn28hpcplusbwp40p140lvtffg0p99vm40c.lib \
]
 
create_library_set -name fast0p99v125c_libs -timing [list \
$svt_std_lib_path/tcbn28hpcplusbwp40p140ffg0p99v125c.lib \
$hvt_std_lib_path/tcbn28hpcplusbwp40p140hvtffg0p99v125c.lib \
$lvt_std_lib_path/tcbn28hpcplusbwp40p140lvtffg0p99v125c.lib \
]

create_library_set -name slow0p81v125c_libs -timing [list \
$svt_std_lib_path/tcbn28hpcplusbwp40p140ssg0p81v125c.lib \
$hvt_std_lib_path/tcbn28hpcplusbwp40p140hvtssg0p81v125c.lib \
$lvt_std_lib_path/tcbn28hpcplusbwp40p140lvtssg0p81v125c.lib \
]

create_library_set -name slow0p81vm40c_libs -timing [list \
$svt_std_lib_path/tcbn28hpcplusbwp40p140ssg0p81vm40c.lib \
$hvt_std_lib_path/tcbn28hpcplusbwp40p140hvtssg0p81vm40c.lib \
$lvt_std_lib_path/tcbn28hpcplusbwp40p140lvtssg0p81vm40c.lib \
]

##############################################################################
## OPERATING CONDITIONS
##############################################################################
create_timing_condition -library_sets slow0p81v125c_libs -name slow125
create_timing_condition -library_sets slow0p81vm40c_libs -name slowm40
create_timing_condition -library_sets fast0p99v125c_libs -name fast125
create_timing_condition -library_sets fast0p99vm40c_libs -name fastm40

##############################################################################
## RC CORNERS
##############################################################################
create_rc_corner -name cworst_m40 -temperature -40 -qrc_tech $qrc_tech_path/cworst/qrcTechFile 
create_rc_corner -name rcworst_125 -temperature 125.0 -qrc_tech $qrc_tech_path/rcworst/qrcTechFile 
create_rc_corner -name cbest_m40 -temperature -40 -qrc_tech $qrc_tech_path/cbest/qrcTechFile
create_rc_corner -name rcbest_125 -temperature 125.0 -qrc_tech $qrc_tech_path/rcbest/qrcTechFile

##############################################################################
## DELAY CORNERS
##############################################################################
create_delay_corner -name ss_125c_rcw -early_timing_condition slow125 -late_timing_condition slow125 -rc_corner rcworst_125
create_delay_corner -name ss_m40c_cw -early_timing_condition slowm40 -late_timing_condition slowm40 -rc_corner cworst_m40

create_delay_corner -name ff_125c_rcb -early_timing_condition fast125 -late_timing_condition fast125 -rc_corner rcbest_125
create_delay_corner -name ff_m40c_cb -early_timing_condition fastm40 -late_timing_condition fastm40 -rc_corner cbest_m40 

##############################################################################
## CONSTRAINT MODES
##############################################################################
create_constraint_mode -name func -sdc_files $sdc_file

##############################################################################
## ANALYSIS VIEWS
##############################################################################
create_analysis_view -name func_ss125c_rcw  -delay_corner ss_125c_rcw -constraint_mode func
create_analysis_view -name func_ssm40c_cw  -delay_corner ss_m40c_cw -constraint_mode func

create_analysis_view -name func_ff125c_rcb  -delay_corner ff_125c_rcb -constraint_mode func
create_analysis_view -name func_ffm40c_cb  -delay_corner ff_m40c_cb -constraint_mode func

##############################################################################
## ACTIVE VIEWS
##############################################################################
set_analysis_view -setup [list func_ss125c_rcw func_ssm40c_cw] -hold [list func_ff125c_rcb func_ffm40c_cb] 



