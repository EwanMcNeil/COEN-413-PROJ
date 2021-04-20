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

		//outputs of device 
		logic [0:1] resp;
		logic [0:31] data_out;
		logic [0:1] tag_out;
		
		//0001 add
		//0010 sub
		constraint commandValid {((cmd == 1) || (cmd == 2) || (cmd == 5) || (cmd ==6));}
		//constraint portValid{((port == 0) || (port == 1) || (port == 2) || (port ==3));}
		constraint tagValid{((tag_in == 1) || (tag_in == 2) || (tag_in ==3)  ||(tag_in == 0));}
		constraint dataOne{ data_in_1 > 1; data_in_1 < 100;}
		constraint dataTwo{ data_in_2 > 1; data_in_2 < 100;}

		//TODO make the random values be made by the generator
		function new(logic [0:1] inPort, logic [0:1] inTag);
			port = inPort;
			tag_in = inTag;
			$display("new transaction Port:%b tag:%b",port,tag_in);
		endfunction


		function displayInputs();
			 $display("cmd: %b, data_in_1: %d, data_in_2: %d, tag_in: %b", cmd,data_in_1,data_in_2,tag_in);
		endfunction

		//added a deep copy function
		
		
	endclass
	

	//randomize ports being sent commands
	//and how many commands on each port. 
	//beacuse these are not signals the $random function is used
	class bundleTransaction;
		int port1;
		int port2;
		int port3;
		int port4;
		int oneCommandCount;
		int twoCommandCount;
		int threeCommandCount;
		int fourCommandCount;
		Transaction portOneList[];
		Transaction portTwoList[];
		Transaction portThreeList[];
		Transaction portFourList[];

	
		function new();
		port1 = 1;
		port2 = 1;
		port3 = 1;
		port4 = 1;
		oneCommandCount  = $urandom_range(0,4);
		twoCommandCount  = $urandom_range(0,4);
		threeCommandCount  = $urandom_range(0,4);
		fourCommandCount  = $urandom_range(0,4);

		portOneList = new[oneCommandCount];
		portTwoList = new[twoCommandCount];
		portThreeList= new[threeCommandCount];
		portFourList =new[fourCommandCount];


		if(port1 == 1)begin 
			foreach(portOneList[i])begin
				 portOneList[i] = new(2'b00,tagCoversion(i));
	    			 portOneList[i].randomize();
			end

		end

		if(port2 == 1)begin
			foreach(portTwoList[i])begin
				 portTwoList[i] = new(2'b01,tagCoversion(i));
	    			 portTwoList[i].randomize();
				

			end
		
		end

		if(port3 == 1)begin
			foreach(portThreeList[i])begin
				 portThreeList[i] = new(2'b10,tagCoversion(i));
	    			 portThreeList[i].randomize();
				
			end
		
		end 

		if(port4 == 1)begin
			foreach(portFourList[i])begin
				 portFourList[i] = new(2'b11,tagCoversion(i));
	    			 portFourList[i].randomize();
				

			end

		end



		endfunction


		function bit[0:1] tagCoversion(int count);
			if(count == 0)
				return 2'b00;
			else if(count ==1)
				return 2'b01;
			if(count ==2)
				return 2'b10;
			if(count ==3)
				return 2'b11;
			
		
		endfunction 

		function displayBundle();
		if(port1 == 1)begin 
			for(int i = 0; i < oneCommandCount; i ++)begin
	    			 portOneList[i].displayInputs();
			end

		end

		if(port2 == 1)begin
			for(int i = 0; i < twoCommandCount; i ++)begin
	    			 portTwoList[i].displayInputs();

			end
		
		end

		if(port3 == 1)begin
			for(int i = 0; i < threeCommandCount; i ++)begin
	    			 portThreeList[i].displayInputs();
			end
		
		end 

		if(port4 == 1)begin
			for(int i = 0; i < fourCommandCount; i ++)begin
	    			 portFourList[i].displayInputs();

			end

		end

		endfunction



	
	endclass 
		
		
		



		
	//driver class
	class DriverSingle;
		virtual dut_IF IF;
		mailbox driverSingleMB;
		task run();



			$display("Driver: starting");

			forever begin


			
			Transaction trans;

			driverSingleMB.get(trans);
			$display("Driver: Transmitting bundle from Generator at time %t ", $time);

				$display("values: Cmd: %b , Data1%b, Data2%b, tag%b", trans.cmd,trans.data_in_1,trans.data_in_2,trans.tag_in);
				$display("on port", trans.port);

				if(trans.port == 00)begin
					
					IF.cb.req1_cmd_in <= trans.cmd;
					IF.cb.req1_tag_in <= trans.tag_in;
					IF.cb.req1_data_in <= trans.data_in_1;
					$display("first data drive");
					@(IF.cb);
					//IF.printIF();
					IF.cb.req1_data_in <= trans.data_in_2;
					//@(IF.cb);
					//$display("Second data drive");
					//IF.printIF();
				end

				if(trans.port == 01)begin
					IF.cb.req2_cmd_in <= trans.cmd;
					IF.cb.req2_tag_in <= trans.tag_in;
					IF.cb.req2_data_in <= trans.data_in_1;
					@(IF.cb);
					IF.cb.req2_data_in <= trans.data_in_2;
				end

				if(trans.port ==10)begin
					IF.cb.req3_cmd_in <= trans.cmd;
					IF.cb.req3_tag_in <= trans.tag_in;
					IF.cb.req3_data_in <= trans.data_in_1;
					@(IF.cb);
					IF.cb.req3_data_in <= trans.data_in_2;
				end

				if(trans.port == 11)begin
					IF.cb.req4_cmd_in <= trans.cmd;
					IF.cb.req4_tag_in <= trans.tag_in;
					IF.cb.req4_data_in <= trans.data_in_1;
					@(IF.cb);
					IF.cb.req4_data_in <= trans.data_in_2;
				end

			//IF.printIF();
			@(IF.c_clk);
			@(IF.c_clk);
			@(IF.c_clk);
			@(IF.c_clk);

		
		end
	endtask


	endclass





	
	

	///
	///Command block
	///

	//driver class
	class Driver;
		virtual dut_IF IF;
		mailbox driverMB;

		function reset();
			IF.reset = 7'b1111111;

			//fixt reset function
			//IF.cb.req1_cmd_in <= 4b'0000;
		endfunction;

		task run();



			$display("Driver: starting");

			forever begin


			bundleTransaction bundle;
			Transaction singleTran;

			driverMB.get(bundle);
			$display("Driver: Transmitting bundle from Generator at time %t ", $time);
			for(int i = 0; i < 4; i++)begin
				

			
				//first data1
				@(IF.c_clk);
				if(bundle.port1 == 1)begin
					if(bundle.oneCommandCount > i)begin
						$display("Driver: Transmitting transaction on port 1");
						bundle.portOneList[i].displayInputs();
						IF.cb.req1_cmd_in <= bundle.portOneList[i].cmd;
						IF.cb.req1_tag_in <= bundle.portOneList[i].tag_in;
						IF.cb.req1_data_in <= bundle.portOneList[i].data_in_1;
					end
				end
				if(bundle.port2 == 1)begin
					if(bundle.twoCommandCount > i)begin
						$display("Driver: Transmitting transaction on port 2");
						bundle.portTwoList[i].displayInputs();
						IF.cb.req2_cmd_in <= bundle.portTwoList[i].cmd;
						IF.cb.req2_tag_in <= bundle.portTwoList[i].tag_in;
						IF.cb.req2_data_in <= bundle.portTwoList[i].data_in_1;
					end
				end
				if(bundle.port3 == 1)begin
					if(bundle.threeCommandCount > i)begin
						$display("Driver: Transmitting transaction on port 3");
						bundle.portThreeList[i].displayInputs();
						IF.cb.req3_cmd_in <= bundle.portThreeList[i].cmd;
						IF.cb.req3_tag_in <= bundle.portThreeList[i].tag_in;
						IF.cb.req3_data_in <= bundle.portThreeList[i].data_in_1;
					end
				end
				if(bundle.port4 == 1)begin
					if(bundle.fourCommandCount > i)begin
						$display("Driver: Transmitting transaction on port 4");
						bundle.portFourList[i].displayInputs();
						IF.cb.req4_cmd_in <= bundle.portFourList[i].cmd;
						IF.cb.req4_tag_in <= bundle.portFourList[i].tag_in;
						IF.cb.req4_data_in <= bundle.portFourList[i].data_in_1;
					end
				end

				
				@(IF.c_clk);
				//second clk cycle for data_2
				if(bundle.port1 == 1)begin
					if(bundle.oneCommandCount > i)begin
					$display("Driver: Transmitting data2 on port 1");
						IF.cb.req1_data_in <= bundle.portOneList[i].data_in_2;
					end
				end
				if(bundle.port1 == 2)begin
					if(bundle.oneCommandCount > i)begin
					$display("Driver: Transmitting data2 on port 2");
						IF.cb.req2_data_in <= bundle.portTwoList[i].data_in_2;
					end
				end
				if(bundle.port1 == 3)begin
					if(bundle.oneCommandCount > i)begin
						$display("Driver: Transmitting data2 on port 3");
						IF.cb.req3_data_in <= bundle.portThreeList[i].data_in_2;
					end
				end
				if(bundle.port1 == 4)begin
					if(bundle.oneCommandCount > i)begin
						$display("Driver: Transmitting data2 on port 4");
						IF.cb.req4_data_in <= bundle.portFourList[i].data_in_2;
					end
				end



				//second data clock
			end

			
			end
			
		endtask;


		  task resetTask();
			$display("reseting");
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





			@(IF.cb);
			@(IF.cb);
			@(IF.cb);
		     

			IF.reset = 0; 
    		endtask



	endclass


	//monitor
	//four threads looking at each of the input/ output ports 
	//but multiple commands could be running so maybe fork a new internally?


		class Monitor;
			//link to the interface

			virtual dut_IF IF;
			
			//TODO 
			mailbox scoreboardMail;

		task run();
			$display("starting the monitor");
		 fork
			watchInputOne();

			//watchOutputOne();
			//watchOutputTwo();
			//watchOutputThree();
			//watchOutputFour();
		 join
		endtask
			

		
		//This concept of watching the inputs maybe isnt needed
		task watchInputOne();
		 forever begin
		   Transaction fresh;

		   @(IF.cb.req1_data_in);
		   //make a new transaction object
			$display("Monitor: seeing new transaction on port 1 at time %t", $time);
			//IF.printIF();
			fresh = new(2'b00,IF.cb.req1_tag_in);		//port is 00 and pass new tag in
			fresh.cmd = IF.cb.req1_cmd_in;
			fresh.data_in_1 = IF.cb.req1_data_in;
	
	
		  @(IF.cb.req1_data_in)
			fresh.data_in_2 = IF.cb.req1_data_in;
			$display("Monitor:");
			fresh.displayInputs();

			
		  fork
			watchOutputOne(fresh);
		  join_none
		  //join none so the watchinputoOne is resarted
		
		
		
	         end


		endtask

		task watchOutputOne(Transaction fresh);
		//task watchOutputOne();
		
		$display("Monitor: waiting for response on port 1");

			
			//TODO wait for equal tag
			@(IF.cb.out_resp1)
				fresh = new(2'b00,IF.req1_tag_in);
				fresh.resp = IF.out_resp1;
				fresh.data_out = IF.out_data1;
				fresh.tag_out = IF.out_tag1;
			
			$display("Monitor Received response on port one");
			$display("Resp: %b", fresh.resp);
			$display("Data: %b", fresh.data_out);
			$display("Tag: %b", fresh.tag_out);

		//TODO
		//then send over to the scoreboard
		
		
		
		endtask

		task watchOutputTwo();
		Transaction fresh;
		$display("Monitor: waiting for response on port 2");

		forever begin
			@(IF.out_resp2)
				fresh = new(2'b01,IF.req2_tag_in);
				fresh.resp = IF.out_resp2;
				fresh.data_out = IF.out_data2;
				fresh.tag_out = IF.out_tag2;
			
			
			$display("Monitor Received response on port 2");
			$display("Resp: %b", fresh.resp);
			$display("Data: %b", fresh.data_out);
			$display("Tag: %b", fresh.tag_out);

		//TODO
		//then send over to the scoreboard
		
		
		end
		endtask

		task watchOutputThree();
		Transaction fresh;
		$display("Monitor: waiting for response on port 3");

		forever begin
			@(IF.out_resp3)
				fresh = new(2'b10,IF.req3_tag_in);
				fresh.resp = IF.out_resp3;
				fresh.data_out = IF.out_data3;
				fresh.tag_out = IF.out_tag3;
			
			
			$display("Monitor Received response on port 3");
			$display("Resp: %b", fresh.resp);
			$display("Data: %b", fresh.data_out);
			$display("Tag: %b", fresh.tag_out);

		//TODO
		//then send over to the scoreboard
		
	
		end
		endtask


		task watchOutputFour();
		Transaction fresh;
		$display("Monitor: waiting for response on port 3");

		forever begin
			@(IF.out_resp4)
				fresh = new(2'b11,IF.req4_tag_in);
				fresh.resp = IF.out_resp4;
				fresh.data_out = IF.out_data4;
				fresh.tag_out = IF.out_tag4;
			
			
			$display("Monitor Received response on port 4");
			$display("Resp: %b", fresh.resp);
			$display("Data: %b", fresh.data_out);
			$display("Tag: %b", fresh.tag_out);

		//TODO
		//then send over to the scoreboard
		
		
		end
		endtask
			
					
		
		endclass


	///
	///Functional block
	///
	
	//agent class
		//*

		//class Agent;
		//endclass

	//scoreboard


		//class Scoreboard;
		//endclass


	//checker 

	

		
		//class Checker;
		//endclass


	
	///
	///Scenario block
	///


	//generator
		
		//maybe we should do both, bundles and signel ones
		//generator generates bundles of transactions 
		class Generator;
			mailbox driverSingleMB;
			mailbox driverMB;
			bundleTransaction bundle;
			Transaction trans;
			
			task run();
				 for(int i = 0; i < 2; i++)begin
				    $display("Generator: making new object");
				    trans = new(2'b00,2'b00);
				    trans.randomize();
				    trans.displayInputs();
				    driverSingleMB.put(trans);
				  end
			

			/*
				  for(int i = 0; i < 1; i++)begin
				    $display("Generator: making new object");
				    bundle = new();
				    bundle.randomize();
				    bundle.displayBundle();
				    driverMB.put(bundle);
				  end
		*/

			endtask
		endclass
	
endpackage
		
