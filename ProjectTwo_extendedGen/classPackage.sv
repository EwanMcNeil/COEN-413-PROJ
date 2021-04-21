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
		//constraint commandValid {(cmd == 1);}
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

		function displayAll();
			 $display("T: %0t [Transaction] port: %b cmd: %b data_in_1: %0d data_in_2: %0d tag_in: %b , resp: %b  tag_out: %0d data_out: %b ,", $time, port, cmd, data_in_1, data_in_2, tag_in,resp,tag_out, data_out);

		endfunction

		//added a deep copy function
		function void copy(Transaction tmp);
			this.port =tmp.port;
    			this.cmd = tmp.cmd;
    			this.data_in_1 = tmp.data_in_1;
   			this.data_in_2 = tmp.data_in_2;
    			this.tag_in = tmp.tag_in;

			//adding outputs to compy
			this.data_out = tmp.data_out;
			this.resp = tmp.resp;
			this.tag_out = tmp.tag_out;
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

		covergroup cg;
			CMD1: coverpoint IF.cb.req1_cmd_in {bins CMD = {4'b0001,4'b0010,4'b0101,4'b0110};}
			CMD2: coverpoint IF.cb.req2_cmd_in {bins CMD = {4'b0001,4'b0010,4'b0101,4'b0110};}
			CMD3: coverpoint IF.cb.req3_cmd_in {bins CMD = {4'b0001,4'b0010,4'b0101,4'b0110};}
			CMD4: coverpoint IF.cb.req4_cmd_in {bins CMD = {4'b0001,4'b0010,4'b0101,4'b0110};}
			DATA1: coverpoint IF.cb.req1_data_in;
			DATA2: coverpoint IF.cb.req2_data_in;
			DATA3: coverpoint IF.cb.req3_data_in;
			DATA4: coverpoint IF.cb.req4_data_in;
			TAG1: coverpoint IF.cb.req1_tag_in;
			TAG2: coverpoint IF.cb.req2_tag_in;
			TAG3: coverpoint IF.cb.req3_tag_in;
			TAG4: coverpoint IF.cb.req4_tag_in;

		endgroup
		

		function new();
			cg = new();
		endfunction


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
			
				//sample for data and commands 
				cg.sample();

				
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

				//sample for data and commands 
				cg.sample();

			
			$display("T: %0t [Driver] LOOP", $time);
				end

			//give it a couple cycles before ending
			for(int i =0; i < 10; i++)begin
				@(posedge IF.c_clk);
			end
	
			

			$display("\n");
			$display("T: %0t [Coverage] Current total coverage is %0.2f",$time, cg.get_coverage());
			$display("\n");
			$display("T: %0t [Coverage] Port One:",$time);
			$display("T: %0t [Coverage] CMD coverage is %0.2f",$time, cg.CMD1.get_coverage());
			$display("T: %0t [Coverage] TAG coverage is %0.2f",$time, cg.TAG1.get_coverage());
			$display("T: %0t [Coverage] DATA coverage is %0.2f",$time, cg.DATA1.get_coverage());
			$display("\n");
			$display("T: %0t [Coverage] Port Two:",$time);
			$display("T: %0t [Coverage] CMD coverage is %0.2f",$time, cg.CMD2.get_coverage());
			$display("T: %0t [Coverage] TAG coverage is %0.2f",$time, cg.TAG2.get_coverage());
			$display("T: %0t [Coverage] DATA coverage is %0.2f",$time, cg.DATA2.get_coverage());
			$display("\n");
			$display("T: %0t [Coverage] Port Three:",$time);
			$display("T: %0t [Coverage] CMD coverage is %0.2f",$time, cg.CMD3.get_coverage());
			$display("T: %0t [Coverage] TAG coverage is %0.2f",$time, cg.TAG3.get_coverage());
			$display("T: %0t [Coverage] DATA coverage is %0.2f",$time, cg.DATA3.get_coverage());
			$display("\n");
			$display("T: %0t [Coverage] Port Four:",$time);
			$display("T: %0t [Coverage] CMD coverage is %0.2f",$time, cg.CMD4.get_coverage());
			$display("T: %0t [Coverage] TAG coverage is %0.2f",$time, cg.TAG4.get_coverage());
			$display("T: %0t [Coverage] DATA coverage is %0.2f",$time, cg.DATA4.get_coverage());

			
		

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
		int transactionCount;

		Transaction portOne[$];
		Transaction portTwo[$];
		Transaction portThree[$];
		Transaction portFour[$];

		task run();
			$display("T: %0t [Monitor] starting...", $time);
			threadCount = 0;
		
			fork
				watchInputOne();
				watchInputTwo();
				watchInputThree();
				watchInputFour();
				watchOutputOne();
				watchOutputTwo();
				watchOutputThree();
				watchOutputFour();
			
			
				waitDriver();
		 	join


			
		endtask
			task waitDriver();
			//not quite sure if this is setup correctly
			forever begin
				
				@(drv_done);

				$display("\n");

				if (portOne.size() > 0)begin
				$display("T: %0t [Monitor]Port One Commands not responded to: ", $time);
				foreach(portOne[i])begin 
					portOne[i].displayAll();
				end
				portOne.delete();
				end
				if (portTwo.size() > 0)begin
				$display("T: %0t [Monitor]Port Two Commands not responded to: ", $time);
				foreach(portTwo[i])begin 
					portTwo[i].displayAll();
				end
				portTwo.delete();
				end
				if( portThree.size() > 0)begin
				$display("T: %0t [Monitor]Port Three Commands not responded to: ", $time);
				foreach(portThree[i])begin 
					portThree[i].displayAll();
				end
				portThree.delete();
				end
				if (portFour.size() > 0)begin
				$display("T: %0t [Monitor]Port Four Commands not responded to: ", $time);
				foreach(portFour[i])begin 
					portFour[i].displayAll();
				end
				portFour.delete();
	
				end


				//->mon_done;
				//$display("T: %0t [Monitor] Monitor finished", $time);
				
			end
			endtask
		
		//This concept of watching the inputs maybe isnt needed
		task watchInputOne();
			forever begin
				Transaction fresh;
				$display("T: %0t [Monitor] watching port one", $time);
		   		@(IF.cb.req1_tag_in);
				if(IF.reset == 0)begin
		   		transactionCount = transactionCount +1;
				//make a new transaction object
				$display("T: %0t [Monitor] seeing new transaction on port Tag total trans: %0d", $time,IF.cb.req1_tag_in );
				fresh = new();		//port is 00 and pass new tag in
				fresh.port = 2'b00;
				fresh.tag_in = IF.cb.req1_tag_in;
				fresh.cmd = IF.cb.req1_cmd_in;
				fresh.data_in_1 = IF.cb.req1_data_in;
	
		  		@(posedge IF.cb)
				@(posedge IF.cb)
				fresh.data_in_2 = IF.cb.req1_data_in;
				fresh.displayInputs();

		  		portOne.push_front(fresh);
				end
	         	end
		endtask

		task watchInputTwo();
			forever begin
				
				Transaction fresh;
				$display("T: %0t [Monitor] watching port Two", $time);
		   		@(IF.cb.req2_tag_in);
				if(IF.reset == 0)begin
		   		transactionCount = transactionCount +1;
				//make a new transaction object
				$display("T: %0t [Monitor] seeing new transaction on port Two with Tag : %0d", $time,IF.cb.req2_tag_in );
				fresh = new();		//port is 00 and pass new tag in
				fresh.port = 2'b01;
				fresh.tag_in = IF.cb.req2_tag_in;
				fresh.cmd = IF.cb.req2_cmd_in;
				fresh.data_in_1 = IF.cb.req2_data_in;
	
		  		@(posedge IF.cb)
				@(posedge IF.cb)
				fresh.data_in_2 = IF.cb.req2_data_in;
				fresh.displayInputs();

		  		portTwo.push_front(fresh);
				end
	         	end
		endtask

		task watchInputThree();
			forever begin
				Transaction fresh;

		   		@(IF.cb.req3_tag_in);
		   		if(IF.reset == 0)begin
				transactionCount = transactionCount +1;
				//make a new transaction object
				
				fresh = new();		//port is 10 and pass new tag in
				fresh.port = 2'b10;
				fresh.tag_in = IF.cb.req3_tag_in;
				fresh.cmd = IF.cb.req3_cmd_in;
				fresh.data_in_1 = IF.cb.req3_data_in;
	
		  		@(posedge IF.cb)
				@(posedge IF.cb)
				$display("T: %0t [Monitor] seeing new transaction on port R", $time);
				fresh.data_in_2 = IF.cb.req3_data_in;
				fresh.displayInputs();

		  		portThree.push_front(fresh);
				end
		  		//join none so the watchInputThree is restarted
	         	end
		endtask

		task watchInputFour();
			forever begin
				Transaction fresh;
				
		   		@(IF.cb.req4_tag_in);
		   		if(IF.reset == 0)begin
				transactionCount = transactionCount +1;
				//make a new transaction object
				$display("T: %0t [Monitor] seeing new transaction on port 4 with tag: %0d", $time, IF.cb.req4_tag_in);
				fresh = new();		//port is 10 and pass new tag in
				fresh.port = 2'b11;
				fresh.tag_in = IF.cb.req4_tag_in;
				fresh.cmd = IF.cb.req4_cmd_in;
				fresh.data_in_1 = IF.cb.req4_data_in;
	
		  		@(posedge IF.cb)
				@(posedge IF.cb)
				fresh.data_in_2 = IF.cb.req4_data_in;
				fresh.displayInputs();

		  		portFour.push_front(fresh);
				end
		  		
	         	end
		endtask

		task watchOutputOne();
			Transaction fresh[$];
			Transaction fromDUT;
			int indexQ[$];
			int index;
			forever begin
				
				@(IF.cb.out_resp1);
			
				if(IF.reset == 0 && IF.cb.out_resp1 != 2'b00)begin
				$display("T: %0t [Monitor]Port One Response Asserted %d", $time,IF.cb.out_resp1);
				fresh = portOne.find() with (item.tag_in == IF.cb.out_tag1);
				

				if(fresh.size > 0)begin
				indexQ = portOne.find_index() with (item.tag_in == IF.cb.out_tag1);
				index = indexQ.pop_front();
				portOne.delete(index);
				fromDUT = fresh.pop_front();
				fromDUT.resp = IF.cb.out_resp1;
				fromDUT.data_out = IF.cb.out_data1;
				fromDUT.tag_out = IF.cb.out_tag1;
			
				
				MNtocheckerMB.put(fromDUT);
				end else begin
					$display("T: %0t [Monitor]Port One: ERROR Response Recieved with No matching command", $time);
				end
			 
			end
		end
		endtask

		task watchOutputTwo();	
			Transaction fresh[$];
				Transaction fromDUT;
			int index;
			int indexQ[$];
			forever begin
			
				@(IF.cb.out_resp2);
				if(IF.reset == 0 & IF.cb.out_resp2 != 2'b00)begin
				$display("T: %0t [Monitor]Port Two Response Asserted %d", $time,IF.cb.out_resp2);
				fresh = portTwo.find() with (item.tag_in == IF.cb.out_tag2);
				
				if(fresh.size > 0)begin
				indexQ = portTwo.find_index() with (item.tag_in == IF.cb.out_tag2);
				index = indexQ.pop_front();
				portTwo.delete(index);
		
				fromDUT = fresh.pop_front();
				fromDUT.resp = IF.cb.out_resp2;
				fromDUT.data_out = IF.cb.out_data2;
				fromDUT.tag_out = IF.cb.out_tag2;
			
				$display("T: %0t [Monitor] received response on port 2", $time);
				
				MNtocheckerMB.put(fromDUT);
				end
				else begin
					$display("T: %0t [Monitor]Port Two: ERROR Response Recieved with No matching command", $time);
				end
			 
			end
			end

			
		endtask

		task watchOutputThree();
			Transaction fresh[$];
				Transaction fromDUT;
			int index;
			int indexQ[$];
			forever begin
				
				@(IF.cb.out_resp3);
				
				if(IF.reset == 0 && IF.cb.out_resp3 != 2'b00)begin
				$display("T: %0t [Monitor]Port Three Response Asserted %d", $time,IF.cb.out_resp3);
				fresh = portThree.find() with (item.tag_in == IF.cb.out_tag3);
				
		
				if(fresh.size > 0)begin
				indexQ = portThree.find_index() with (item.tag_in == IF.cb.out_tag3);
				index = indexQ.pop_front();
				portThree.delete(index);
				fromDUT = fresh.pop_front();
				fromDUT.resp = IF.cb.out_resp3;
				fromDUT.data_out = IF.cb.out_data3;
				fromDUT.tag_out = IF.cb.out_tag3;
			
				$display("T: %0t [Monitor] received response on port 3", $time);
				
				MNtocheckerMB.put(fromDUT);
				end
				else begin
					$display("T: %0t [Monitor]Port Two: ERROR Response Recieved with No matching command", $time);
				end
			 
			end
			end
		endtask

		task watchOutputFour();
			Transaction fresh[$];
				Transaction fromDUT;
				int index;
				int indexQ[$];

				forever begin
				
				@(IF.cb.out_resp4);
				
				if(IF.reset == 0 && IF.cb.out_resp4 != 2'b00)begin
				$display("T: %0t [Monitor]Port Four Response Asserted %d", $time,IF.cb.out_resp4);
				fresh = portFour.find() with (item.tag_in == IF.cb.out_tag4);
				
		
				if(fresh.size > 0)begin
				indexQ = portFour.find_index() with (item.tag_in == IF.cb.out_tag4);
				index = indexQ.pop_front();
				portFour.delete(index);
				fromDUT = fresh.pop_front();
				fromDUT.resp = IF.cb.out_resp4;
				fromDUT.data_out = IF.cb.out_data4;
				fromDUT.tag_out = IF.cb.out_tag4;
			
				$display("T: %0t [Monitor] received response on port 4", $time);
				
				MNtocheckerMB.put(fromDUT);
				end
				else begin
					$display("T: %0t [Monitor]Port Two: ERROR Response Recieved with No matching command", $time);
				end
			 
			end
				end
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
		logic [32:0] addCheck;
 		task run();

   			forever begin
				//trying to see if using the same mailbox as driver single works when using the get function

     				Transaction ref_item;
				scoreboardMB.get(ref_item);

				$display("[Scoreboard] cmd: %0d data1: %0d data2: %0d", ref_item.cmd, ref_item.data_in_1, ref_item.data_in_2);

				//Calculate the expected results
				if (ref_item.cmd == 1) begin
					addCheck = ref_item.data_in_1 + ref_item.data_in_2;
					
					if(addCheck[32] == 0)begin
						ref_item.data_out = ref_item.data_in_1 + ref_item.data_in_2;
						ref_item.resp = 2'b01;
					end else begin
						ref_item.data_out = 2'h0000000;
						ref_item.resp = 2'b10;
					end

				
				end

				else if (ref_item.cmd == 2) begin
					if (ref_item.data_in_1 >= ref_item.data_in_2) begin
						ref_item.data_out = ref_item.data_in_1 - ref_item.data_in_2;
						ref_item.resp = 2'b01;
					end

					else begin
						i = 0;
						ref_item.data_out = 2'h0000000;
						ref_item.resp = 2'b10;
						
					end
				end

				else if (ref_item.cmd == 5) begin
					ref_item.data_out = ref_item.data_in_1 << ref_item.data_in_2;
					ref_item.resp = 2'b01;
				end

				else if (ref_item.cmd == 6) begin
					ref_item.data_out = ref_item.data_in_1 >> ref_item.data_in_2;
					ref_item.resp = 2'b01;
				end
				
				if (i == 1) begin
					$display("T: %0t [Scoreboard] expected answer %0d", $time, ref_item.data_out);
					i = 1;
				end
				ref_item.tag_out = ref_item.tag_in;


				//TODO do the resp setting

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
		Transaction monitorQueue[$];

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
				Transaction compare;
				@(drv_done);
			
				

				$display("[Checker] Transactions from scoreboard seen : %0d ", compareTranQueue.size());
				$display("[Checker] Transactions from monitor seen : %0d ",monitorQueue.size() );

				$display("[Checker] Running Comparison  : %0d ",monitorQueue.size());

				
				while(monitorQueue.size > 0)begin 
					compare = monitorQueue.pop_front();
					$display("\n");
					$display("[Checker] Monitor Transaction recieved:");
					compare.displayAll();
					compareTrans(compare);
					
				end
				testCount = 0;
				monitorQueue.delete();
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
				Transaction fromDUT;
				fromDUT = new();
				MNtocheckerMB.get(MNoutput);
				$display("T: %0t [Checker] Recieved transaction from Monitor", $time);
				MNoutput.displayTagPort();
				fromDUT.copy(MNoutput);
				monitorQueue.push_back(fromDUT);
				testCount = testCount +1;
				
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
					$display("T: %0t [Checker] Comparing with Scoreboard reference:", $time);
					compareTo =  fromScore.pop_front();
					compareTo.displayAll();
					if(compareTo.data_out != fromDUT.data_out)begin
						$display("[Checker]ERROR, data is %0d should be %0d",fromDUT.data_out,compareTo.data_out);
					end
					else begin
						$display("[Checker] CORRECT,data is %0d should be %0d",fromDUT.data_out,compareTo.data_out);
					end
					if(compareTo.resp != fromDUT.resp)begin
						$display("[Checker]ERROR, Resp is %0d should be %0d",fromDUT.resp,compareTo.resp);
					end
					else begin
						$display("[Checker]CORRECT, Resp is %0d should be %0d",fromDUT.resp,compareTo.resp);
					end
					
					//compareTranQueue.delete(index);
					//dont need to delete
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

		

		function new(mailbox driver, mailbox scoreboard, event check, event gen, event test);
			driverSingleMB = driver;
			scoreboardMB = scoreboard;
			check_done = check;
			gen_done = gen;
			test_done = test;
		
			
		endfunction
		
		
		


		task run();
			//going to comment loop for now to just test one operation
			//Pull in from config file to run generator
			configFile = $fopen("./testbenchConfig.txt", "r");

			//first line of the testbenchConfig is how many random scenerios to be generated
			$fgets(line,configFile);
			
			//noTests = line.atoi();
			noTests = 10;
			//if second line exists then hat is the input scenerio to be run -> no random sernario
			$fgets(line,configFile);
			
			if(!$feof(configFile))begin
				$display("T: %0t [Generator] Found user defined scenario ", $time);

			end

			else begin
				$display("T: %0t [Generator] Running %0d random scenerio", $time,noTests);
			//TODO randomize a number 1-16 to run	
			for(int j = 0; j< noTests; j++)begin
				$display("T: %0t [Generator] Making Test # %0b", $time,j);


			
			//Max of 16 possible commands running at once
			//doing it so theres always min of two
			portOneCount = $urandom_range(0,4);
			portTwoCount = $urandom_range(0,4);
			portThreeCount = $urandom_range(0,4);
			portFourCount = $urandom_range(0,4);
			portOneTagCount = 2'b11;
			portTwoTagCount = 2'b11;
			portThreeTagCount= 2'b11;
			portFourTagCount= 2'b11;
			

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
					portOneTagCount = portOneTagCount -1;
			
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
					portTwoTagCount = portTwoTagCount -1;
			
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
					portThreeTagCount = portThreeTagCount -1;
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
					portFourTagCount = portFourTagCount -1;
			end	
			
			//displayCoverage();
			
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
