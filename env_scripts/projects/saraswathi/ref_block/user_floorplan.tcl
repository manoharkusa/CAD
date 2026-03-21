create_floorplan -core_density_size {1 0.7 0.84 0.9 0.84 0.9}

edit_pin -pin_depth 0.6 -fix_overlap 1 -pattern fill_layer -spread_direction clockwise -unit track -spacing 2 -side Top -start 23.31100 95.49050 -end 78.68200 95.22150  -layer {4 6} -pin  [get_db [get_ports *]  .name]
