`ifndef regUnit_regCommand__sv
`define regUnit_regCommand__sv

class regCommandClass extends commandBaseClass; // {

	typedef enum
	{
		waitReq,
		updateRegState
	} regCommandType_enum;

	regCommandType_enum type;
	bit needResult;
	regTransClass regTr;

	// initialize
	// this.name = nm
	// this.type = t
	// this.needResult = nr
	extern function new (
		string nm = "<null>",
		regCommandType_enum t,
		bit nr
	);

endclass // }





`endif
