define_design_lib work -path ./WORK

set search_path [list . /opt/dell/openmanage/idrac7/synopsys/syn/O-2018.06-SP2/libraries/syn /proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140_180b/AN61001_20180509/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp40p140_180a /proj1/pd/pdk/TSMC28HPHP/logic/tcbn28hpcplusbwp40p140hvt_180a/AN61001_20180829/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp40p140hvt_180a /proj1/pd/users/testcase/arm_mems/ct_f_spsram_512x44/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_512x52/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_512x54/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_512x59/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_512x7/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_512x96/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_8192x128/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_128x16/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_1024x64/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_2048x32/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_256x23/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_256x84/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_512x144/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_512x22/lib /proj1/pd/users/testcase/arm_mems/ct_f_spsram_256x98/lib]

set target_library [list tcbn28hpcplusbwp40p140ssg0p81vm40c.db tcbn28hpcplusbwp40p140hvtssg0p81vm40c.db]
set synthetic_library [list dw_foundation.sldb]
set link_library [list * tcbn28hpcplusbwp40p140ssg0p81vm40c.db tcbn28hpcplusbwp40p140hvtssg0p81vm40c.db dw_foundation.sldb ct_f_spsram_512x44_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_512x52_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_512x54_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_512x59_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_512x7_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_512x96_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_8192x128_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_256x98_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_128x16_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_1024x64_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_2048x32_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_256x23_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_256x84_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_512x144_ssg_cworstt_0p81v_0p81v_m40c.db ct_f_spsram_512x22_ssg_cworstt_0p81v_0p81v_m40c.db] 

set rtl_filelist /proj1/projects/pd/projects_28nm/ct_top/C910_asic_rtl.fl 
source $rtl_filelist
analyze -format verilog $ver_files

##Elaborate
elaborate ct_top 

current_design ct_top 

link

