# Project F: FPGA Pong - Create Vivado Project
# (C)2020 Will Green, open source hardware released under the MIT License
# Learn more at https://projectf.io

puts "INFO: Project F - FPGA Pong Project Creation Script"

# If the FPGA board/part isn't set use Arty
if {! [info exists fpga_part]} {
    set fpga_part "xc7a35ticsg324-1L"
}
if {! [info exists board_name]} {
    set board_name "arty"
}

# Set the project name
set _xil_proj_name_ "fpga-pong"

# Set the reference directory for source file relative paths
set origin_dir "./../.."

# Set the directory path for the project
set orig_proj_dir "[file normalize "${origin_dir}/xc7/vivado"]"

# Create Vivado project
create_project ${_xil_proj_name_} ${orig_proj_dir} -part ${fpga_part}

#
# Design sources
#

if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}
set fs_design_obj [get_filesets sources_1]

# Top design sources (not used in simulation)
set top_sources [list \
  [file normalize "${origin_dir}/xc7/top_pong_v1.sv"] \
  [file normalize "${origin_dir}/xc7/top_pong_v2.sv"] \
  [file normalize "${origin_dir}/xc7/top_pong_v3.sv"] \
  [file normalize "${origin_dir}/xc7/top_pong_v4.sv"] \
]
add_files -norecurse -fileset $fs_design_obj $top_sources
set design_top_obj [get_files -of_objects [get_filesets sources_1]]
set_property -name "used_in_simulation" -value "0" -objects $design_top_obj

# Set top module for design sources
set_property -name "top" -value "top_pong_v4" -objects $fs_design_obj
set_property -name "top_auto_set" -value "0" -objects $fs_design_obj

# Design sources (used in simulation)
set design_sources [list \
  [file normalize "${origin_dir}/debounce.sv"] \
  [file normalize "${origin_dir}/display_timings.sv"] \
  [file normalize "${origin_dir}/xc7/clock_gen.sv"] \
]
add_files -norecurse -fileset $fs_design_obj $design_sources

#
# Constraints
#

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}
set fs_constr_obj [get_filesets constrs_1]

set constr_sources [list \
  [file normalize "$origin_dir/xc7/${board_name}.xdc"] \
]
add_files -norecurse -fileset $fs_constr_obj $constr_sources
set constr_file_obj [get_files -of_objects [get_filesets constrs_1]]
set_property -name "file_type" -value "XDC" -objects $constr_file_obj

#
# Done
#

puts "INFO: Project created:${_xil_proj_name_}"
