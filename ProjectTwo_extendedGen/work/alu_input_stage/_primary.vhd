library verilog;
use verilog.vl_types.all;
entity alu_input_stage is
    port(
        alu_data1       : out    vl_logic_vector(0 to 63);
        alu_data2       : out    vl_logic_vector(0 to 63);
        prio_cmd        : in     vl_logic_vector(0 to 3);
        prio_data1      : in     vl_logic_vector(0 to 31);
        prio_data2      : in     vl_logic_vector(0 to 31);
        alu_cmd         : in     vl_logic_vector(0 to 3)
    );
end alu_input_stage;
