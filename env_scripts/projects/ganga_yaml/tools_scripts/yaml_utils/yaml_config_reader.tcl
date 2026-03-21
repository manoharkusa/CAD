#!/usr/bin/env tclsh
# ==============================================================================
# YAML Config Reader - Simplified Version
# ==============================================================================
# Loads Tech → Project → Block configs with simple merging
# To inspect block overrides: check if key exists in BLOCK_CONFIG
# ==============================================================================

package require yaml

# ==============================================================================
# Global Variables
# ==============================================================================
set ::TECH_CONFIG {}
set ::PROJECT_CONFIG {}
set ::BLOCK_CONFIG {}
set ::METAL_STACK_CONFIG {}
set ::VT_CONFIGS [dict create]
set ::SRAM_MACRO_TYPES [dict create]

# ==============================================================================
# Configuration Paths - Only specify these 3 main YAMLs
# Everything else (VT configs, metal stacks, SRAMs) resolved from tech.yaml
# ==============================================================================

# Technology and project names
set ::TECH_NAME "TSMC28HPHP"
set ::PROJECT_NAME "flow28nm_generalize"

# Main YAML paths (relative to CONFIGS_DIR)
#set ::YAML_PATHS [dict create \
#    tech_file           "tech/${TECH_NAME}/tech.yaml" \
#    project_file        "projects/${PROJECT_NAME}/project.yaml" \
#    block_file          "blocks/\${block_name}/block.yaml" \
#    mem_list            "blocks/\${block_name}/mem_list" \
#]
set ::YAML_PATHS [dict create \
    tech_file            $env(TECH_YAML) \
    project_yaml         $env{PROJECT_YAML) \
    block_file          "blocks/\${block_name}/block.yaml" \
    mem_list            "blocks/\${block_name}/mem_list" \
]

# Default configs directory
set ::DEFAULT_CONFIGS_DIR "/proj1/pd/users/testcase/Bharath/proj/flow28nm_generalize/configs"

# NOTE: VT configs, metal stack, and SRAM paths are NOT specified here
#       They are automatically resolved from tech.yaml catalog using resolve_config_file()

# ==============================================================================
# YAML Loading
# ==============================================================================

proc load_yaml_file {yaml_file} {
    if {![file exists $yaml_file]} {
        error "YAML file not found: $yaml_file"
    }
    set fp [open $yaml_file r]
    set yaml_content [read $fp]
    close $fp
    return [::yaml::yaml2dict $yaml_content]
}

# ==============================================================================
# Simple Recursive Dictionary Merge
# ==============================================================================

proc dict_merge_recursive {dict1 dict2} {
    # Merge dict2 into dict1 (dict2 values override dict1)
    # Handles nested dictionaries recursively

    set result $dict1

    dict for {key value} $dict2 {
        if {[dict exists $result $key]} {
            set existing [dict get $result $key]

            # Check if both are dicts (even-length lists)
            set is_dict1 [expr {[string is list $existing] && [llength $existing] % 2 == 0 && [llength $existing] > 0}]
            set is_dict2 [expr {[string is list $value] && [llength $value] % 2 == 0 && [llength $value] > 0}]

            if {$is_dict1 && $is_dict2} {
                # Both are dicts - merge recursively
                dict set result $key [dict_merge_recursive $existing $value]
            } else {
                # Scalar or list - override
                dict set result $key $value
            }
        } else {
            # New key - add it
            dict set result $key $value
        }
    }

    return $result
}

# ==============================================================================
# Tech Catalog Validation
# ==============================================================================

proc load_tech_catalog {} {
    global TECH_CONFIG
    set catalog [dict create]

    if {[dict exists $TECH_CONFIG available_metal_stacks]} {
        dict set catalog metal_stacks [dict get $TECH_CONFIG available_metal_stacks]
    }
    if {[dict exists $TECH_CONFIG available_std_cell_vts]} {
        dict set catalog std_cells [dict get $TECH_CONFIG available_std_cell_vts]
    }
    if {[dict exists $TECH_CONFIG available_memory_macros]} {
        dict set catalog memories [dict get $TECH_CONFIG available_memory_macros]
    }

    return $catalog
}

