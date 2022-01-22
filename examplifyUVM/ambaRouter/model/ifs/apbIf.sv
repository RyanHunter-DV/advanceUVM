// signal layer of the regUnit
interface #(AW=32,DW=32) apb4If; // {

	logic PClk;
	logic PRstn;
	logic PSel,PWrite,PEnable;
	logic [AW-1:0] PAddr;
	logic [DW-1:0] PWDat,PRDat;


	clocking clock @(posedge PClk);
	endclocking




	// signal control APIs here {{{
	// }}}


	modport toRegUnit(
		input clock;
		input PRstn,PSel,PWrite,PEnable;
		input PAddr,PWDat;
		output PRDat;
	);

end // }
