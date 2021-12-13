`ifdef UVM_ENABLE_DEPRECATED_API
//------------------------------------------------------------------------------
//
// Class- uvm_test_done_objection DEPRECATED
//
// Provides built-in end-of-test coordination
//------------------------------------------------------------------------------

class uvm_test_done_objection extends uvm_objection; // {

	protected static uvm_test_done_objection m_inst;
	protected bit m_forced;

  // For communicating all objections dropped and end of phasing
  local  bit m_executing_stop_processes;
  local  int m_n_stop_threads;


  // Function- new DEPRECATED
  //
  // Creates the singleton test_done objection. Users must not call
  // this method directly.
  function new(string name="uvm_test_done");
    super.new(name);
  endfunction


	// Function- qualify DEPRECATED
	//
	// Checks that the given ~object~ is derived from either <uvm_component> or
	// <uvm_sequence_base>.
	virtual function void qualify(
		uvm_object obj=null,
		bit is_raise,
		string description
	); // {
		uvm_component c;
		uvm_sequence_base s;
		string nm = is_raise ? "raise_objection" : "drop_objection";
		string desc = description == "" ? "" : {" (\"", description, "\")"};

		if(! ($cast(c,obj) || $cast(s,obj))) begin // {
			// @ryan, if not a derivative of component and sequence_base
			uvm_report_error("TEST_DONE_NOHIER", {"A non-hierarchical object, '",
				obj.get_full_name(), "' (", obj.get_type_name(),") was used in a call ",
				"to uvm_test_done.", nm,"(). For this objection, a sequence ",
				"or component is required.", desc }
			);
		end // }
	endfunction // }

	// Below are basic data operations needed for all uvm_objects
	// for factory registration, printing, comparing, etc.
	typedef uvm_object_registry#(uvm_test_done_objection,"uvm_test_done") type_id;
	static function type_id get_type();
		return type_id::get();
	endfunction

	function uvm_test_done_objection create (string name="");
		uvm_test_done_objection tmp = new(name);
		return tmp;
	endfunction

  virtual function string get_type_name ();
    return "uvm_test_done";
  endfunction

  static function uvm_test_done_objection getStaticObj();
    if(m_inst == null)
      m_inst = uvm_test_done_objection::type_id::create("run");
    return m_inst;
  endfunction

endclass // }
`endif // UVM_ENABLE_DEPRECATED_API
