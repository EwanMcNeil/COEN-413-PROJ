program automatic test(dut_IF.TEST vif); 
	
	`include "environment.sv";

	environment env;
	//gen generator;



	
	initial begin
  		env = new(vif);

  		//generator = new();
  		//env.generator = generator;

  		env.run();

  		$finish;
	end
endprogram
