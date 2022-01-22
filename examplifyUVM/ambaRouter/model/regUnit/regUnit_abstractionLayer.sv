`ifndef regUnit_abstractionLayer__sv
`define regUnit_abstractionLayer__sv

typedef class commandLayerClass;

class abstractionLayerClass; // {

	static abstractionLayerClass staticObj;
	static commandLayerClass cmdh;

	process mainProc;
	regCommandGeneratorClass genCmd;

	extern static function abstractionLayerClass getStaticObj();
	extern task startEntry();
	extern task mainProcessor();

	// generate a wait cmd, genCmd.waitReq()
	// cmdh.issue(cmd) // this cmd will expect a result
	// processReg(cmd.regTr)
	// cmdh.feedback(cmd) // give back response if has, if not, then just to flush the cmd queue
	extern task registerCtrlThread();

	// if regTr.isWrite
	// this.updateRegValue(regTr.reg,regTr.value)
	// cmd = genCmd.driveRegSignal(regTr.reg,regTr.value)
	// cmdh.issue(cmd)
	// if !regTr.isWrite
	// regTr.value = this.getRegValue(regTr.reg)
	extern task processReg(regTransClass regTr);

	//TODO
	extern function void updateRegValue(string name,bit[127:0] value);

	// cmdh.getRegValue(tr.register,tr.value)
	// updateRsp("read",tr)
	extern function void getRegState (ref regTransClass tr);

	// case type
	// "null" -> return
	// "read" -> tr.resp=OKAY/ADDRE
	extern function void updateRsp (string type, ref regTransClass tr);

endclass // }

`define func(r,f) function r abstractionLayerClass::f
`define task(t) task abstractionLayerClass::t
`define endf endfunction
`define endt endtask

`func(abstractionLayerClass,getStaticObj) (
	commandLayerClass cmd
); // {

	if (staticObj) return staticObj;

	fork // {
		startEntry();
	join_none // }

	return staticObj;

`endf // }

`task(startEntry) (); // {
	fork // {
		initDetector();
		begin // {
			mainProc = process::self();
			mainProcessor();
		end // }
	join // }
`endt // }

`task(mainProcessor) (); // {
	fork // {
		processRegReq();
	join // }
`endt // }



`undef func
`undef task
`undef endf
`undef endt
`endif
