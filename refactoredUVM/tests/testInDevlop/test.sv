module tb;
	initial begin
		$display("hello started");
		#200ns;
		$finish;
	end


	task taskB();
		process p2=process::self();
		$display("p2: %0d",p2);
	endtask

	initial 
	fork
		begin
			process p0 = process::self();
			$display("p0: %0d",p0);
			begin
				process p1 = process::self();
				#1;
				$display("p1: %0d",p1);
				taskB();
			end
			#100ns;
		end
	join


endmodule 
