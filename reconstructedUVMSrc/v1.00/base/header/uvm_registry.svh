// @RyanH, copyright
// reconstructed registry contents

class uvm_component_registry #(type T=uvm_component, string Tname="<unknown>")
	extends uvm_object_wrapper; // {


	typedef uvm_component_registry#(T,Tname) thisType;


	// public:

	// @RyanH, create a T typed component by this classObj, with name and parent info
	extern virtual function T create_component(string name,uvm_component parent);
	// @RyanH, static to give back the caller this class's Tname parameter.
	extern static function string typename();
	// @RyanH, same as typename by default, but it's a virtual non-static function, may have further
	// usage, TODO
	extern virtual function string getTypename();
	// @RyanH, get static object of this class
	extern static function thisType getStaticObj();

	// @RyanH, register this class into factory, why not directly register in factory, but to use
	// a common registry?
	extern virtual function void initialize();

	// @RyanH, the API to create the new uvm_component based type
	extern static function T create(string name, uvm_component parent, string contxt="");

	// @RyanH, this function to override the original uvm_component_registry#(T,Tname) type by a new
	// one
	extern static function void set_type_override (
		uvm_object_wrapper overrideObj,
		bit replace=1
	);

	// @RyanH, this actually override by objectHandle, can be some kind of a 'type'
	extern static function void set_inst_type_override(
		uvm_object_wrapper overrideObj,
		string full_inst_path,
		uvm_component parent
	);



	// private:

endclass // }
