////////////////////////////////////////////////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////s           www.testbench.in           s////
////s                                      s////
////s        SystemVerilog Tutorial        s////
////s                                      s////
////s           gopi@testbench.in          s////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////////////////////////////////////////////////
`include "transactor.sv"
`include "generator.sv"
`include "interface.sv"
`include "driver.sv"
`include "env.sv"
`include "assertion.sv"

`ifdef TEST1
  `include "test_1.sv"
`elsif TEST2
  `include "test_2.sv"
`endif
  module top();
      reg pclk = 0;
      reg i2c_core_clock = 0;
      always #20 i2c_core_clock = ~i2c_core_clock ;
      always #5 pclk = ~pclk;
      // DUT/assertion monitor/testcase instances
      intf_cnt vif(pclk, i2c_core_clock );
      assertion_cov acov(vif);
      dut_top dut(
        .i2c_core_clock_i(vif.i2c_core_clock), 
        .pclk_i(vif.pclk), 
        .preset_n_i(vif.preset), 
        .penable_i(vif.penable), 
        .psel_i(vif.psel), 
        .paddr_i(vif.paddr), 
        .pwdata_i(vif.pwdata), 
        .pwrite_i(vif.pwrite), 
        .prdata_o(vif.prdata_o),
        .pready_o(vif.pready_o),
        .sda_io(vif.sda_io),
        .scl_io(vif.scl_io)
    );
    testcase test(vif);
    assertion_cov assert_cov(vif);
   endmodule