proc validate_selection {category selection} {
    set catalog [load_tech_catalog]

    if {![dict exists $catalog $category]} {
        return 0
    }

    set items [dict get $catalog $category]
    foreach item $items {
        if {[dict exists $item name]} {
            set item_name [dict get $item name]
        } elseif {[dict exists $item vt_type]} {
            set item_name [dict get $item vt_type]
        } else {
            continue
        }

        if {$item_name eq $selection} {
            return 1
        }
    }

    return 0
}

proc resolve_config_file {category name} {
    global TECH_CONFIG

    set catalog_key_map [dict create \
        metal_stacks "available_metal_stacks" \
        std_cells "available_std_cell_vts" \
        memories "available_memory_macros" \
    ]

    if {![dict exists $catalog_key_map $category]} {
        error "Unknown catalog category: $category"
    }

    set catalog_key [dict get $catalog_key_map $category]

    if {![dict exists $TECH_CONFIG $catalog_key]} {
        error "Catalog category not found in tech.yaml: $catalog_key"
    }

    set items [dict get $TECH_CONFIG $catalog_key]
    foreach item $items {
        if {[dict exists $item name]} {
            set item_name [dict get $item name]
        } elseif {[dict exists $item vt_type]} {
            set item_name [dict get $item vt_type]
        } else {
            continue
        }

        if {$item_name eq $name} {
            if {[dict exists $item config_file]} {
                return [dict get $item config_file]
            } else {
                error "No config_file defined for $category/$name"
            }
        }
    }

    error "Item not found in tech catalog: $category/$name"
}

# ==============================================================================
# SRAM Macro Loading
# ==============================================================================

proc load_sram_macros {} {
    global SRAM_MACRO_TYPES YAML_PATHS DEFAULT_CONFIGS_DIR PROJECT_NAME

    if {[info exists env(CONFIGS_DIR)]} {
        set configs_dir $env(CONFIGS_DIR)
    } else {
        set configs_dir $DEFAULT_CONFIGS_DIR
    }

    set block_name $env(BLOCK_NAME)

    puts "\n===================================================================="
    puts "Loading SRAM Macros"
    puts "===================================================================="

    # Check mem_list file
    set mem_list_file "$configs_dir/blocks/$block_name/mem_list"
    if {![file exists $mem_list_file]} {
        puts "  ℹ No mem_list found - block has no SRAM macros"
        puts "===================================================================="
        return
    }

    puts "  ✓ Found mem_list: $mem_list_file"

    # Parse mem_list (one macro type per line)
    set fp [open $mem_list_file r]
    set macro_count 0

    while {[gets $fp line] >= 0} {
        set line [string trim $line]
        if {$line eq "" || [string index $line 0] eq "#"} {
            continue
        }

        set macro_type $line

        # Validate against catalog
        if {![validate_selection memories $macro_type]} {
            puts "  ⚠ WARNING: Macro type '$macro_type' not in tech.yaml catalog"
            continue
        }

        # Load macro definition if not already loaded
        if {![dict exists $SRAM_MACRO_TYPES $macro_type]} {
            set config_file [resolve_config_file memories $macro_type]
            set macro_yaml "$configs_dir/$config_file"

            if {![file exists $macro_yaml]} {
                puts "  ⚠ WARNING: Macro YAML not found: $macro_yaml"
                continue
            }

            set macro_def [load_yaml_file $macro_yaml]
            dict set SRAM_MACRO_TYPES $macro_type $macro_def
            incr macro_count
        }
    }

    close $fp

    puts "  ✓ Loaded $macro_count SRAM macro type(s)"

    set unique_types [dict keys $SRAM_MACRO_TYPES]
    if {[llength $unique_types] > 0} {
        puts "  Macro types:"
        foreach mtype $unique_types {
            puts "    - $mtype"
        }
    }

    puts "===================================================================="
}

# ==============================================================================
# Main Config Loader
# ==============================================================================

