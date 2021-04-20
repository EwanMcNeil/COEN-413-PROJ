library verilog;
use verilog.vl_types.all;
entity alu_output_stage is
    port(
        out_data1       : out    vl_logic_vector(0 to 31);
        out_resp1       : out    vl_logic_vector(0 to 1);
        out_tag1        : out    vl_logic_vector(0 to 1);
        out_data2       : out    vl_logic_vector(0 to 31);
        out_resp2       : out    vl_logic_vector(0 to 1);
        out_tag2        : out    vl_logic_vector(0 to 1);
        out_data3       : out    vl_logic_vector(0 to 31);
        out_resp3       : out    vl_logic_vector(0 to 1);
        out_tag3        : out    vl_logic_vector(0 to 1);
        out_data4       : out    vl_logic_vector(0 to 31);
        out_tag4        : out    vl_logic_vector(0 to 1);
        out_resp4       : out    vl_logic_vector(0 to 1);
        scan_out        : out    vl_logic;
        alu_overflow    : in     vl_logic;
        alu_result      : in     vl_logic_vector(0 to 63);
        prio_alu_out_vld: in     vl_logic;
        prio_alu_tag    : in     vl_logic_vector(0 to 3);
        reset           : in     vl_logic;
        scan_in         : in     vl_logic;
        a_clk           : in     vl_logic;
        b_clk           : in     vl_logic;
        c_clk           : in     vl_logic
    );
end alu_output_stage;
