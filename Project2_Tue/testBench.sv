program testBench(dut_IF.TEST IF);
	import classes::*;
	Generator generator;
	//Agent agent;
	Scoreboard scoreboard;
	Checker checkerOB;
	Monitor monitor;
	DriverSingle driverS;

	//mailbox driverMB;
	mailbox scoreboardMB; 
	mailbox driverSingleMB;
	mailbox SBtocheckerMB;
 	mailbox MNtocheckerMB;

	event drv_done;
	event gen_done;
	event mon_done;
	event check_done;
	event test_done;

    	initial begin

		//driverMB = new();
		scoreboardMB = new();
		driverSingleMB = new();
		SBtocheckerMB = new();
		MNtocheckerMB = new();

		//generator = new();
		generator.driverSingleMB = driverSingleMB;
		generator.scoreboardMB = scoreboardMB;
		generator.check_done = check_done;
		generator.gen_done = gen_done;
		generator.test_done = test_done;
		

		checkerOB = new();
		checkerOB.SBtocheckerMB = SBtocheckerMB;
		checkerOB.MNtocheckerMB = MNtocheckerMB;
		checkerOB.check_done = check_done;
		checkerOB.mon_done = mon_done;
		checkerOB.drv_done = drv_done;
	
		driverS = new();
		driverS.IF = IF;
		driverS.driverSingleMB = driverSingleMB;

        	monitor = new();
		monitor.IF = IF;
		monitor.MNtocheckerMB = MNtocheckerMB;
		monitor.drv_done = drv_done;
		monitor.mon_done = mon_done;
       
		driverS.drv_done = drv_done;
		driverS.gen_done = gen_done;
		

		

		//going to use the same mailbox as the driver for now
		scoreboard = new();
		scoreboard.scoreboardMB = scoreboardMB;
		scoreboard.SBtocheckerMB = SBtocheckerMB;

        	reset();

	 	fork
        		monitor.run();
			driverS.run();
			generator.run();
			scoreboard.run();
			checkerOB.run();
    		join

		$display("End of program");
	end

	task reset();
        	IF.reset = 1; 
        	IF.cb.req1_cmd_in <= 0000;
        	IF.cb.req2_cmd_in <= 0000;
        	IF.cb.req3_cmd_in <= 0000;
        	IF.cb.req4_cmd_in <= 0000;
        
        	IF.cb.req1_data_in <= 00000000000000000000000000000000;
        	IF.cb.req2_data_in <= 00000000000000000000000000000000;
        	IF.cb.req3_data_in <= 00000000000000000000000000000000;
        	IF.cb.req4_data_in <= 00000000000000000000000000000000;

        	IF.cb.req1_tag_in <= 00;
        	IF.cb.req2_tag_in <= 00;
        	IF.cb.req3_tag_in <= 00;
        	IF.cb.req4_tag_in <= 00;

        	@(IF.c_clk);
        	@(IF.c_clk);
        	@(IF.c_clk);
     
        	IF.reset = 0; 

		@(IF.c_clk);
   		@(IF.c_clk);
		@(IF.c_clk);
   		@(IF.c_clk);	
    	endtask
endprogram
