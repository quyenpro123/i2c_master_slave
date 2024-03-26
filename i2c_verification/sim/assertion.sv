////////////////////////////////////////////////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////s           www.testbench.in           s////
////s                                      s////
////s        SystemVerilog Tutorial        s////
////s                                      s////
////s           gopi@testbench.in          s////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////////////////////////////////////////////////
`ifndef ASSERT
`define ASSERT
`include "interface.sv"
   module assertion_cov(intf_cnt intf);
    //    check_start: cover property (@(posedge vif.pclk) $fell(vif.sda_io) |-> vif.scl_io) $display("start condition detected");
    //    check_stop: cover property (@(posedge vif.pclk) $rose(vif.sda_io) |-> vif.scl_io) $display("stop condition detected");
    //    check_sda_scl_reset: cover property (@(posedge vif.i2c_core_clock) ~vif.sda_io || ~vif.scl_io |-> vif.pclk && (vif.paddr != 5 && vif.pwdata[7])) ;
    endmodule
`endif
