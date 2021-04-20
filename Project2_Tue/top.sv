module Top;
   	bit	clk;	
    	always #50 clk = ~clk;	

	

    	dut_IF IF(.c_clk(clk));
    	
		
	
    	//testBench TEST(IF.TEST);

	calc2_top DUT(.c_clk(IF.c_clk), .reset(IF.reset), .req1_cmd_in(IF.req1_cmd_in), .req1_data_in(IF.req1_data_in),.req1_tag_in(IF.req1_tag_in), .out_resp1(IF.out_resp1), .out_data1(IF.out_data1), .out_tag1(IF.out_tag1),
			.req2_cmd_in(IF.req2_cmd_in), .req2_data_in(IF.req2_data_in),.req2_tag_in(IF.req2_tag_in), .out_resp2(IF.out_resp2), .out_data2(IF.out_data2), .out_tag2(IF.out_tag2),
			.req3_cmd_in(IF.req3_cmd_in), .req3_data_in(IF.req3_data_in),.req3_tag_in(IF.req3_tag_in), .out_resp3(IF.out_resp3), .out_data3(IF.out_data3), .out_tag3(IF.out_tag3),
			.req4_cmd_in(IF.req4_cmd_in), .req4_data_in(IF.req4_data_in),.req4_tag_in(IF.req4_tag_in), .out_resp4(IF.out_resp4), .out_data4(IF.out_data4), .out_tag4(IF.out_tag4));

	test TEST(IF.TEST);

	initial begin
        	$display("Top is running");
    	end
endmodule

interface dut_IF(input bit c_clk);

	//inputs to device
	logic reset;
	logic [0:3] req1_cmd_in;
	logic [0:31] req1_data_in;
	logic [0:1] req1_tag_in;

	logic [0:3] req2_cmd_in;
	logic [0:31] req2_data_in;
	logic [0:1] req2_tag_in;

	logic [0:3] req3_cmd_in;
	logic [0:31] req3_data_in;
	logic [0:1] req3_tag_in;

	logic [0:3] req4_cmd_in;
	logic [0:31] req4_data_in;
	logic [0:1] req4_tag_in;

	//outputs of device 
	logic [0:1] out_resp1;
	logic [0:31] out_data1;
	logic [0:1] out_tag1;

	logic [0:1] out_resp2;
	logic [0:31] out_data2;
	logic [0:1] out_tag2;

	logic [0:1] out_resp3;
	logic [0:31] out_data3;
	logic [0:1] out_tag3;

	logic [0:1] out_resp4;
	logic [0:31] out_data4;
	logic [0:1] out_tag4;

	clocking cb @(posedge c_clk);	//Declare cb
		output req1_cmd_in,req1_data_in, req1_tag_in, req2_cmd_in,req2_data_in, req2_tag_in, req3_cmd_in,req3_data_in, req3_tag_in, req4_cmd_in,req4_data_in, req4_tag_in;
		input out_resp1, out_data1, out_tag1, out_resp2, out_data2, out_tag2, out_resp3, out_data3, out_tag3, out_resp4, out_data4, out_tag4; 
	endclocking

	//ASYNC reset
	modport	TEST (clocking cb, input reset, c_clk);
    	modport	DUT (
		input c_clk, reset, req1_cmd_in,req1_data_in, req1_tag_in, req2_cmd_in,req2_data_in, req2_tag_in, req3_cmd_in,req3_data_in, req3_tag_in, req4_cmd_in,req4_data_in, req4_tag_in, 
		output out_resp1, out_data1, out_tag1, out_resp2, out_data2, out_tag2,out_resp3, out_data3, out_tag3, out_resp4, out_data4, out_tag4
		);	
endinterface
