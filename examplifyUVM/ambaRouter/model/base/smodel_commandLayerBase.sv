`ifndef smodel_commandLayerBase__sv
`define smodel_commandLayerBase__sv

virtual class commandLayerBaseClass; // {


	// variaty commands from abstraction layer sent to commandLayer through this issue
	// task.
	pure virtual task issue (commandBaseClass cmd);


endclass // }

`endif