proc init_yaml_configs {} {
    global TECH_CONFIG PROJECT_CONFIG BLOCK_CONFIG
    global METAL_STACK_CONFIG VT_CONFIGS
    global YAML_PATHS DEFAULT_CONFIGS_DIR

    if {[info exists env(CONFIGS_DIR)]} {
        set configs_dir $env(CONFIGS_DIR)
    } else {
        set configs_dir $DEFAULT_CONFIGS_DIR
    }

    if {![info exists env(BLOCK_NAME)]} {
        error "ERROR: BLOCK_NAME environment variable not set"
    }
    set block_name $env(BLOCK_NAME)

    puts "\n===================================================================="
    puts "YAML Configuration System - Simplified"
    puts "===================================================================="
    puts "Config directory: $configs_dir"
    puts "Block name: $block_name"

    # =========================================================================
    # Load Tech Config
    # =========================================================================
    puts "\n[1/6] Loading tech config..."
    set tech_yaml "$configs_dir/[dict get $YAML_PATHS tech_file]"
    set TECH_CONFIG [load_yaml_file $tech_yaml]
    puts "  ✓ Loaded: $tech_yaml"

    # =========================================================================
    # Load Project Config
    # =========================================================================
    puts "\n[2/6] Loading project config..."
    set project_yaml "$configs_dir/[dict get $YAML_PATHS project_file]"
    set PROJECT_CONFIG [load_yaml_file $project_yaml]
    puts "  ✓ Loaded: $project_yaml"

    # =========================================================================
    # Load Block Config (Optional)
    # =========================================================================
    puts "\n[3/6] Loading block config..."
    set block_yaml "$configs_dir/blocks/$block_name/block.yaml"

    if {[file exists $block_yaml]} {
        set BLOCK_CONFIG [load_yaml_file $block_yaml]
        puts "  ✓ Loaded: $block_yaml"

        # Merge block overrides into project config
        puts "  ✓ Merging block overrides into project config..."
        set PROJECT_CONFIG [dict_merge_recursive $PROJECT_CONFIG $BLOCK_CONFIG]
    } else {
        puts "  ℹ No block config found - using project defaults"
        set BLOCK_CONFIG [dict create]
    }

    # =========================================================================
    # Load Metal Stack (path resolved from tech.yaml)
    # =========================================================================
    puts "\n[4/6] Loading metal stack..."
    set metal_stack_name [dict get $PROJECT_CONFIG metal_stack_selection selected]

    # Resolve path from tech.yaml catalog
    set metal_stack_config_file [resolve_config_file metal_stacks $metal_stack_name]
    set metal_stack_yaml "$configs_dir/tech/${TECH_NAME}/$metal_stack_config_file"

    set METAL_STACK_CONFIG [load_yaml_file $metal_stack_yaml]
    puts "  ✓ Loaded metal stack: $metal_stack_name"
    puts "    From: $metal_stack_config_file"

    # =========================================================================
    # Load VT Configs (paths resolved from tech.yaml)
    # =========================================================================
    puts "\n[5/6] Loading VT configs..."
    foreach vt_type {SVT HVT LVT} {
        # Resolve path from tech.yaml catalog
        if {[catch {resolve_config_file std_cells $vt_type} vt_config_file] == 0} {
            set vt_yaml "$configs_dir/tech/${TECH_NAME}/$vt_config_file"

            if {[file exists $vt_yaml]} {
                set vt_config [load_yaml_file $vt_yaml]
                dict set VT_CONFIGS $vt_type $vt_config
                puts "  ✓ Loaded $vt_type from: $vt_config_file"
            } else {
                puts "  ⚠ WARNING: VT config file not found: $vt_yaml"
            }
        } else {
            puts "  ⚠ WARNING: VT type $vt_type not in tech.yaml catalog"
        }
    }

    # =========================================================================
    # Load SRAM Macros
    # =========================================================================
    puts "\n[6/6] Loading SRAM macros..."
    load_sram_macros

    # =========================================================================
    # Summary
    # =========================================================================
    puts "\n===================================================================="
    puts "Configuration Loading Complete"
    puts "===================================================================="
    puts "Tech: [dict get $TECH_CONFIG technology name]"
    puts "Project: [dict get $PROJECT_CONFIG project name]"

    if {[dict size $BLOCK_CONFIG] > 0} {
        puts "Block config: YES ([dict size $BLOCK_CONFIG] top-level keys)"
        puts "  → To inspect overrides: check BLOCK_CONFIG dict"
    } else {
        puts "Block config: NO (using project defaults)"
    }

    if {[dict size $SRAM_MACRO_TYPES] > 0} {
        puts "SRAM macros: [dict size $SRAM_MACRO_TYPES] type(s)"
    }

    puts "===================================================================="
}

# ==============================================================================
puts "INFO: Simplified YAML Config Reader loaded"
puts "INFO: Call 'init_yaml_configs' to load configurations"
puts "INFO: To inspect block overrides: check BLOCK_CONFIG global variable"
# ==============================================================================
