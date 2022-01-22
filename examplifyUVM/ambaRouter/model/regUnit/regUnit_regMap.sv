`ifndef regUnit_reqMap__sv
`define regUnit_regMap__sv


class regFieldClass; // {

	parameter defaultFieldWidth = 128;
	`define DW defaultFieldWidth

	typedef enum
	{
		RW,
		RO,
		WO
	} regAccessType_enum;

	regAccessType_enum access;
	string name;
	int lsb;
	int size;
	bit [`DW-1:0] value;

	function new (
		string _name = "",int _size = 1
		int _lsb,
		regAccessType_enum _acc,
		bit reset
	); // {
		name = _name;
		size = _size;
		// TODO
	endfunction // }

endclass // }

`undef DW


class regClass; // {


	regFieldClass fields[string];
	bit [] offset;



endclass // }


class regMapClass; // {

	string name;
	int width;




endclass // }


`endif
