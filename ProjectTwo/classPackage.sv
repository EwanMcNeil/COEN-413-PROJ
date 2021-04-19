package classes;
	//transaction Class
	//is this for one port or for multiple
	//I think just for one

	class Transaction;
		static int errorCount = 0;
		static int posCount = 0;
		//rand bit [0:1] port;		//used to see which port it is on
		logic [0:1] port;
		rand bit [0:3] cmd;
		rand bit [0:31] data_in_1;
		rand bit [0:31] data_in_2;
    		logic [0:1] tag_in;
		//rand bit tag_in;

		//outputs of device 
		logic [0:1] resp;
		logic [0:31] data_out;
		logic [0:1] tag_out;
		
		//0001 add, 0010 sub, 0101 shift left, 0110 shift right
		constraint commandValid {((cmd == 1) || (cmd == 2) || (cmd == 5) || (cmd ==6));}
		//constraint commandValid {(cmd == 6);}
		constraint portValid{((port == 0) || (port == 1) || (port == 2) || (port ==3));}
		constraint tagValid{((tag_in == 0) || (tag_in == 1) || (tag_in == 2)  ||(tag_in == 3));}
		constraint dataOne{ data_in_1 > 1; data_in_1 < 100;}
		constraint dataTwo{ data_in_2 > 1; data_in_2 < 100;}

		//TODO make the random values be made by the generator
		//function new(logic [0:1] inPort, logic [0:1] inTag);
		//	port = inPort;
		//	tag_in = inTag;
		//endfunction


		function displayInputs();
			 $display("T: %0t [Transaction] port: %b cmd: %b data_in_1: %0d data_in_2: %0d tag_in: %b", $time, port, cmd, data_in_1, data_in_2, tag_in);
		endfunction

		function displayTagPort();
				 $display("T: %0t [Transaction] port: %b tag_out: %b", $time, port, tag_in);
		endfunction

		//added a deep copy function
		function void copy(Transaction tmp);
			this.port =tmp.port;
    			this.cmd = tmp.cmd;
    			this.data_in_1 = tmp.data_in_1;
   			this.data_in_2 = tmp.data_in_2;
    			this.tag_in = tmp.tag_in;
  		endfunction
	endclass
		
	//driver class

	//TODO this needs to be setup as the bundle driver was setup
	class DriverSingle;
		virtual dut_IF IF;
		mailbox driverSingleMB;

		//holds the queues from the values 
		Transaction portOneTrans[$];
		Transaction portTwoTrans[$];
		Transaction portThreeTrans[$];
		Transaction portFourTrans[$];

		Transaction tranOne;
		Transaction tranTwo;
		Transaction tranThree;
		Transaction tranFour;

		int driveOne;
		int driveTwo;
		int driveThree;
		int driveFour;

		
		event drv_done;
		event gen_done;


		task run();
			$display("T: %0t [Driver] starting...", $time);

			forever begin
			   
			      @gen_done;	//wait for the generator to signal completion
				//load values from the generator into 4 queues each for a port

				reset();
				while(driverSingleMB.num() > 0)begin
					Transaction trans;
					driverSingleMB.get(trans);

				$display("T: %0t [Driver] receiving transaction from Generator", $time);

				$display("T: %0t [Driver] port: %b cmd: %b Data1: %0d Data2: %0d Tag: %b", $time, trans.port, trans.cmd, trans.data_in_1, trans.data_in_2, trans.tag_in);
					
					if(trans.port == 0'b00)begin
						portOneTrans.push_back(trans);
					end
					if(trans.port == 0'b01)begin
						portTwoTrans.push_back(trans);
					end
					if(trans.port == 0'b10)begin
						portThreeTrans.push_back(trans);
					end
					if(trans.port == 0'b11)begin
						portFourTrans.push_back(trans);
					end



				end
				
				
				for(int i = 0; i < 4; i++)begin
					driveOne = 0;	
					driveTwo = 0;
					driveThree = 0;
					driveFour = 0;

					if(portOneTrans.size > 0)begin
						driveOne = 1;
						tranOne = portOneTrans.pop_front();
					end
					

					if(portTwoTrans.size > 0)begin
						driveTwo = 1;
						tranTwo = portTwoTrans.pop_front();
					end

					if(portThreeTrans.size > 0)begin
						driveThree = 1;
						tranThree = portThreeTrans.pop_front();
					end
			
					if(portFourTrans.size > 0)begin
						driveFour = 1;
						tranFour = portFourTrans.pop_front();
					end
					
				@(posedge IF.c_clk)
					$display("T: %0t [Driver] Driving set of commands", $time);
				if(driveOne == 1) begin
					
					IF.cb.req1_cmd_in <= tranOne.cmd;
					IF.cb.req1_tag_in <= tranOne.tag_in;
					IF.cb.req1_data_in <= tranOne.data_in_1;
				end

				if(driveTwo == 1) begin
					IF.cb.req2_cmd_in <= tranTwo.cmd;
					IF.cb.req2_tag_in <= tranTwo.tag_in;
					IF.cb.req2_data_in <= tranTwo.data_in_1;
					
				end

				if(driveThree == 1) begin
					IF.cb.req3_cmd_in <= tranThree.cmd;
					IF.cb.req3_tag_in <= tranThree.tag_in;
					IF.cb.req3_data_in <= tranThree.data_in_1;
					
				end

				if(driveFour == 1) begin
					IF.cb.req4_cmd_in <= tranFour.cmd;
					IF.cb.req4_tag_in <= tranFour.tag_in;
					IF.cb.req4_data_in <= tranFour.data_in_1;
				end

				//check if this is right because before they were being driven off of @(IF.cb) which I dont think is right
				//@(IF.cb);
				@(posedge IF.c_clk)
				
				if(driveOne == 1)begin
				IF.cb.req1_data_in <= tranOne.data_in_2;
				end

				if(driveTwo == 1)begin
				IF.cb.req2_data_in <= tranTwo.data_in_2;
				end
				
				if(driveThree == 1)begin
				IF.cb.req3_data_in <= tranThree.data_in_2;
				end

				if(driveFour == 1)begin
				IF.cb.req4_data_in <= tranFour.data_in_2;
				end

			
			$display("T: %0t [Driver] LOOP", $time);
				end

			//give it a couple cycles before ending
			for(int i =0; i < 30; i++)begin
				@(posedge IF.c_clk);
			end

			$display("T: %0t [Driver] Drive done asserted", $time);
			->drv_done;
			end
		endtask

		task reset();
			$display("T: %0t [Driver] Driver Reseting DUT", $time);
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
	endclass

	///
	///Command block
	///

	//monitor
	//four threads looking at each of the input/ output ports 
	//but multiple commands could be running so maybe fork a new internally?
	class Monitor;
		//link to the interface

		virtual dut_IF IF;
			
		//TODO 
		mailbox scoreboardMail;
		mailbox MNtocheckerMB;
		event mon_done;
		event drv_done;
		int threadCount;

		task run();
			$display("T: %0t [Monitor] starting...", $time);
			threadCount = 0;
		
			fork
				watchInputOne();
				watchInputTwo();
				watchInputThree();
				watchInputFour();
				//waitDriver();
		 	join


			
		endtask
			task waitDriver();
			//not quite sure if this is setup correctly
			forever begin
				$display("T: %0t [Monitor] Waiting for driver", $time);
				@(drv_done);
				$display("T: %0t [Monitor] Drive done asserted, waiting for final signals", $time);
					
				for(int i = 0 ; i < 50; i++)begin
					@(IF.c_clk);
				end

				->mon_done;
				$display("T: %0t [Monitor] Monitor finished", $time);
				
			end
			endtask
		
		//This concept of watching the inputs maybe isnt needed
		task watchInputOne();
			forever begin
				Transaction fresh;
				$display("T: %0t [Monitor] watching port one", $time);
		   		@(IF.cb.req1_data_in);
				if(IF.reset == 0)begin
		   		
				//make a new transaction object
				$display("T: %0t [Monitor] seeing new transaction on port 1", $time);
				fresh = new();		//port is 00 and pass new tag in
				fresh.port = 2'b00;
				fresh.tag_in = IF.cb.req1_tag_in;
				fresh.cmd = IF.cb.req1_cmd_in;
				fresh.data_in_1 = IF.cb.req1_data_in;
	
		  		@(IF.cb.req1_data_in)
				fresh.data_in_2 = IF.cb.req1_data_in;
				fresh.displayInputs();

		  		fork
					watchOutputOne(fresh);
					threadCount = threadCount +1;
		  		join_none
				$display("T: %0t [Monitor] after fork", $time);
		  		//join none so the watchInputOne is restarted
				end
	         	end
		endtask

		task watchInputTwo();
			forever begin
				Transaction fresh;
				$display("T: %0t [Monitor] watching port two", $time);
		   		@(IF.cb.req2_data_in);
		   		if(IF.reset == 0)begin
				//make a new transaction object
				$display("T: %0t [Monitor] seeing new transaction on port 2", $time);
				fresh = new();		//port is 01 and pass new tag in
				fresh.port = 2'b01;
				fresh.tag_in = IF.cb.req2_tag_in;
				fresh.cmd = IF.cb.req2_cmd_in;
				fresh.data_in_1 = IF.cb.req2_data_in;
	
		  		@(IF.cb.req2_data_in)
				fresh.data_in_2 = IF.cb.req2_data_in;
				fresh.displayInputs();

		  		fork
					watchOutputTwo(fresh);
		  		join_none
		  		//join none so the watchInputTwo is restarted
				end
	         	end
		endtask

		task watchInputThree();
			forever begin
				Transaction fresh;

		   		@(IF.cb.req3_data_in);
		   		if(IF.reset == 0)begin
				//make a new transaction object
				$display("T: %0t [Monitor] seeing new transaction on port 3", $time);
				fresh = new();		//port is 10 and pass new tag in
				fresh.port = 2'b10;
				fresh.tag_in = IF.cb.req3_tag_in;
				fresh.cmd = IF.cb.req3_cmd_in;
				fresh.data_in_1 = IF.cb.req3_data_in;
	
		  		@(IF.cb.req3_data_in)
				fresh.data_in_2 = IF.cb.req3_data_in;
				fresh.displayInputs();

		  		fork
					watchOutputThree(fresh);
		  		join_none
				end
		  		//join none so the watchInputThree is restarted
	         	end
		endtask

		task watchInputFour();
			forever begin
				Transaction fresh;
				
		   		@(IF.cb.req4_data_in);
		   		if(IF.reset == 0)begin
				//make a new transaction object
				$display("T: %0t [Monitor] seeing new transaction on port 4", $time);
				fresh = new();		//port is 10 and pass new tag in
				fresh.port = 2'b11;
				fresh.tag_in = IF.cb.req4_tag_in;
				fresh.cmd = IF.cb.req4_cmd_in;
				fresh.data_in_1 = IF.cb.req4_data_in;
	
		  		@(IF.cb.req4_data_in)
				fresh.data_in_2 = IF.cb.req4_data_in;
				fresh.displayInputs();

		  		fork
					
					watchOutputFour(fresh);
		  		join_none
				end
		  		//join none so the watchInputFour is restarted
	         	end
		endtask

		task watchOutputOne(Transaction fresh);

	$display("T: %0t [Monitor] waiting for response on port 1", $time);
			
		   fork
			begin 
			   fork : timeout_block
		           begin
				wait(IF.cb.out_tag1 == fresh.tag_in);
				
				fresh.resp = IF.cb.out_resp1;
				fresh.data_out = IF.cb.out_data1;
				fresh.tag_out = IF.cb.out_tag1;
			
				$display("T: %0t [Monitor] received response on port 1", $time);
				$display("T: %0t [Monitor] Resp: %b Data: %0d Tag: %b", $time, fresh.resp, fresh.data_out, fresh.tag_out);
				MNtocheckerMB.put(fresh);
				$display("T: %0t [Monitor] Finished inside", $time);
			  end
			  #800 $display("T: %0t [Monitor] ERROR timeout", $time);
			join_any
			disable timeout_block;
			end
			join_none
		endtask

		task watchOutputTwo(Transaction fresh);	

		$display("T: %0t [Monitor] waiting for response on port 2", $time);
		fork
			begin 
			   fork : timeout_block
		           begin
				wait(IF.cb.out_tag2 == fresh.tag_in);
				
				fresh.resp = IF.cb.out_resp2;
				fresh.data_out = IF.cb.out_data2;
				fresh.tag_out = IF.cb.out_tag2;
			
				$display("T: %0t [Monitor] received response on port 2", $time);
				$display("T: %0t [Monitor] Resp: %b Data: %0d Tag: %b", $time, fresh.resp, fresh.data_out, fresh.tag_out);
				MNtocheckerMB.put(fresh);
				$display("T: %0t [Monitor] Finished inside", $time);
			  end
			  #800 $display("T: %0t [Monitor] ERROR timeout", $time);
			join_any
			disable timeout_block;
			end
			join_none

			
		endtask

		task watchOutputThree(Transaction fresh);
			
			$display("T: %0t [Monitor] waiting for response on port 3", $time);
		fork
			begin 
			   fork : timeout_block
		           begin
				wait(IF.cb.out_tag3 == fresh.tag_in);
				
				fresh.resp = IF.cb.out_resp3;
				fresh.data_out = IF.cb.out_data3;
				fresh.tag_out = IF.cb.out_tag3;
			
				$display("T: %0t [Monitor] received response on port 3", $time);
				$display("T: %0t [Monitor] Resp: %b Data: %0d Tag: %b", $time, fresh.resp, fresh.data_out, fresh.tag_out);
				MNtocheckerMB.put(fresh);
				$display("T: %0t [Monitor] Finished inside", $time);
			  end
			  #800 $display("T: %0t [Monitor] ERROR timeout", $time);
			join_any
			disable timeout_block;
			end
			join_none
			
		endtask

		task watchOutputFour(Transaction fresh);

		$display("T: %0t [Monitor] waiting for response on port 4", $time);
		fork
			begin 
			   fork : timeout_block
		           begin
				wait(IF.cb.out_tag2 == fresh.tag_in);
				
				fresh.resp = IF.cb.out_resp4;
				fresh.data_out = IF.cb.out_data4;
				fresh.tag_out = IF.cb.out_tag4;
			
				$display("T: %0t [Monitor] received response on port 4", $time);
				$display("T: %0t [Monitor] Resp: %b Data: %0d Tag: %b", $time, fresh.resp, fresh.data_out, fresh.tag_out);
				MNtocheckerMB.put(fresh);
				$display("T: %0t [Monitor] Finished inside", $time);
			  end
			  #800 $display("T: %0t [Monitor] ERROR timeout", $time);
			join_any
			disable timeout_block;
			end
			join_none
		endtask
	endclass


	///
	///Functional block
	///
/*	
	//agent class
	class Agent;
		mailbox #(Transaction) gen2agt, agt2drv;
		Transaction tr;
		function new(mailbox #(Transaction) gen2agt, agt2drv);
			this.gen2agt = gen2agt;
			this.agt2drv = agt2drv;
		endfunction

		task run(); 
			forever begin
			gen2agt.get(tr);
			// Do some processing
			agt2drv.put(tr);
			end 

		endtask
			
		task wrap_up();
		endtask
	endclass

*/



	//TODO scoreboard needs to sent the tag out and the response out
	class Scoreboard;
		mailbox scoreboardMB;
		mailbox SBtocheckerMB;
		int i = 1;
 		task run();

   			forever begin
				//trying to see if using the same mailbox as driver single works when using the get function

     				Transaction ref_item;
				scoreboardMB.get(ref_item);

				$display("[Scoreboard] cmd: %0d data1: %0d data2: %0d", ref_item.cmd, ref_item.data_in_1, ref_item.data_in_2);

				//Calculate the expected results
				if (ref_item.cmd == 1) begin
					ref_item.data_out = ref_item.data_in_1 + ref_item.data_in_2;
				end

				else if (ref_item.cmd == 2) begin
					if (ref_item.data_in_1 >= ref_item.data_in_2) begin
						ref_item.data_out = ref_item.data_in_1 - ref_item.data_in_2;
					end

					else begin
						i = 0;
						$display("[Scoreboard] can't subtract %0d from %0d", ref_item.data_in_2, ref_item.data_in_1);
					end
				end

				else if (ref_item.cmd == 5) begin
					ref_item.data_out = ref_item.data_in_1 << ref_item.data_in_2;
				end

				else if (ref_item.cmd == 6) begin
					ref_item.data_out = ref_item.data_in_1 >> ref_item.data_in_2;
				end
				
				if (i == 1) begin
					$display("T: %0t [Scoreboard] expected answer %0d", $time, ref_item.data_out);
					i = 1;
				end
				ref_item.tag_out = ref_item.tag_in;

				SBtocheckerMB.put(ref_item);
			end
 		endtask
	endclass


	//TODO checker needs to match transactions from the monitor to transcations from the scoreboard
	//Two or three tasks, one to wait for values from the scoreboard and put them in a queue
	//
	class Checker;
		event test_done;
		event mon_done;
		event check_done;
		event drv_done;
		int testCount;
		mailbox SBtocheckerMB;
		mailbox MNtocheckerMB;
		Transaction compareTranQueue[$];

		task run();

   			forever begin
				fork
				    recieveFromMonitor();
				    recieveFromScoreboard();
			            waitDriver();
				join

				
				end


			//when generator finishes its tests checker will keep going for a bit
			//this will run in a seperate thread
			
		endtask

		task waitDriver();
			forever begin
				@(drv_done);
			
				$display("T: %0t [Checker] Asserting Checkdone number of transactions checked:", $time, testCount);
				$display("T: %0t [Checker] Number of transactions unseen", $time, compareTranQueue.size());

				foreach(compareTranQueue[i])  $display("\tScoreboardTransaction[%0d] = %0d",i,compareTranQueue[i].displayInputs());
				testCount = 0;
				compareTranQueue.delete();
				->check_done;	
			
			end
			endtask



		task recieveFromScoreboard();
			forever begin
				Transaction SBoutput;
				SBtocheckerMB.get(SBoutput); //blocking call
				$display("T: %0t [Checker] Recieved transaction from Scoreboard", $time);
				SBoutput.displayTagPort();
				
				compareTranQueue.push_back(SBoutput);
			end

		endtask

		task recieveFromMonitor();
			forever begin
				Transaction MNoutput;
				MNtocheckerMB.get(MNoutput);
				$display("T: %0t [Checker] Recieved transaction from Monitor", $time);
				MNoutput.displayTagPort();
				testCount = testCount +1;
				fork
					compareTrans(MNoutput);
				join_none
			end

		endtask;

		task compareTrans(Transaction fromDUT);
			Transaction compareTo;
			Transaction fromScore[$];
			int indexes[$];
			int index;
			fromScore = compareTranQueue.find() with (item.port == fromDUT.port && item.tag_in == fromDUT.tag_in);
			indexes = compareTranQueue.find_index() with (item.port == fromDUT.port && item.tag_in == fromDUT.tag_in);
			
			if(fromScore.size == 0)begin
				$display("T: %0t [Checker]No data found for command on Port %0d with tag %0d", $time, fromDUT.port,fromDUT.tag_out);
			end
			else begin
				index = indexes.pop_front();
					$display("T: %0t [Checker]DATA FOUND for command on Port %0d with tag %0d", $time, fromDUT.port,fromDUT.tag_out);
					compareTo =  fromScore.pop_front();
					if(compareTo.data_out != fromDUT.data_out)begin
						$display("T: %0t [Checker]ERROR, port %0d with tag %0d data is %0d should be %0d", $time, fromDUT.port,fromDUT.tag_out,fromDUT.data_out,compareTo.data_out);
					end
					else begin
						$display("T: %0t [Checker] CORRECT, port  %0d with tag %0d data is %0d should be %0d", $time, fromDUT.port,fromDUT.tag_out,fromDUT.data_out,compareTo.data_out);
					end
					
					compareTranQueue.delete(index);
			end


			
		endtask
	endclass

	///
	///Scenario block
	///

	//generator
	//maybe we should do both, bundles and signel ones
	//generator generates bundles of transactions 
	class Generator;
		mailbox driverSingleMB;
		mailbox scoreboardMB;
		event drv_done;
		event gen_done;
		event test_done;
		event check_done;
		Transaction trans, temp;
		bit [2:0] portOneCount;
		bit [2:0] portTwoCount;
		bit [2:0] portThreeCount;
		bit [2:0] portFourCount;
		logic [1:0] portOneTagCount;
		logic [1:0] portTwoTagCount;
		logic [1:0] portThreeTagCount;
		logic [1:0] portFourTagCount;
		string line;
		int noTests;
		int configFile;

		task run();
			//going to comment loop for now to just test one operation
			//Pull in from config file to run generator
			configFile = $fopen("./testbenchConfig.txt", "r");

			//first line of the testbenchConfig is how many random scenerios to be generated
			$fgets(line,configFile);
			
			noTests = line.atoi();
			//if second line exists then hat is the input scenerio to be run -> no random sernario
			$fgets(line,configFile);
			
			if(!$feof(configFile))begin
				$display("T: %0t [Generator] Found user defined scenario ", $time);

			end

			else begin
				$display("T: %0t [Generator] Running %0d random scenerio", $time,noTests);
			//TODO randomize a number 1-16 to run	
			for(int j = 0; j< 10; j++)begin
				$display("T: %0t [Generator] Making Test # %0b", $time,j);
			
			//Max of 16 possible commands running at once
			//doing it so theres always min of two
			portOneCount = $urandom_range(0,4);
			portTwoCount = $urandom_range(0,4);
			portThreeCount = $urandom_range(0,4);
			portFourCount = $urandom_range(0,4);
			portOneTagCount = 2'b00;
			portTwoTagCount = 2'b00;
			portThreeTagCount= 2'b00;
			portFourTagCount= 2'b00;
			

			for(int i = 0; i < portOneCount; i ++)begin
				
				
					trans = new();
					trans.port = 2'b00;
					trans.tag_in = portOneTagCount;
				    	trans.randomize();
					
				    	trans.displayInputs();
					temp = new();
				  	temp.copy(trans);
				    	scoreboardMB.put(temp);
				    	driverSingleMB.put(trans);
					portOneTagCount = portOneTagCount +1;
			
			end	

			for(int i = 0; i < portTwoCount; i ++)begin
					
					trans = new();
					trans.port = 2'b01;
					trans.tag_in = portTwoTagCount;
				    	trans.randomize();
				    	trans.displayInputs();
					temp = new();
				  	temp.copy(trans);
				    	scoreboardMB.put(temp);
				    	driverSingleMB.put(trans);
					portTwoTagCount = portTwoTagCount +1;
			
			end	


			for(int i = 0; i < portThreeCount; i ++)begin
					
					trans = new();
					trans.port = 2'b10;
					trans.tag_in = portThreeTagCount;
				    	trans.randomize();
				    	trans.displayInputs();
					temp = new();
				  	temp.copy(trans);
				    	scoreboardMB.put(temp);
				    	driverSingleMB.put(trans);
					portThreeTagCount = portThreeTagCount +1;
			end	


			for(int i = 0; i < portFourCount; i ++)begin
					
					trans = new();
					trans.port = 2'b11;
					trans.tag_in = portFourTagCount;
				    	trans.randomize();
				    	trans.displayInputs();
					temp = new();
				  	temp.copy(trans);
				    	scoreboardMB.put(temp);
				    	driverSingleMB.put(trans);
					portFourTagCount = portFourTagCount + 1;
			end	
				//make a copy here
			->gen_done;
			
			
			//wait until the checker has completed
			@(check_done);
		
		end
		end
		$display("T: %0t [Generator] Test finished", $time);
		//->test_done;
		$finish;
		endtask

		task stringtoTran(string line);


		endtask
			

	endclass
endpackage
