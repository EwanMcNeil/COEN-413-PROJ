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
    		//randc logic [0:1] tag_in;
		logic [0:1] tag_in;

		//outputs of device 
		logic [0:1] resp;
		logic [0:31] data_out;
		logic [0:1] tag_out;
		
		//0001 add, 0010 sub, 0101 shift left, 0110 shift right
		constraint commandValid {((cmd == 1) || (cmd == 2) || (cmd == 5) || (cmd ==6));}
		//constraint commandValid {(cmd == 1);}
		//constraint portValid{((port == 0) || (port == 1) || (port == 2) || (port ==3));}
		constraint tagValid{((tag_in == 0) || (tag_in == 1) || (tag_in == 2)  || (tag_in == 3));}
		constraint dataOne{data_in_1 > 1; data_in_1 < 100;}
		constraint dataTwo{data_in_2 > 1; data_in_2 < 100;}

		//TODO make the random values be made by the generator
		/*function new(logic [0:1] inPort = 0, logic [0:1] inTag = 0);
			port = '{default:inPort};
			tag_in = '{default:inTag};
		endfunction*/

		function new(logic [0:1] inPort, logic [0:1] inTag);
			port = inPort;
			tag_in = inTag;
			//$display("new transaction Port:%b tag:%b",port,tag_in);
		endfunction

		function void displayInputs();
			 $display("T: %0t [Transaction] port: %b cmd: %b data_in_1: %0d data_in_2: %0d tag_in: %b", $time, port, cmd, data_in_1, data_in_2, tag_in);
		endfunction

		//added a deep copy function
		function void copy(Transaction tmp);
    			this.cmd = tmp.cmd;
    			this.data_in_1 = tmp.data_in_1;
   			this.data_in_2 = tmp.data_in_2;
    			this.tag_in = tmp.tag_in;
  		endfunction
	endclass
		
	//driver class
	class DriverSingle;
		virtual dut_IF IF;
		mailbox driverSingleMB;
		event drv_done;

		task run();
			$display("T: %0t [Driver] starting...", $time);

			forever begin
				Transaction trans;

				driverSingleMB.get(trans);
				$display("T: %0t [Driver] receiving transaction from Generator", $time);

				$display("T: %0t [Driver] port: %b cmd: %b Data1: %0d Data2: %0d Tag: %b", $time, trans.port, trans.cmd, trans.data_in_1, trans.data_in_2, trans.tag_in);

				if(trans.port == 00) begin
					IF.cb.req1_cmd_in <= trans.cmd;
					IF.cb.req1_tag_in <= trans.tag_in;
					IF.cb.req1_data_in <= trans.data_in_1;
					@(IF.cb);
					IF.cb.req1_data_in <= trans.data_in_2;
				end

				if(trans.port == 01) begin
					IF.cb.req2_cmd_in <= trans.cmd;
					IF.cb.req2_tag_in <= trans.tag_in;
					IF.cb.req2_data_in <= trans.data_in_1;
					@(IF.cb);
					IF.cb.req2_data_in <= trans.data_in_2;
				end

				if(trans.port == 10) begin
					IF.cb.req3_cmd_in <= trans.cmd;
					IF.cb.req3_tag_in <= trans.tag_in;
					IF.cb.req3_data_in <= trans.data_in_1;
					@(IF.cb);
					IF.cb.req3_data_in <= trans.data_in_2;
				end

				if(trans.port == 11) begin
					IF.cb.req4_cmd_in <= trans.cmd;
					IF.cb.req4_tag_in <= trans.tag_in;
					IF.cb.req4_data_in <= trans.data_in_1;
					@(IF.cb);
					IF.cb.req4_data_in <= trans.data_in_2;
				end

				@(IF.c_clk);
				@(IF.c_clk);
				@(IF.c_clk);
				@(IF.c_clk);

				@(posedge IF.c_clk);
					->drv_done;
			end
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

		task run();
			$display("T: %0t [Monitor] starting...", $time);
		
			fork
				watchInputOne();
				watchInputTwo();
				watchInputThree();
				watchInputFour();
		 	join
		endtask
			
		
		//This concept of watching the inputs maybe isnt needed
		task watchInputOne();
			forever begin
				Transaction fresh;

		   		@(IF.cb.req1_data_in);
		   		
				//make a new transaction object
				$display("T: %0t [Monitor] seeing new transaction on port 0", $time);
				fresh = new(2'b00,IF.cb.req1_tag_in);		//port is 00 and pass new tag in
				fresh.cmd = IF.cb.req1_cmd_in;
				fresh.data_in_1 = IF.cb.req1_data_in;
	
		  		@(IF.cb.req1_data_in)
				fresh.data_in_2 = IF.cb.req1_data_in;
				fresh.displayInputs();

		  		fork
					watchOutputOne(fresh);
		  		join_none
		  		//join none so the watchInputOne is restarted
	         	end
		endtask

		task watchInputTwo();
			forever begin
				Transaction fresh;

		   		@(IF.cb.req2_data_in);
		   		
				//make a new transaction object
				$display("T: %0t [Monitor] seeing new transaction on port 1", $time);
				fresh = new(2'b01,IF.cb.req2_tag_in);		//port is 01 and pass new tag in
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
		endtask

		task watchInputThree();
			forever begin
				Transaction fresh;

		   		@(IF.cb.req3_data_in);
		   		
				//make a new transaction object
				$display("T: %0t [Monitor] seeing new transaction on port 2", $time);
				fresh = new(2'b10,IF.cb.req3_tag_in);		//port is 01 and pass new tag in
				fresh.cmd = IF.cb.req3_cmd_in;
				fresh.data_in_1 = IF.cb.req3_data_in;
	
		  		@(IF.cb.req3_data_in)
				fresh.data_in_2 = IF.cb.req3_data_in;
				fresh.displayInputs();

		  		fork
					watchOutputThree(fresh);
		  		join_none
		  		//join none so the watchInputThree is restarted
	         	end
		endtask

		task watchInputFour();
			forever begin
				Transaction fresh;

		   		@(IF.cb.req4_data_in);
		   		
				//make a new transaction object
				$display("T: %0t [Monitor] seeing new transaction on port 3", $time);
				fresh = new(2'b11,IF.cb.req4_tag_in);		//port is 01 and pass new tag in
				fresh.cmd = IF.cb.req4_cmd_in;
				fresh.data_in_1 = IF.cb.req4_data_in;
	
		  		@(IF.cb.req4_data_in)
				fresh.data_in_2 = IF.cb.req4_data_in;
				fresh.displayInputs();

		  		fork
					watchOutputFour(fresh);
		  		join_none
		  		//join none so the watchInputFour is restarted
	         	end
		endtask

		task watchOutputOne(Transaction fresh);
			$display("T: %0t [Monitor] waiting for response on port 0", $time);

			//TODO wait for equal tag
			@(IF.cb.out_resp1)
				fresh = new(2'b00,IF.req1_tag_in);
				fresh.resp = IF.out_resp1;
				fresh.data_out = IF.out_data1;
				fresh.tag_out = IF.out_tag1;
			
			$display("T: %0t [Monitor] received response on port 0", $time);
			$display("T: %0t [Monitor] Resp: %b Data: %0d Tag out: %b", $time, fresh.resp, fresh.data_out, fresh.tag_out);

			//TODO
			//then send over to the scoreboard
		endtask

		task watchOutputTwo(Transaction fresh);	
			$display("T: %0t [Monitor] waiting for response on port 1", $time);

			//TODO wait for equal tag
			@(IF.cb.out_resp2)
				fresh = new(2'b01,IF.req2_tag_in);
				fresh.resp = IF.out_resp2;
				fresh.data_out = IF.out_data2;
				fresh.tag_out = IF.out_tag2;
			
			$display("T: %0t [Monitor] received response on port 1", $time);
			$display("T: %0t [Monitor] Resp: %b Data: %0d Tag out: %b", $time, fresh.resp, fresh.data_out, fresh.tag_out);

			//TODO
			//then send over to the scoreboard
		endtask

		task watchOutputThree(Transaction fresh);
			$display("T: %0t [Monitor] waiting for response on port 2", $time);

			//TODO wait for equal tag
			@(IF.cb.out_resp3)
				fresh = new(2'b10,IF.req3_tag_in);
				fresh.resp = IF.out_resp3;
				fresh.data_out = IF.out_data3;
				fresh.tag_out = IF.out_tag3;
			
			$display("T: %0t [Monitor] received response on port 2", $time);
			$display("T: %0t [Monitor] Resp: %b Data: %0d Tag out: %b", $time, fresh.resp, fresh.data_out, fresh.tag_out);

			//TODO
			//then send over to the scoreboard
		endtask

		task watchOutputFour(Transaction fresh);
			$display("T: %0t [Monitor] waiting for response on port 3", $time);

			//TODO wait for equal tag
			@(IF.cb.out_resp4)
				fresh = new(2'b11,IF.req4_tag_in);
				fresh.resp = IF.out_resp4;
				fresh.data_out = IF.out_data4;
				fresh.tag_out = IF.out_tag4;
			
			$display("T: %0t [Monitor] received response on port 3", $time);
			$display("T: %0t [Monitor] Resp: %b Data: %0d Tag out: %b", $time, fresh.resp, fresh.data_out, fresh.tag_out);

			//TODO
			//then send over to the scoreboard
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
	class Scoreboard;
		mailbox scoreboardMB;
		mailbox SBtocheckerMB;
		int i = 1;
 		task run();

   			forever begin
				//trying to see if using the same mailbox as driver single works when using the get function

     				Transaction ref_item;
				scoreboardMB.get(ref_item);

				$display("T: %0t [Scoreboard] cmd: %b tag: %b data1: %0d data2: %0d", $time, ref_item.cmd, ref_item.tag_in, ref_item.data_in_1, ref_item.data_in_2);

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

				SBtocheckerMB.put(ref_item);
			end
 		endtask
	endclass

	//checker 
	class Checker;
		mailbox SBtocheckerMB;
		mailbox MNtocheckerMB;

		task run();
   			forever begin
				Transaction SBoutput, MNoutput;

				SBtocheckerMB.get(SBoutput);
				
				$display("T: %0t [Checker] Scoreboard output is %0d", $time, SBoutput.data_out);
			end
		endtask
	endclass

	///
	///Scenario block
	///

	//generator
	//maybe we should do both, bundles and signal ones
	//generator generates bundles of transactions 
	class Generator;
		mailbox driverSingleMB;
		mailbox scoreboardMB;
		event drv_done;
		Transaction trans, temp;
			
		task run();
			for(int i = 0; i < 1; i++)begin
				$display("T: %0t [Generator] making a new object", $time);
				trans = new(2'b00, 2'b00);
				trans.randomize();
				trans.displayInputs();
				driverSingleMB.put(trans);
				@(drv_done);

				//make a copy here
				temp = new(2'b00, 2'b00);
				temp.copy(trans);

				scoreboardMB.put(temp);
			end

			$display("T: %0t [Generator] done generation of transactions", $time);
		endtask
	endclass
endpackage
