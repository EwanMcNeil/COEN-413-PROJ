program automatic test(dut_IF.TEST vif); 
	
	`include "environment.sv";

	class gen extends Generator;
		covergroup transCovergroup;
			PORTS: coverpoint this.trans.port{bins ports =  {2'b00, 2'b01, 2'b10, 2'b11};}
			COMMANDS: coverpoint this.trans.cmd{bins cmds = {4'b0001, 4'b0010, 4'b0101, 4'b0110};}

			PORTS_COMMANDS: cross PORTS, COMMANDS;
		endgroup

		function new(mailbox driver=null, mailbox scoreboard=null, event check=null, event gen=null, event test=null);
			super.new(driver, scoreboard, check, gen, test);
			transCovergroup = new;
		endfunction

		function displayCoverage();
			$display("Current coverage is %0.2f", transCovergroup.get_inst_coverage()); 
		endfunction
	endclass: gen

	environment env;
	gen generator;

	initial begin
  		env = new(vif);

  		generator = new(env.driverSingleMB, env.scoreboardMB, env.check_done, env.gen_done, env.test_done);
  		env.generator = generator;

  		env.run();

  		$finish;
	end
endprogram
