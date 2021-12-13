//------------------------------------------------------------------------------
//
// Class -- NODOCS -- uvm_phase_state_change
//
//------------------------------------------------------------------------------
//
// Phase state transition descriptor.
// Used to describe the phase transition that caused a
// <uvm_phase_cb::phase_state_changed()> callback to be invoked.
//

// @uvm-ieee 1800.2-2017 auto 9.3.2.1
class uvm_phase_state_change extends uvm_object; // {{{

  `uvm_object_utils(uvm_phase_state_change)

  // Implementation -- do not use directly
  /* local */ uvm_phase       m_phase;
  /* local */ uvm_phase_state m_prev_state;
  /* local */ uvm_phase       m_jump_to;
  
  function new(string name = "uvm_phase_state_change");
    super.new(name);
  endfunction



  // @uvm-ieee 1800.2-2017 auto 9.3.2.2.1
  virtual function uvm_phase_state get_state();
    return m_phase.get_state();
  endfunction
  

  // @uvm-ieee 1800.2-2017 auto 9.3.2.2.2
  virtual function uvm_phase_state get_prev_state();
    return m_prev_state;
  endfunction


  // @uvm-ieee 1800.2-2017 auto 9.3.2.2.3
  function uvm_phase jump_to();
    return m_jump_to;
  endfunction

endclass // }}}
