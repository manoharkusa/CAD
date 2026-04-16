set sdc_file      $env(BLOCK_INPUTS)/${design_name}.sdc
set qrc_tech_base [dict get $metal_cfg qrc_tech_base]

##############################################################################
## CONSTRAINT MODE
##############################################################################
create_constraint_mode -name func -sdc_files $sdc_file

##############################################################################
## Dynamic MMMC build from pnr_corners in project YAML
##############################################################################
set pnr_corner_names [dict get $PROJ_PDK pnr_corners]

set setup_views      {}
set hold_views       {}
set created_lib_sets {}
set created_rc_corners {}

foreach corner_name $pnr_corner_names {
    set corner_cfg [dict get $PROJ_PDK corners $corner_name]
    set lib_pvt    [dict get $corner_cfg lib_pvt]
    set temp       [dict get $corner_cfg temp]
    set rc         [dict get $corner_cfg rc]
    set qrc_file   ${qrc_tech_base}/[dict get $metal_cfg qrc_corners $rc]

    ## LIBRARY SET (create once per unique lib_pvt)
    if {$lib_pvt ni $created_lib_sets} {
        create_library_set -name ${lib_pvt}_libs -timing $TIMING_LIBS($lib_pvt)
        lappend created_lib_sets $lib_pvt
    }

    ## TIMING CONDITION
    create_timing_condition -name tc_${corner_name} -library_sets ${lib_pvt}_libs

    ## RC CORNER (create once per unique rc value)
    if {$rc ni $created_rc_corners} {
        create_rc_corner -name $rc -temperature $temp -qrc_tech $qrc_file
        lappend created_rc_corners $rc
    }

    ## DELAY CORNER
    create_delay_corner -name dc_${corner_name} \
        -early_timing_condition tc_${corner_name} \
        -late_timing_condition  tc_${corner_name} \
        -rc_corner              $rc

    ## ANALYSIS VIEW
    create_analysis_view -name func_${corner_name} \
        -delay_corner    dc_${corner_name} \
        -constraint_mode func

    ## Classify setup (ss*) vs hold (ff* / tt*)
    if {[string match "ss*" $lib_pvt]} {
        lappend setup_views func_${corner_name}
    } else {
        lappend hold_views func_${corner_name}
    }
}

##############################################################################
## ACTIVE VIEWS
##############################################################################
set_analysis_view -setup $setup_views -hold $hold_views
