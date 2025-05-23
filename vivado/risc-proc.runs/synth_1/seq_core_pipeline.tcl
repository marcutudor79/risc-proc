# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
namespace eval ::optrace {
  variable script "D:/_code/risc-proc/vivado/risc-proc.runs/synth_1/seq_core_pipeline.tcl"
  variable category "vivado_synth"
}

# Try to connect to running dispatch if we haven't done so already.
# This code assumes that the Tcl interpreter is not using threads,
# since the ::dispatch::connected variable isn't mutex protected.
if {![info exists ::dispatch::connected]} {
  namespace eval ::dispatch {
    variable connected false
    if {[llength [array get env XILINX_CD_CONNECT_ID]] > 0} {
      set result "true"
      if {[catch {
        if {[lsearch -exact [package names] DispatchTcl] < 0} {
          set result [load librdi_cd_clienttcl[info sharedlibextension]] 
        }
        if {$result eq "false"} {
          puts "WARNING: Could not load dispatch client library"
        }
        set connect_id [ ::dispatch::init_client -mode EXISTING_SERVER ]
        if { $connect_id eq "" } {
          puts "WARNING: Could not initialize dispatch client"
        } else {
          puts "INFO: Dispatch client connection id - $connect_id"
          set connected true
        }
      } catch_res]} {
        puts "WARNING: failed to connect to dispatch server - $catch_res"
      }
    }
  }
}
if {$::dispatch::connected} {
  # Remove the dummy proc if it exists.
  if { [expr {[llength [info procs ::OPTRACE]] > 0}] } {
    rename ::OPTRACE ""
  }
  proc ::OPTRACE { task action {tags {} } } {
    ::vitis_log::op_trace "$task" $action -tags $tags -script $::optrace::script -category $::optrace::category
  }
  # dispatch is generic. We specifically want to attach logging.
  ::vitis_log::connect_client
} else {
  # Add dummy proc if it doesn't exist.
  if { [expr {[llength [info procs ::OPTRACE]] == 0}] } {
    proc ::OPTRACE {{arg1 \"\" } {arg2 \"\"} {arg3 \"\" } {arg4 \"\"} {arg5 \"\" } {arg6 \"\"}} {
        # Do nothing
    }
  }
}

OPTRACE "synth_1" START { ROLLUP_AUTO }
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
OPTRACE "Creating in-memory project" START { }
create_project -in_memory -part xc7z010iclg225-1L

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir D:/_code/risc-proc/vivado/risc-proc.cache/wt [current_project]
set_property parent.project_path D:/_code/risc-proc/vivado/risc-proc.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo d:/_code/risc-proc/vivado/risc-proc.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
OPTRACE "Creating in-memory project" END { }
OPTRACE "Adding files" START { }
read_verilog D:/_code/risc-proc/vivado/risc-proc.srcs/sources_1/new/seq_core.vh
read_verilog -library xil_defaultlib {
  D:/_code/risc-proc/vivado/risc-proc.srcs/sources_1/new/compute_dep_exec.v
  D:/_code/risc-proc/vivado/risc-proc.srcs/sources_1/new/compute_dep_exec_floating.v
  D:/_code/risc-proc/vivado/risc-proc.srcs/sources_1/new/compute_dep_wb.v
  D:/_code/risc-proc/vivado/risc-proc.srcs/sources_1/new/data_dep_ctrl.v
  D:/_code/risc-proc/vivado/risc-proc.srcs/sources_1/new/execute.v
  D:/_code/risc-proc/vivado/risc-proc.srcs/sources_1/new/execute_floating_point.v
  D:/_code/risc-proc/vivado/risc-proc.srcs/sources_1/new/fetch.v
  D:/_code/risc-proc/vivado/risc-proc.srcs/sources_1/new/read.v
  D:/_code/risc-proc/vivado/risc-proc.srcs/sources_1/new/regs.v
  D:/_code/risc-proc/vivado/risc-proc.srcs/sources_1/new/write_back.v
  D:/_code/risc-proc/vivado/risc-proc.srcs/sources_1/new/seq_core_pipeline.v
}
OPTRACE "Adding files" END { }
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

OPTRACE "synth_design" START { }
synth_design -top seq_core_pipeline -part xc7z010iclg225-1L
OPTRACE "synth_design" END { }
if { [get_msg_config -count -severity {CRITICAL WARNING}] > 0 } {
 send_msg_id runtcl-6 info "Synthesis results are not added to the cache due to CRITICAL_WARNING"
}


OPTRACE "write_checkpoint" START { CHECKPOINT }
# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef seq_core_pipeline.dcp
OPTRACE "write_checkpoint" END { }
OPTRACE "synth reports" START { REPORT }
generate_parallel_reports -reports { "report_utilization -file seq_core_pipeline_utilization_synth.rpt -pb seq_core_pipeline_utilization_synth.pb"  } 
OPTRACE "synth reports" END { }
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
OPTRACE "synth_1" END { }
