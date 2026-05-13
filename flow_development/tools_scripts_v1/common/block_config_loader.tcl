
ui_info "Start of block YAML loader script"
###project yaml pointer
set BLOCK_YAML "$env(BLOCK_INPUTS)/block.yaml"
if {[file exists $BLOCK_YAML]} {
	set block_cfg [load_yaml_file $BLOCK_YAML]
} else {
	ui_error "FATAL block yaml file not found $BLOCK_YAML"
	exit 1
}

ui_info "End of block YAML loader script"
