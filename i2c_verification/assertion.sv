`ifndef ASRT
`define ASRT
class assertion (virtual intf vif);
    check_start: cover property (@(posedge clock) $fell(vif.sda_in) |-> vif.scl_in) $display("start condition detected");
    check_stop: cover property (@(posedge clock) $rose(vif.sda_in) |-> vif.scl_in) $display("stop condition detected");
    check_sda_scl_reset: ~vif.sda_in || ~vif.scl_in |-> vif.pclk && (vif.paddr != 5 && vif.pwdata[7]) ;
endclass //className
`endif