// the apb4 interface
module apbIf (
	iPClk,
	iPRstn,
	iPSel,
	iPWrite,
	iPWDat,
	iPAddr,
	iPEnable,
	oPRDat,
	oRegSel,
	oRegWr,
	oRegWD,
	iRegRD
); // {

	input iPClk, iPRstn, iPSel, iPWrite,iPEnable;
	input  [7:0] iPAddr;
	input  [31:0] iPWDat;
	output [31:0] oPRDat;

	output oRegWr;
	output [31:0] oRegSel;
	output [31:0] oRegWD;
	input  [31:0] iRegRD;




	always @(posedge iPClk or negedge iPRstn) begin // {
	end // }



endmodule // }
