
ui_info "Start of PDK YAML loader script"
###project yaml pointer
set PROJ_YAML "$env(ENV_SCRIPTS)/common/project_tech.yaml"
if {[file exists $PROJ_YAML]} {
	set PROJ_PDK [load_yaml_file $PROJ_YAML]
} else {
	ui_error "FATAL Project yaml file not found $PROJ_YAML"
	exit
}
set MEM_LIST_FILE "$env(BLOCK_INPUTS)/mem_list"

##Validate if required sections exist
foreach req_section {metal_stack stdcells macros corners} {
    if {![dict exists $PROJ_PDK $req_section]} {
        ui_error "Missing required section '$req_section' in $PROJ_YAML"
    }
}

set TIMING_LIB_FORMAT [dict get $PROJ_PDK timing_lib_format]
set TIMING_DB_FORMAT [dict get $PROJ_PDK timing_db_format]

set VALID_LIB_FORMATS {timing_nldm_libs timing_ccs_libs timing_ecsm_libs}
set VALID_DB_FORMATS {timing_nldm_dbs timing_ccs_dbs}

if {$TIMING_LIB_FORMAT ni $VALID_LIB_FORMATS} {
    ui_error "FATAL: Invalid timing_lib_format '$TIMING_LIB_FORMAT'. Must be one of: $VALID_LIB_FORMATS"
}

if {$TIMING_DB_FORMAT ni $VALID_DB_FORMATS} {
    ui_error "FATAL: Invalid timing_db_format '$TIMING_DB_FORMAT'. Must be one of: $VALID_DB_FORMATS"
}
ui_info "Timing libs format set to: $TIMING_LIB_FORMAT"
ui_info "Timing db format set to: $TIMING_DB_FORMAT"

# ----------------------------------------------------------------
# --- 1. Load Metal Stack & Collect Core Paths ---
# ----------------------------------------------------------------
set metal_yaml [dict get $PROJ_PDK metal_stack]
set metal_cfg  [load_yaml_file $metal_yaml]

# ----------------------------------------------------------------
# --- 2. Load stdcell yaml files ---
# ----------------------------------------------------------------
set stdcells_cfg {}
foreach {vt_type yaml_path} [dict get $PROJ_PDK stdcells] {
    ui_info "Loading VT flavor '$vt_type' from $yaml_path"
    dict set stdcells_cfg $vt_type [load_yaml_file $yaml_path]
}


