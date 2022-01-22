namespace eval uvmtcl {
    namespace export uvm_set uvm_get uvm_message uvm_component uvm_config_db uvm_factory uvm_phase uvm_objection uvm_version help

    catch { rename help ncsim_builtin_help } e

    # Generic parameters
    array set constants { UNDEF            -1
                          SET_VERBOSITY     0
                          GET_VERBOSITY     1
                          SET_ACTIONS       2
                          GET_ACTIONS       3
                          SET_STYLE         4
                          GET_STYLE         5
                          SET_SEVERITY      6
                          GET_SEVERITY      7
                          ANYSET          100 }


    proc isnumber {value} {
	set v [string index $value 0]
	if { $v >= 0 && $v <= 9 } { return 1 }
	if { $v == "'" } { return 1 }
	return 0 
    }

    variable verbosity_list {NONE 0 LOW 100 MEDIUM 200 HIGH 300 FULL 400 DEBUG 500}
    variable severity_list {INFO 0 WARNING 1 ERROR 2 FATAL 3}
    
    proc lookup_table { key table } {
	array set a $table
	regsub "^UVM_" $key "" key

	if { [info exists a($key)] } {
	    return  $a($key)
	} elseif { [isnumber $key] } {
	    return $key
	} else {
	    puts "uvm: *E,UVMCMD: \"$key\" is neither a number nor a predefined constant"
	}
    }

    # FIXME is native in tcl 8.5
    proc lreverse { lst } {
	set reversed {}
	for {set i [llength $lst]} {[incr i -1] >= 0} {} {lappend reversed [lindex $lst $i]}
	return $reversed
    }

    proc verbosity_to_value { verbosity } {
        variable verbosity_list   
	lookup_table $verbosity $verbosity_list
    }

    proc severity_to_value { severity } {
        variable severity_list   
	lookup_table $severity $severity_list
    }

    proc value_to_verbosity { value } {
        variable verbosity_list   
	lookup_table $value [lreverse $verbosity_list]
    }

    proc value_to_severity { value } {
        variable severity_list   
	lookup_table $value [lreverse $severity_list]
    }

    proc is_severity_value { value } {
        variable severity_list   
	regsub "^UVM_" $value "" value
	array set a $severity_list
	info exists a($value)
    }

    proc is_verbosity_value { value } {
        variable verbosity_list   
        regsub "^UVM_" $value "" value
        array set a $verbosity_list
	info exists a($value)
    }

    proc uvm_get_result {} {
	set result ""
	if { ! [file exists .uvmtclcomm.txt] } { return "" }
	set fid [open .uvmtclcomm.txt r]
	if { [gets $fid result] != -1 } {
	    while { [gets $fid line] != -1 } {
		set result "$result\n$line"
	    } 
	}
	return $result
    }

    proc do_command { args } {
	if { [catch { set r [eval $args] } e ] } {
	    if { [regexp OBJACC $e] } {
		puts "uvm: *E,UVMACC: UVM commands require read/write access for the verilog functions which implement the commands"
	    } else { 
		return -code return $e
	    }
	    return "command failed"
	}
	return $r
    }

    proc help args {
	if { [llength $args] == 0 } {
	    puts ""
	    puts "UVM commands:"
	    puts ""
	    puts "uvm_component uvm_get     uvm_message uvm_phase   uvm_set     uvm_version"
	    puts "uvm_objection uvm_factory uvm_config_db" 
	    puts [ncsim_builtin_help]
	    return;
	}
	foreach i $args {
	    if { $i == "uvm_component" } {
		puts "uvm_component................Get information on UVM components"
		puts "    -list....................List all UVM components"
		puts "    -tops....................Print top level components"
		puts "    -describe <names>........Print one or more UVM component."
		puts "        <names>..............List of components to describe"
		puts "        -depth <depth>.......The depth of the component hierarchy"
		puts "                             to display (the default is 1). A depth"
		puts "                             of -1 recurses the full hierarchy"
	    } elseif { $i == "uvm_get" } {
		puts "uvm_get <name> <field>........Get the value of a variable from a"
		puts "                              component. The component name can"
		puts "                              be a wildcarded name. The field"
		puts "                              must exist in the component."
	    } elseif { $i == "uvm_message" } {
		puts "uvm_message...................Access the UVM messaging service. Is currently"
		puts "                              used for getting and setting verbosity values."
		puts "    <verbosity> <comp>........Set the verbosity for a component"
		puts "                              The component may be a wildcard. Verbosity"
		puts "                              may be an integer or an UVM verbosity value."
		puts "    -file <file>..............Specify a file name (currently for e messages"
		puts "                              only)."
		puts "    -get_verbosity <comp>.....Get the verbosity of a specific component."
		puts "                              If more than one component matches the comp"
		puts "                              name, the first value is returned."
		puts "    -hier <comp>..............Explicitly specify the component (glob style"
		puts "                              patterns are used). This argument is optional."
		puts "                              An argument that is not a severity value will"
		puts "                              be taken as the component setting."
		puts "    -tag <tag>................Specify a tag (currently for e messages only)."
		puts "    -text <text>..............Specify a text (currently for e messages only)."
		puts "    -set_action [-id <id>] <comp> <actions>"
		puts "                              set the action for the message <id> (or all id's)"
		puts "                              for components matching comp"
		puts "    -set_severity [-id <id>] <comp> <severity>"
		puts "                              set the severity for the message <id> (or all id's)"
		puts "                              for components matching comp" 
	        puts "    -stop_on_error <ON/OFF>"
		puts "                              set the stop on error on and off"
		puts "                              it this is enabled 'on' then simulation"
                puts "                              will stop whenever UVM_ERROR occured"   
		puts "    -hyperlinks <on|off|get>  enable|disable|query hyperlinked UVM messages"   
	    } elseif { $i == "uvm_phase" } {
		puts "uvm_phase <option>...........Access the phase interface for breaking on "
		puts "                             phases, or executing stop requests on phases."
		puts "                             Phases may be from the common domain (build"
		puts "                             through final) of from the runtime uvm domain"
		puts "                             (pre_reset through post_shutdown)."
		puts "    -delete <id>.............Remove a previously set -stop_at break point."
		puts "                             (behaves like uvm_phase -remove_stop <id>)."
		puts "    -remove_stop <type> <id / hash / name>"
		puts "                             Remove a previously set -stop_at break point. For"
		puts "                             stop-naming, see the -stop_at"
		puts "        -counter <id>........Delete a break by it's counter id. This is the"
		puts "                             default type."
		puts "        -unique <hash>.......Delete a break by it's unique hash sequence."
		puts "        -full <name>.........Delete a break by it's full name as shown in"
		puts "                             \"get_all_uvm_stops\"."
		puts "    -get <options>...........Get the name of the current phase. This is the"
		puts "                             default option if no other options are specified."
		puts "         -new............... Get the name of the active phase with enhanced"
		puts "                             details <scheduler>.<phase_name>:<phase_state>"
		puts "         -all................Enhanced details which included completed phase"
		puts "                             \"-all\" should be combined with new"		
                puts "    -run <phase name>........Run to the desired phase."
		puts "    -stop_at <phase name> <options>"
		puts "                             Set a break point on the specified phase. By"
		puts "                             default, the break will occur at the start of"
		puts "                             the phase. A standard tcl break point (using the"
		puts "                             stop commmand) is issued. All options after the"
		puts "                             phase name are sent to the stop command. Use"
		puts "                             \"help stop\" for a list of options that can be used."
		puts "                             Stop name will be set to \"<counter>:<unique>:uvm\""
		puts "      -build_done............{ Deprecated }Sets a callback when the primary environment"
		puts "                              build out (from the run_test() command) is complete"
		puts "      -end...................Set the callback for the end of the phase."
		puts "      -stop_args <argset>....Set of arguments can be provided to stop command"
                puts "                             all the valid options \"help stop\" can be used"
		puts "    -stop_request............Execute a global stop request for the current"
		puts "                             phase."
              } elseif { $i == "uvm_set" } {
		puts "uvm_set <name> <field> <value>"
		puts "                             Set <field> for unit <name>."
		puts "    -config                  Apply the set to a configuration parameter. This"
		puts "                             means that the setting will not be applied until"
		puts "                             the specified component updates its configuration"
		puts "                             (which normally occurs during build()."
		puts "                             "
		puts "                             If field is 'default_sequence', then the component"
		puts "                             target is assumed to be a <sequencer>.<phase>."
		puts "                             The value is used to find the factory wrapper in"
		puts "                             factory and then the uvm_config_db#"
		puts "                             (uvm_object_wrapper::set() is used to perform"
		puts "                             the setting."
		puts "    -type int | string.......Specify the type of object to set." 
		puts "                             If type is not specified then if value "
		puts "                             is an integral value, int is assumed,"
		puts "                             otherwise string is assumed. For non-config sets"
		puts "                             the field must exist in the component."
	    } elseif { $i == "uvm_objection" } {
		puts "uvm_objection................Print current objection status"
		puts "    -all                     also include all objections with no raised objection"
	    } elseif { $i == "uvm_config_db" } {
		puts "uvm_config_db................Provides access to the config_db data store"
		puts "    -dump[-audit]            Dump all values stored in the data store,Include audit trail using -audit."
		puts "    -trace on|off            Enables/disables tracing of config_db accesses (UVM_INFO+UVM_LOW)"
		puts "    -audit on|off            Enables/disables the audit log when the config_db is accessed"
	    } elseif { $i == "uvm_factory" } {
		puts "uvm_factory..................Provides access to the UVM factory"
		puts "    -print \[-all_types\]      Print the contents of the UVM factory"
		puts "    -override                Provide override information for the factory"
		puts "       -by_type oldType newType             Override by type and replace oldType"
		puts "                                            with newType in factory"
		puts "       -by_instance oldType newType path    Override by instance and replace"
		puts "                                            oldType with newType for instance path"
		puts "    -debug typeName parentPath instName     provides factory analysis when attempting"
		puts "                                            to create an instance of typeName"
		puts "                                            at parentPath.instName"         
	    } elseif { $i == "uvm_version" } {
		puts "uvm_version..................Get the UVM library version."
	    } else {
		puts [ncsim_builtin_help $i]
	    }
	}
    }

proc uvm_get args {
  if { [cdns_help_evaluate $args] } { return }
  set re "(.*\s?.*?)$" 
  set isOk [cdns_validate_command $re [info level 0] $args]
 
  if { ![cdns_validate [info level 0] uvm cdnsextn ] } { return "command aborted" }

if { $isOk } {
  set num [llength $args]
  if { $num < 2 && [lindex $args 0] != "-help" } {
    puts "uvm_get <name> <field>"
    return
  }
  if { $num < 2 && [lindex $args 0] == "-help" } {
    help uvm_get 
    return
  }


  set name [lindex $args 0]
  set field [lindex $args 1]

  for {set i 2} {$i < [llength $args]} {incr i} {
    set value [lindex $args $i]
    if { $value == "-help" } {
      help uvm_get 
      return
    } elseif { [string index $value 0] == "-" } {
      puts "uvm: *E,UNKOPT: unrecognized option for the uvm_get command ($value)."
      return
    } elseif { $value != "" } {
      puts "uvm: *E,UNKOPT: unrecognized option for the uvm_get command ($value)."
      return
    }
  }
  if { [regexp {[*?]} $field ] } {
    puts "uvm: *E,NOWLCD: Wildcard field name, $field, not allowed for uvm_get"
    return
  }

  set comps [uvm_component -describe $name -depth 0]
  if { [regexp {@[0-9]+} $comps comp] } {
    return [do_command value ${comp}.${field}]
  } else {
    puts "uvm: *E,NOMTCH: Did not match any components to $name"
  }
  }
}

proc uvm_set args {
  variable constants 
  if { [cdns_help_evaluate $args] } { return }
  set re "((.*\\s+.*\\s+.*)|-(config?|type(\\s+(int|string))))$"

  set isOk [cdns_validate_command $re [info level 0] $args]

  if { ![cdns_validate [info level 0] uvm cdnsextn ] } { return "command aborted" }
  if { $isOk } {
  set num [llength $args]
  if { $num < 3 && [lindex $args 0] != "-help" } {
    puts "uvm_set <name> <field> <value>"
    return
  }
  if { $num < 3 && [lindex $args 0] == "-help" } {
    help uvm_set 
    return
  }


  set name $constants(UNDEF) 
  set field $constants(UNDEF)
  set int 0 
  set str 0 
  set config 0
  set v 0

  for {set i 0} {$i < [llength $args]} {incr i} {
    set value [lindex $args $i]
    if { $value == "-help" } {
      help uvm_set 
      return
    } elseif { $value == "-config" } {
      set config 1
    } elseif { $value == "-type" } {
      incr i
      set value [lindex $args $i]
      if { $value == "int" } {
        set int 1
      } elseif { $value == "string" } {
        set str 1
      } else {
        puts "Error: illegal type [lindex $args $i] specifed with -type option"
      }
    } elseif { [string index $value 0] == "-" } {
      puts "uvm: *E,UNKOPT: unrecognized option for the uvm_set command ($value)."
      return
    } else {
      if { $name == -1 } { 
        set name $value 
      } elseif { $field == -1 } {
        set field $value
      } else {
        set v $value
      }
    }
  }
  if { ($name == -1)  || ($field == -1) } {
     puts "uvm: *E,ILLCL: uvm_set requires a unit and a field"
     return
  } 
  if { $int == 0 && $str == 0 } {
    if { [is_verbosity_value $v] } {
      set v [verbosity_to_value $v]
    } elseif { [is_severity_value $v] } {
      set v [severity_to_value $v]
    }
    if { [isnumber $v] } {
      set int 1
      set str 0
    } else {
      set int 0
      set str 1
    }
  }
  if { $int == 0 && $str == 0 } {
    puts "Error: no value given for setting field $field"
    return
  }
  if { $int == 1 && $config == 1} {
    call tcl_uvm_set \"$name\" \"$field\" $v $config
  } elseif { $config == 1} {
    call tcl_uvm_set_string \"$name\" \"$field\" \"$v\" $config
  } else {
    set comps [uvm_component -describe $name -depth 0]
    set cnt 0
    if { [regexp {@[0-9]+} $comps comp] } {
      foreach  i [split $comps] {
        if { [regexp {@[0-9]+} $i comp] } {
          if { $int == 1} {
            if { ! [catch { set r [do_command deposit ${comp}.${field} $v] } e ] } {
              incr cnt  
          }} else {
            if { ! [catch { set r [do_command deposit ${comp}.${field} \"$v\"] } e ] } {
              incr cnt  
          }}
    }}}
    if { $cnt == 0 } {
        puts "uvm: *E,NOMTCH: Did not match any components to $name for field $field"
    }
  }}
 
}
proc uvm_component args {
  set depth "default"
  set ll   0
  set desc 0
  set tops  0
  set names [list]

  if { [cdns_help_evaluate $args] } { return }
  set re "-(list\\s?.*|tops|(describe\\s+.*\\s?((-?d?e?p?t?h?)\\s?.*?))|depth\\s?.*?)$"

  set isOk [cdns_validate_command $re [info level 0] $args]

 
  if { ![cdns_validate [info level 0] uvm cdnsextn ] } { return "command aborted" }

  if { [llength $args] == 0 } {
    puts "uvm_component <options>"
    return
  }

if { $isOk } {
 
  for {set i 0} {$i < [llength $args]} {incr i} {
    set value [lindex $args $i]
    if { $value == "-depth" } {
      incr i
      set depth [lindex $args $i] 
    } elseif { $value  == "-list" } {
      set ll 1
    } elseif { $value  == "-help" } {
      help uvm_component
      return
    } elseif { $value  == "-describe" } {
      set desc 1
    } elseif { $value  == "-tops" } {
      set tops 1
      set desc 1
    } elseif { [string index $value 0] == "-" } {
      puts "uvm: *E,UNKOPT: unrecognized option for the uvm_component command ($value)."
      return
    } else {
      lappend names $value
    }
  }
  if { ("$depth" == "default") && ($tops == 1)} {
    set depth 0
  } elseif {$depth == "default" } {
    set depth 1
  }
  if { $ll == 1 } { 
    call tcl_uvm_list_components 1
    set rval [uvm_get_result]
    if { [llength $names] != 0 } {
      set l {}
      set rl [split $rval "\n"]
      set rl [lrange $rl 1 [ expr [llength $rl] -2] ]
      set nm  [join $names " "]
      foreach i $rl {
        foreach pattern $names {
          if [string match $pattern [lindex [split $i " "] 0] ] { lappend l $i }
      } }
      if { [llength $l] == 0 } {
        set rval "No uvm components match the input name(s): $nm" 
      } else {
        set match [join $l "\n"]
        set rval "List of uvm components matching the input name(s): $nm\n$match"
      }
    }
    return $rval
  } 
  if { $desc == 1 } {
    if { $tops == 1 } {
      call tcl_uvm_print_components $depth 0 1
      set rval [uvm_get_result]
      return $rval
    } else {
      if { [llength $names] == 0 } {
        puts "uvm: *E,ILLOPT: the -describe option requires a component name"
      }
      set rval ""
      foreach name $names {
        call tcl_uvm_print_component \"$name\" $depth 1
        if { $rval != "" } { set rval "$rval\n" }
        set rval "${rval}[uvm_get_result]"
      }
    }
      return $rval
    }
  } elseif { [llength $names] != 0 } {
    puts "uvm: *E,NOACT: no action specified for the components \"$names\""
  } else {
    puts "uvm: *E,ILLOPT: illegal usage of the uvm_component command"
    }
  }

    proc m_uvm_message_formatter_installed args {
	if { [ catch "value uvm_pkg::uvm_report_server::m_global_report_server.delegate" err_msg ] } { return 0 }  else { return 1 }
    }

proc uvm_message args {

	variable constants 

        set get 0
	set value $constants(UNDEF)
	set hier "*"
	set file "*"
	set text_val "*"
	set tag ""

	if { [cdns_help_evaluate $args] } { return }	
	if { ![cdns_validate [info level 0] uvm cdnsextn ] } { return "command aborted" }

	if {[regexp -line -- "^-set_(action|severity)" $args]} {
	    #
	    # set message severity|action 
	    # action might be UVM_STOP|UVM_COUNT
	    #
	    if { [cdns_help_evaluate $args] } { return }
	    set re "-(set_(action|severity))\\s+(-id\\s+(\\S+)\\s+)?(\\S+)\\s+(\\S+)"
	    set isOk [cdns_validate_command $re [info level 0] $args]
	    if { ![cdns_validate [info level 0] uvm cdnsextn ] } { return "command aborted" }
	    
	    if { $isOk } {
		regexp -line -- $re $args v1 v2 v3 v4 v5 v6 v7
		switch -regexp -- $args {
		    "-set_action" { call tcl_uvm_message_set 0 \"$v5\" \"$v6\" \"$v7\"} 
		    "-set_severity" { call tcl_uvm_message_set 1 \"$v5\" \"$v6\" \"$v7\" }
		    default { cdns_assert 0 "this should never happen" }
		}
	    }
	    
	    return
	}
       
        if {[regexp -line -- "^-stop_on_error" $args]} {
	    #
	    # set message severity|action 
	    # action might be UVM_STOP|UVM_COUNT
	    #
	    if { [cdns_help_evaluate $args] } { return }
	    set re "-(stop_on_error\\s+(ON|OFF))"
            set isOk [cdns_validate_command $re [info level 0] $args]
	    if { ![cdns_validate [info level 0] uvm cdnsextn ] } { return "command aborted" }
	    
	    if { $isOk } {
		regexp -line -- $re $args v1 v2 v3 v4 v5 v6 v7
		switch -regexp -- $args {
		    "-stop_on_error" { call tcl_uvm_message_set 2 \"$v5\" \"$v6\" \"$v2\" }
                    default { cdns_assert 0 "this should never happen" }
		}
	    }
	    
	    return
	}
	
	# uvm_message -hyperlinks <on|off>  
	if {[regexp -line -- "^-hyperlinks" $args]} {
	    if { [cdns_help_evaluate $args] } { return }
	    set re "-hyperlinks\\s+(on|off|get)"
	    set isOk [cdns_validate_command $re [info level 0] $args]
	    if { ![cdns_validate [info level 0] uvm] } { return "command aborted" }
	    
		if { $isOk } {
		    regexp -line -- $re $args v1 v2 v3 v4 v5 v6 v7
		    switch -regexp -- $args {
			"-hyperlinks" { call tcl_uvm_message_hyperlinks [cdns_get_on_off_mapping $v2] } 
			default { cdns_assert 0 "this should never happen" }
		    }
		}
	              	
	if { [value cdns_uvm_pkg::cdns_tcl_uvm_message_hyperlinks.status] ==1 } {
                  return "uvm: *I,UVMTCL: UVM message hyperlinks enabled"     
                } else { 
                  return "uvm: *I,UVMTCL: UVM message hyperlinks disabled"     
                }
	}
	
	for {set i 0} {$i < [llength $args]} {incr i} {
	    set argvalue [lindex $args $i]
	    if { $argvalue  == "-help" } {
		help uvm_message
		return
	    } elseif {$argvalue == "-tag" } {
		incr i
		set tag [lindex $args $i]
	    } elseif {$argvalue == "-text" } {
		incr i
		set text_val [lindex $args $i]
	    } elseif {$argvalue == "-file" } {
		incr i
		set file [lindex $args $i]
	    } elseif {$argvalue == "-verbosity" } {
		incr i
		set value [lindex $args $i]
	    } elseif {$argvalue == "-get_verbosity" } {
		set get 1
	    } elseif {$argvalue == "-set_verbosity" } {
		set get 0
	    } elseif {$argvalue == "-hier" } {
		set hier $argvalue
	    } elseif { [string index $argvalue 0] == "-" } {
		puts "uvm: *E,UNKOPT: unrecognized option for the uvm_message command ($argvalue)."
		return
	    } else {
		if { [is_verbosity_value $argvalue] } {
		    set value [verbosity_to_value $argvalue]
		} elseif { [isnumber $argvalue] } {
		    set value [verbosity_to_value $argvalue]
		} else {
		    set hier $argvalue
		}
	    }
	}
	if { [llength $args] == 0 } {
	    puts "uvm_message \"\" \[-get_verbosity\] [options] <verbosity> <component>"
	    return
	} 

	if { $get == 0 } {
	    set value_type $constants(SET_VERBOSITY)
	    call tcl_uvm_set_message $value_type \"$hier\" \"$file\" \"$text_val\" \"$tag\" $value
	} else {
	    set value_type $constants(GET_VERBOSITY)
	    return [tcl_get_message $hier \"\"]
	}
    }

    proc get_all_uvm_stops args {
	set n 0
	set retval ""
	set len [ string length [ stop -show ] ]
	if { [ stop -show ] != "No stops set\n" } {
	    while { $n < $len && $n != -1 } {
		set substr [string range [ stop -show ] $n $len ]
		set curr_elem [ string range $substr 0 [ string first " " $substr ] ]
		set retval "$retval $curr_elem"
		set n [ expr [ string first "\n" [ stop -show ] $n ] + 1 ]
	    }
	}
	return $retval
    }

    proc remove_break_by {t b} {
	set brks [ get_all_uvm_stops ]
	set found 0
	set indx 0
	if { $t == "-counter" } {
	    while { $found == 0 && $indx < [ llength $brks ] } {
		set rmbrk [ lindex $brks $indx ]
		if { [ string first $b $rmbrk ] == 0 } {
		    set found 1
		}
		incr indx
	    }
	} else {
	    set loc [ string first $b $brks ]
	    if { $loc != -1 } {
		set rmbrk [ lindex $brks [ expr [ llength [ string range $brks 0 $loc ] ] - 1 ] ]
		set found 1
	    }
	}
	if { $found == 1 } {
	    stop -delete $rmbrk
	    puts "Stop \"$rmbrk\" was removed"
	}
	return $found   
    }

    proc get_jenkins_hash {str} {
	set res 0
	set len [ string length $str ]
	for { set idx 0 } { $idx < $len } { incr idx } {
	    set char [ string index $str $idx ]
	    scan $char %c ascii
	    set res [ expr $res + $ascii ]
	    set res [ expr $res + [ expr $res << 10 ] ]
	    set res [ expr $res ^ [ expr $res >> 6 ] ]
	}
	set res [ expr $res + [ expr $res << 3 ] ]
	set res [ expr $res ^ [ expr $res >> 11 ] ]
	set res [ expr $res + [ expr $res << 15 ] ]
	set res [ format "%08x" $res ]
	return $res
    }

proc uvm_phase args {
  variable constants
  global stop_counter

  set break_phase $constants(UNDEF)
  set run_phase $constants(UNDEF)
  set pre 1
  set get $constants(UNDEF)
  set stop_req $constants(UNDEF)
  set stop_options $constants(UNDEF)
  set ph_cmd ""
 
  if { ![cdns_validate [info level 0] uvm cdnsextn ] } { return "command aborted" }
   if { [llength $args] == 0 } { 
    call tcl_uvm_get_phase
    set rval [uvm_get_result]
    return $rval
 }

  if { [cdns_help_evaluate $args] } { return }
  set re "-((delete\\s+\\w*)|(remove_stop\\s+(-(counter\\s+\\w*|unique\\s+\\w*|full\\s+\.*)))|(get\\s?(-new)?\\s?(-all)?)|(run\\s+\\w*)|(stop_at\\s+-?\\w*?\\s?\\w*?\\s?.*?)|stop_request)$"

  set isOk [cdns_validate_command $re [info level 0] $args]		
if { $isOk } {
  for {set i 0} {$i < [llength $args]} {incr i} {
    set argvalue [lindex $args $i]
    if { $argvalue  == "-help" } {
      help uvm_phase
      return
    } elseif { $argvalue == "-delete" || $argvalue == "-remove_stop" } {
      set cmd $argvalue
      incr i
      set argvalue [lindex $args $i]
      if { $cmd == "-delete" || [ string index $argvalue 0 ] != "-" } {
        set valtype "-counter"
      } elseif { $argvalue == "-counter" || $argvalue == "-unique" || $argvalue == "-full" } {
        set valtype $argvalue
        incr i
        set argvalue [ lindex $args $i ]
      } else {
        puts "uvm: *E,UNKOPT: unrecognized option for the $cmd option ($argvalue)."
      }
      if { ( $valtype == "-unique" && [ regexp {^[0-9,a-f]{8}$} $argvalue ] != 1 ) ||
           ( $valtype == "-counter" && [ regexp {^[1-9](\d)*$} $argvalue ] != 1 ) ||
           ( $valtype == "-full" && [ regexp {^[1-9](\d)*:[0-9,a-f]{8}:uvm$} $argvalue ] != 1)  } {
        if { $cmd == "-delete" } { set valtype $cmd }
        puts "uvm: *E.ILLARG: break point \"$argvalue\" is not a \"$valtype\" valid argument."
        unset valtype
      }
      if { [ info exists valtype ] == 1 && [ remove_break_by $valtype $argvalue ] == 0 } {
        puts "uvm: *E,ILLBRK: break point \"$argvalue\" is not valid."
      }
      return
      } elseif { $argvalue == "-stop_at" } {
      incr i 
      set argvalue [lindex $args $i]
      incr i
      set  argvalue1 [lindex $args $i]
      if { $argvalue1 == "-end" } {
           set pre 0
      } elseif { $argvalue1 == "-begin" } {
           set pre 1
      } elseif { $argvalue== "-build_done" || $argvalue1 == "-build_done" } {
           puts "uvm: *W,DEPUVM: \"-build_done\" Option is Deprecated, please use \"-stop_at build\" instead"
           set break_phase "uvm_build_complete"
      } elseif { $argvalue1 == "-stop_args" } {
           incr i
           while { $i < [llength $args] } {
             if {$stop_options == -1 } { set stop_options ""}
             set stop_options "$stop_options \{[lindex $args $i]\}"
             incr i
      } } elseif { [string index $argvalue 0] == "-" } {
          if { $argvalue=="-begin" } {
                                      set break_phase $argvalue1
                              } else {
        puts "uvm: *E,UNKOPT: unrecognized option/command for the -stop_at option ($argvalue), please provide -stop_at <phase_name> <options>"
        return }
      } else {
         if {$argvalue1!=""} { puts "uvm: *E,UNKOPT: unrecognized option/command for the -stop_at option ($argvalue), please provide -stop_at <phase_name> <options>" 
                               return
                             } else { set break_phase $argvalue }
      }
      incr i
      set  argvalue2 [lindex $args $i]
      if  { $argvalue2 == "-stop_args" } { 
      incr i
           while { $i < [llength $args] } {
             if {$stop_options == -1 } { set stop_options ""}
             set stop_options "$stop_options \{[lindex $args $i]\}"
             incr i
      } }
      if { $break_phase == $constants(UNDEF) } { set break_phase $argvalue; }
    } elseif { $argvalue == "-get" } {
       incr i
       set  argvalue1 [lindex $args $i]
       incr i
       set  argvalue2 [lindex $args $i]
       if { $argvalue1 == "-new" } { if { $argvalue2 == "-all"} { set get 3 } else { set get 2  } } else { set get 1 }
    } elseif { $argvalue == "-run" } {
      incr i
      set run_phase [lindex $args $i]
    } elseif { ($argvalue == "-stop_request") || ($argvalue == "-global_stop_request") } {
      set stop_req 1
    } else {
      puts "uvm: *E,UNKOPT: unrecognized option for the uvm_phase command ($argvalue)."
      return
    }
  }
  if { (($get != $constants(UNDEF)) && (($break_phase != $constants(UNDEF)) || ($run_phase != $constants(UNDEF))) ) ||
       (($get != $constants(UNDEF)) && (($stop_req != $constants(UNDEF)) || ($run_phase != $constants(UNDEF))) ) ||
       (($break_phase != $constants(UNDEF)) && (($stop_req != $constants(UNDEF)) || ($run_phase != $constants(UNDEF)))) } {
    puts "uvm: *E,ILLARG: Only one operation may be specified: set break, get phase, set stop request, or run phase"
    return
  }
  if { $get == 1 } {
    call tcl_uvm_get_phase
    set rval [uvm_get_result]
    return $rval
  } elseif { $get == 2 } {
    call tcl_uvm_get_phase_new 1 
  } elseif { $get == 3 } {
    call tcl_uvm_get_phase_new 2
  } elseif { $stop_req == 1 } {
    task cdns_uvm_pkg::cdns_tcl_global_stop_request
  } elseif { $break_phase != $constants(UNDEF) } {
    if { $break_phase == "uvm_build_complete" } {
      set ph_cmd "$ph_cmd -build_done"
      set stop_cmd "stop -object cdns_uvm_pkg::uvm_build_complete"
      if {$stop_options != $constants(UNDEF)} {
        set stop_cmd "$stop_cmd $stop_options"
        set ph_cmd "$ph_cmd $stop_options"
      }
    } else  {
      regsub {_phase$} $break_phase "" break_phase
      set stop_cmd "stop -create -object cdns_uvm_pkg::cdns_uvm_data_valid -if \{\#cdns_uvm_pkg::uvm_break_phase == \"$break_phase\" && \#cdns_uvm_pkg::uvm_phase_is_start == $pre\}"
      if {[m_supports_label]} {
       if {$pre} { set stop_cmd "$stop_cmd -label \"begin-of-$break_phase\" " } else { set stop_cmd "$stop_cmd -label \"End-of-$break_phase\" " }  
      }
      if {$pre} { set ph_cmd "$ph_cmd -stop_at $break_phase -begin" } else { set ph_cmd "$ph_cmd -stop_at $break_phase -end" }
      if {$stop_options != $constants(UNDEF)} {
        set stop_cmd "$stop_cmd $stop_options"
        set ph_cmd "$ph_cmd $stop_options"
      } 
    }
    set brk_name [ string range [ get_jenkins_hash $ph_cmd ] 0 7 ]
    set brks [ get_all_uvm_stops ]
    set indx [ string first $brk_name $brks ]
    if { $indx != "-1" } {
      set brk_full_name [ lindex $brks [ expr [ llength [ string range $brks 0 $indx ] ] - 1 ] ]
      return "Stop $brk_full_name already exists"
    }
    if { [ catch "incr stop_counter" err_msg ] == 1 } { set stop_counter 1 }
    set brk_full_name "$stop_counter\:$brk_name\:uvm"
    set stop_cmd "$stop_cmd -name $brk_full_name"
    set tmp [split [eval $stop_cmd] " "]
    set tmp [lindex $tmp 2]
    set tmp [lindex [split $tmp "\n"] 0]
    return "Created stop $tmp"
  } elseif { $run_phase != $constants(UNDEF) } {
    if { ![cdns_validate [info level 0] uvm cdnsextn] } { return "command aborted" }
       # strip the post _phase and validate phase name  
       regsub -all "_phase"  $run_phase "" run_phase
       set re "(build|connect|end_of_elaboration|start_of_simulation|run|extract|check|report|final)|((pre_|post_)?(configure|main|shutdown|reset))"
       if {[regexp $re $run_phase ]} {
	   set stop_cmd "stop -create -object cdns_uvm_pkg::cdns_uvm_data_valid -delbreak 1 -name \"begin-of-$run_phase\_phase\" -if \{\#cdns_uvm_pkg::uvm_break_phase == \"$run_phase\" && \#cdns_uvm_pkg::uvm_phase_is_start == 1\}"
#	   puts $stop_cmd
	   eval $stop_cmd
	   run
       } else {
               puts "uvm: *E,UVMCMD: phase name \"$run_phase\" is not a predefined phase name"
       }
   }
 } 
}

    proc tcl_get_message { comp tag } {
	call tcl_uvm_get_message \"$comp\" \"$tag\"
	set rval [uvm_get_result]
    }


    ### Tcl access to the uvm version
    proc uvm_version { args } {
	if { [cdns_help_evaluate $args] } { return }
        if { ![cdns_validate [info level 0] uvm ] } { return "command aborted" }
        return [value uvm_pkg::uvm_revision]
    }

    proc uvm_objection args {
	if { [cdns_help_evaluate $args] } { return }	
	set re "(-all)?$"
	set isOk [cdns_validate_command $re [info level 0] $args]
	if { ![cdns_validate [info level 0] uvm cdnsextn ] } { return "command aborted" }
	
	if { $isOk } {
	    set isAll [expr ([llength $args]) ?  0 : 1 ]	
	    call tcl_uvm_objection $isAll
	}
    }

    proc uvm_factory args {
	if { [cdns_help_evaluate $args] } { return }
	set re "-(print(\\s+-all_types)?|override\\s+-by_((type\\s+\\S+\\s+\\S+)|(instance\\s+\\S+\\s+\\S+\\s+\\S+))|debug\\s+\\S+\\s+\\S+\\s+\\S+)$"
	set isOk [cdns_validate_command $re [info level 0] $args]

        if { ![cdns_validate [info level 0] uvm cdnsextn ] } { return "command aborted" }
	

	if { $isOk } {
	    switch -regexp -- $args {
		"-print\\s+-all_types" { call tcl_uvm_factory 0 1 0  \"\" \"\" \"\" } 
		"-print" { call tcl_uvm_factory 0 0 0  \"\" \"\" \"\" } 
		"-override\\s+-by_type" { 
		    regexp -line -- "-override\\s+-by_type\\s+(\\S+)\\s+(\\S+)" $args all a b
		    call tcl_uvm_factory 1 0 1  \"$a\" \"$b\" \"\"					
		}
		"-override\\s+-by_instance" { 
		    regexp -line -- "-override\\s+-by_instance\\s+(\\S+)\\s+(\\S+)\\s+(\\S+)" $args all a b c
		    call tcl_uvm_factory 1 0 0  \"$a\" \"$b\" \"$c\"				
		}
		"-debug\\s+"  { 
		    regexp -line -- "-debug\\s+(\\S+)\\s+(\\S+)\\s+(\\S+)" $args all a b c
		    call tcl_uvm_factory 2 0 0  \"$a\" \"$b\" \"$c\"				
		}
		default { cdns_assert 0 "this should never happen" }
	    }				
	}
    }


    proc uvm_config_db args {
	if { [cdns_help_evaluate $args] } { return }
        set re "-(dump(\\s+-audit)?|(trace\\s+(on|off))|(audit\\s+(on|off)))"
	set isOk [cdns_validate_command $re [info level 0] $args]
        if { ![cdns_validate [info level 0] uvm cdnsextn ] } { return "command aborted" }
	
	if { $isOk } {
	    regexp -line -- $re $args v1 v2 v3 v4 v5 v6 v7
	    switch -regexp -- $args {
                "-dump\\s+-audit" {   
		    if { ![cdns_validate [info level 0] is_uvm_initialized ] } { return "command aborted" }
		    call tcl_uvm_config_db 0 1 
		} 
		"-dump" { 
		    if { ![cdns_validate [info level 0] is_uvm_initialized ] } { return "command aborted" }
		    call tcl_uvm_config_db 0 0 
		} 
		"-trace" { call tcl_uvm_config_db 1 [cdns_get_on_off_mapping $v5] }
		"-audit"  { call tcl_uvm_config_db 2 [cdns_get_on_off_mapping $v7 ] }
		default { cdns_assert 0 "this should never happen" }
	    }
	}
    }

    # check if someone is asking for help
    proc cdns_help_evaluate args {
	#	puts [info level 1]
	foreach key [lindex $args 0] {
	    if { $key == "-help" } {
		help [lindex [info level 1] 0]
		return 1
	    }
	}
	return 0
    }

    proc cdns_assert {condition msg} {
	if {![uplevel 1 expr $condition]} {
	    return -code error $msg
	}
    }

    proc cdns_get_on_off_mapping arg {
	array set v [list on 1 off 0 OFF 0 ON 1 get 2]
	#	puts "took \"$arg\" as $v($arg)"
	return $v($arg)
    }

    proc cdns_validate_command {re name actual} {
	#	puts "\"^$re\" \"$actual\""
	if {![regexp -line -- "\^$re" $actual]} {
	    puts "*E,UVMCMD: provided arguments do not match requirements \"$re\" provided \"$actual\""
	    help [lindex $name 0]
	    return 0
	} 
	#	puts "command passed test"
	return 1
    }

    # validate that the prerequirements are met
    # uvm
    # cdnsuvm
    proc cdns_validate { name args } {
        array set map {uvm "only works with UVM which apparently is not part of the snapshot" \
        		   cdnsextn "requires the CDNS-Extention Package to work" \
			   is_uvm_initialized "UVM is not yet fully initialized, run \"run -vda\" to complete init" \
        	       }
        set prefix "uvm: *E,UVMCMD: \"$name\" "
        set scope [scope]
        set ret_val 1

        foreach key $args {
            switch $key {
        	uvm { if { [catch {scope uvm_pkg} foo] } { puts "$prefix$map($key)"; set ret_val 0; } }
		is_uvm_initialized { if { [value uvm_pkg::uvm_resource_pool::print_resources::printer] == "null" } { puts "$prefix$map($key)"; set ret_val 0; } }
        	cdnsextn { if { [catch {scope cdns_uvm_pkg} foo] } { puts "$prefix$map($key)"; set ret_val 0; } }
        	default { cdns_assert 0 "this should never happen"; set ret_val 0; }
            }
        }
        scope -set $scope
        return $ret_val
    }

    #
    # if the -label option is support in the stop cmd
    #
    proc m_supports_label {} {
	return [regexp -line -- "(12\.2|1[3-9]\.)" [version]] 
    }
}

namespace import uvmtcl::*
