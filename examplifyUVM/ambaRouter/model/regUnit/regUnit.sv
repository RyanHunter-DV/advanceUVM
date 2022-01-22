module regUnit (
	apb4If.toRegUnit ri
); // {

	import regUnitModel_pkg::*;

	typedef timeUntimedBufferClass tutClass;
	typedef commandLayerClass cmdClass;
	typedef abstractionLayerClass absClass;

	initial begin // {
		tutClass tut = tutClass::getStaticObj(ri);
		cmdClass cmd = cmdClass::getStaticObj(tut);
		absClass abs = absClass::getStaticObj(cmd);
	end // }

endmodule // }
