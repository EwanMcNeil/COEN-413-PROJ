library verilog;
use verilog.vl_types.all;
entity shifter is
    port(
        bin_ovfl        : out    vl_logic;
        shift_out       : out    vl_logic_vector(0 to 63);
        scan_out        : out    vl_logic;
        shift_cmd       : in     vl_logic_vector(0 to 3);
        shift_places    : in     vl_logic_vector(0 to 63);
        shift_val       : in     vl_logic_vector(0 to 63);
        reset           : in     vl_logic;
        scan_in         : in     vl_logic;
        a_clk           : in     vl_logic;
        b_clk           : in     vl_logic;
        c_clk           : in     vl_logic
    );
end shifter;