# ----------------------------------------------------------------
# --- 3. Load memory yaml files (only used in this block) ---
# ----------------------------------------------------------------
set design_with_macros  0;   #Default macro flag set to 0
if {[file exists $MEM_LIST_FILE]} {
    # Parse mem_list file
    ui_info "Macro list file found: $MEM_LIST_FILE"

    set fp [open $MEM_LIST_FILE r]
    set raw_lines [split [read $fp] \n]
    close $fp

    set macros_list {}       ;# List of macro keys
    set design_with_macros  1;   #Flag if design having macros

    foreach line $raw_lines {
    	# Strip comments & whitespace
    	regsub {#.*$} $line {} line
    	set line [string trim $line]
    	if {$line eq ""} continue

    	# Extract macro key (first token)
    	set tokens [split $line]
    	set macro_key [lindex $tokens 0]
    	lappend macros_list $macro_key
     }

    # Validate & Load ONLY requested macros
    set macros_cfg {}
    
    foreach macro_key $macros_list {
    	if {![dict exists $PROJ_PDK macros $macro_key]} {
        	ui_error "Macro '$macro_key' in $MEM_LIST_FILE is not defined in project YAML macros section!"
    	}
    
    	set yaml_path [dict get $PROJ_PDK macros $macro_key]
    	puts "Loading macro '$macro_key' ($yaml_path)"
    	dict set macros_cfg $macro_key [load_yaml_file $yaml_path]
    }
    
    ui_info "Loaded [dict size $macros_cfg] macros for design."
}


# ----------------------------------------------------------------
# --- 4. Populate flow variables in flow ---
# ----------------------------------------------------------------
set CELL_LEFS {}
set CELL_GDS {}
set CELL_CDL {}
set CELL_NDMS {}
##First populate empty TIMING_LIBS & TIMING_DBS for every corner in PROJ_PDK
foreach {view_name corner_cfg} [dict get $PROJ_PDK corners] {
	set corner_name [dict get $corner_cfg lib_pvt]
	set TIMING_LIBS($corner_name) {}
	set TIMING_TARGET_LIBS($corner_name) {}
	set TIMING_DBS($corner_name) {}
	set TIMING_TARGET_DBS($corner_name) {}
}

# --- a. LEFS, GDS, CDL, NDMS ---
# Std cells
foreach {vt_type cfg} $stdcells_cfg {
    lappend CELL_LEFS [get_required $cfg lef "stdcell '$vt_type'"]
    lappend CELL_GDS [get_required $cfg gds "stdcell '$vt_type'"]
    lappend CELL_CDL [get_required $cfg spice "stdcell '$vt_type'"]
    lappend CELL_NDMS [get_required $cfg ndm "stdcell '$vt_type'"]
    #libs
    set TIMING_STD_LIBS [get_required $cfg $TIMING_LIB_FORMAT "stdcell '$vt_type'"]
    set lib_path [get_required $TIMING_STD_LIBS base_path "stdcell '$vt_type'"]
    foreach lib_corner [array names TIMING_LIBS] {
	    lappend TIMING_LIBS($lib_corner) [join [list $lib_path [get_required $TIMING_STD_LIBS $lib_corner]] "/"]
	    lappend TIMING_TARGET_LIBS($lib_corner) [join [list $lib_path [get_required $TIMING_STD_LIBS $lib_corner]] "/"]
    }
    #dbs
    set TIMING_STD_DBS [get_required $cfg $TIMING_DB_FORMAT "stdcell '$vt_type'"]
    set lib_path [get_required $TIMING_STD_DBS base_path "stdcell '$vt_type'"]
    foreach lib_corner [array names TIMING_DBS] {
	    lappend TIMING_DBS($lib_corner) [join [list $lib_path [get_required $TIMING_STD_DBS $lib_corner]] "/"]
	    lappend TIMING_TARGET_DBS($lib_corner) [join [list $lib_path [get_required $TIMING_STD_DBS $lib_corner]] "/"]
    }
}


# Load macros only if macro flag is set
if {$design_with_macros} {
foreach {macro_name cfg} $macros_cfg {
    lappend CELL_LEFS [get_required $cfg lef "macro '$macro_name'"]
    lappend CELL_GDS [get_required $cfg gds "macro '$macro_name'"]
    lappend CELL_CDL [get_required $cfg spice "macro '$macro_name'"]
    lappend CELL_NDMS [get_required $cfg ndm "macro '$macro_name'"]
    #libs
    set TIMING_MACRO_LIBS [get_required $cfg $TIMING_LIB_FORMAT "macro '$macro_name'"]
    set lib_path [get_required $TIMING_MACRO_LIBS base_path "macro '$macro_name'"]
    foreach lib_corner [array names TIMING_LIBS] {
	    lappend TIMING_LIBS($lib_corner) [join [list $lib_path [get_required $TIMING_MACRO_LIBS $lib_corner]] "/"]
    }
    #dbs
    set TIMING_MACRO_DBS [get_required $cfg $TIMING_DB_FORMAT "macro '$macro_name'"]
    set lib_path [get_required $TIMING_MACRO_DBS base_path "macro '$macro_name'"]
    foreach lib_corner [array names TIMING_DBS] {
	    lappend TIMING_DBS($lib_corner) [join [list $lib_path [get_required $TIMING_MACRO_DBS $lib_corner]] "/"]
    }
}
}


ui_info "End of PDK YAML loader script"
