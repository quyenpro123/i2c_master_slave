`ifdef TEST_1
    `include "test_1.sv"
`elsif TEST_2
    `include "test_2.sv"
`endif
module top_tb ();
    reg pclk = 0;
    reg i2c_core_clock = 0;
    preset = 0;
    always #5 pclk = ~pclk;
    always #20 i2c_core_clock = ~i2c_core_clock;
    
    intf intf(pclk, preset, i2c_core_clock)
endmodule