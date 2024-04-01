`ifndef ASSERT
`define ASSERT
`include "interface.sv"
   module assertion_cov(intf_cnt intf);
	check_psel_penable_1: cover property(@(posedge intf.pclk) intf.psel ##1 intf.penable);
	check_psel_penable_2: cover property(@(posedge intf.pclk) ~intf.psel |-> ~intf.penable);
	check_sda_scl_reset: cover property(@(posedge intf.pclk) (intf.psel && intf.penable && intf.pwrite && (intf.paddr == 4) && ~intf.pwdata[7]) |-> (~intf.sda_io && ~intf.scl_io));
   endmodule
`endif
