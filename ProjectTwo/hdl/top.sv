module Top;
    	bit clk;	
    	always #50 clk = ~clk;	

    	dut_IF IF(.c_clk(clk));
    	testBench TEST(IF.TEST);

	// I don't think we need this
	/*calc2_top DUT(.c_clk(IF.c_clk), .reset(IF.reset),
		      .req1_cmd_in(IF.req1_cmd_in), .req1_data_in(IF.req1_data_in), .req1_tag_in(IF.req1_tag_in),
                      .out_resp1(IF.out_resp1), .out_data1(IF.out_data1), .out_tag1(IF.out_tag1),

		      .req2_cmd_in(IF.req2_cmd_in), .req2_data_in(IF.req2_data_in), .req2_tag_in(IF.req2_tag_in),
		      .out_resp2(IF.out_resp2), .out_data2(IF.out_data2), .out_tag2(IF.out_tag2),

		      .req3_cmd_in(IF.req3_cmd_in), .req3_data_in(IF.req3_data_in), .req3_tag_in(IF.req3_tag_in),
 		      .out_resp3(IF.out_resp3), .out_data3(IF.out_data3), .out_tag3(IF.out_tag3),

		      .req4_cmd_in(IF.req4_cmd_in), .req4_data_in(IF.req4_data_in), .req4_tag_in(IF.req4_tag_in),
		      .out_resp4(IF.out_resp4), .out_data4(IF.out_data4), .out_tag4(IF.out_tag4)
	);*/

    	initial begin
        	$display("T: %0t [Top] is running", $time);
    	end
endmodule