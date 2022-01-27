`ifndef uvm_resource__svh
`define uvm_resource__svh

// this is the resource file that declares the uvm_resource#(T) class as a container for
// storing type <T> variables.
class uvm_resource#(type T=int) extends uvm_resourceBase; // {

	local T value;



	function new (string name="",string scope="");
		super.new(name,scope);
	endfunction



	// write value to current resource
	extern function void write(T val);

endclass // }


`endif
